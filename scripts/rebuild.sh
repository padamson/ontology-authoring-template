#!/usr/bin/env bash
# scripts/rebuild.sh
#
# Rebuild the dogfood-loop site: refresh producer debug binaries
# (panschema, mdbook-listings, mdbook-admonish) via `cargo build`, then
# rebuild the combined site (book + versioned schema docs) into `site/`.
#
# Mirrors what `.github/workflows/docs.yml` does in CI (minus the deploy
# step), but with producer-source changes flowing in via the local debug
# binaries the user's shell aliases point at (see README "Dogfooding the
# tooling"). Called by `scripts/dev.sh` for the initial build
# and re-invoked on every file change via `cargo-watch`.
#
# Where the producer binaries come from is chosen per producer, via
# TOOL_SOURCE / MDBOOK_LISTINGS_SOURCE / PANSCHEMA_SOURCE — see
# scripts/tool-source.sh for the accepted values. The default is `path`,
# which is what CI uses.
#
# Set SKIP_PRODUCER_BUILD=1 to skip the `cargo build` a `sibling` source
# would otherwise run, and use whatever that checkout last built — useful
# while iterating on a producer in its own repo, so its slow build doesn't
# run on every schema change.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ts() { date '+%H:%M:%S'; }

# Where each producer's binaries come from (path | sibling | git[:rev] |
# crates[:version]), per TOOL_SOURCE / MDBOOK_LISTINGS_SOURCE /
# PANSCHEMA_SOURCE. Default is `path`, matching what CI does.
# shellcheck source=scripts/tool-source.sh
. scripts/tool-source.sh

# Shell aliases (e.g. `alias panschema=.../target/debug/panschema` in
# ~/.zshrc) only load in *interactive* shells — non-interactive scripts
# like this one resolve `panschema`, `mdbook-listings`, `mdbook-panschema`
# via $PATH. So a selected source has to reach this script as a PATH
# prepend, not as an alias.
echo ""
echo "==> [$(ts)] Resolve producer binaries:"
for producer in $TOOL_PRODUCERS; do
  spec="$(tool_source_for "$producer")"
  if [ "$spec" = "sibling" ] && [ -n "${SKIP_PRODUCER_BUILD:-}" ]; then
    echo "  - $producer: $spec (build skipped — SKIP_PRODUCER_BUILD set)"
  else
    echo "  - $producer: $spec"
  fi
  # A silent wait here on `sibling` = another cargo run holds this
  # producer's target lock. cargo writes to stderr, so that message reaches
  # the terminal rather than this capture.
  if ! bin_dir="$(tool_bin_dir "$producer" "$spec")"; then
    echo "    ❌ could not resolve $producer — bailing this rebuild cycle."
    exit 1
  fi
  [ -n "$bin_dir" ] && export PATH="$bin_dir:$PATH"
done

echo ""
echo "==> [$(ts)] Producer versions in use:"
report_tool_versions

echo ""
echo "==> [$(ts)] Rebuild the combined site:"

# 1. Book — outputs to book/build/
(
  cd book
  # Admonish and schema-link CSS/JS are gitignored (produced assets).
  # Generate each once if missing so a fresh-clone dev loop is green —
  # guarded, not every cycle, because both installers can rewrite book.toml
  # (watched by dev.sh) and would otherwise risk a rebuild loop. Listings
  # install stays unconditional: it refreshes callout CSS/JS for producer
  # dogfooding.
  [ -f mdbook-admonish.css ] || mdbook-admonish install . >/dev/null 2>&1
  { [ -f schema-link.css ] && [ -f schema-link.js ]; } || mdbook-panschema install >/dev/null 2>&1
  mdbook-listings install >/dev/null 2>&1
  mdbook build
)

# 2. Versioned schema docs — site/schema/{main,current}/ (plus any
# release tags once they exist).
# --edge-from-worktree: render /schema/main/ from the working tree
# rather than `git show main:schema/<name>.yaml`, so local edits
# appear immediately. CI (.github/workflows/docs.yml) deliberately
# omits this flag so deployed docs always reflect committed state.
panschema publish --edge-from-worktree

# 3. Combine — book at site/ root, schema docs already at site/schema/
mkdir -p site
cp -r book/build/* site/

echo "==> [$(ts)] Done. Reload http://localhost:${PORT:-8000}/"
