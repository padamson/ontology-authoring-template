#!/usr/bin/env bash
# scripts/rebuild.sh
#
# Rebuild the combined site (book + versioned schema docs) into `site/`.
#
# Mirrors what `.github/workflows/docs.yml` does in CI (minus the deploy
# step). Producers (`panschema`, `mdbook-panschema`, `mdbook-listings`,
# `mdbook-admonish`) are invoked by name and resolve via $PATH — the
# consumer story, and what CI does. A wrapper that wants this script to
# use different binaries prepends to PATH before invoking it.
#
# Called by `scripts/dev.sh` for the initial build and re-invoked on
# every file change.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ts() { date '+%H:%M:%S'; }

# Shell aliases (e.g. `alias panschema=…/target/debug/panschema` in
# ~/.zshrc) only load in *interactive* shells — a non-interactive script
# like this one resolves every producer via $PATH. The report makes the
# resolution visible, which is what catches a stale binary: PATH holding
# an install built weeks ago while the alias hid it.
hash -r 2>/dev/null || true
echo ""
echo "==> [$(ts)] Producer versions in use (via PATH):"
for producer in panschema mdbook-panschema mdbook-listings mdbook-admonish; do
  ver="$(command "$producer" --version 2>/dev/null | head -1)"
  printf '  %-18s %s\n' "$producer" "${ver:-(not found)}"
done

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
