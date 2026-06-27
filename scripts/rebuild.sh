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
# Set SKIP_PRODUCER_BUILD=1 to skip the producer `cargo build` step and
# regenerate the site from the producer binaries already on PATH — useful
# while iterating on a producer (e.g. panschema) in its own repo, so its
# slow build doesn't run on every schema change.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ts() { date '+%H:%M:%S'; }

# Producer dogfooding is opt-in. Set PRODUCER_ROOT in your environment to
# the directory where you've cloned the producer source repos (panschema,
# mdbook-listings, the mdbook-admonish fork) — see the README "Dogfooding
# the tooling" section. Leave it unset (the normal author-only case) and
# this script skips all producer build/PATH logic and just uses whatever
# producer binaries are already on PATH.
PRODUCER_ROOT="${PRODUCER_ROOT:-}"

# Shell aliases (e.g. `alias panschema=.../target/debug/panschema` in
# ~/.zshrc) only load in *interactive* shells — non-interactive scripts
# like this one resolve `panschema`, `mdbook-listings`, `mdbook-admonish`
# via $PATH, which would hit the cargo-installed releases in
# ~/.cargo/bin/ instead of the dogfood-fresh debug binaries. When
# PRODUCER_ROOT is set, prepend each producer's target/debug to PATH so
# script invocations use the same binaries the interactive shell does.
if [ -n "$PRODUCER_ROOT" ]; then
  for producer in panschema mdbook-listings mdbook-admonish; do
    debug_dir="$PRODUCER_ROOT/$producer/target/debug"
    if [ -x "$debug_dir/$producer" ]; then
      export PATH="$debug_dir:$PATH"
    fi
  done
fi

echo ""
if [ -z "$PRODUCER_ROOT" ]; then
  echo "==> [$(ts)] PRODUCER_ROOT unset — using producer binaries on PATH (author-only mode)."
elif [ -n "${SKIP_PRODUCER_BUILD:-}" ]; then
  echo "==> [$(ts)] Skip producer rebuild (SKIP_PRODUCER_BUILD set) — using binaries on PATH."
else
  echo "==> [$(ts)] Refresh producer debug binaries (no-op if no change):"

  # Each producer: if the repo exists locally, `cargo build` it. Incremental
  # build is a few hundred ms when nothing changed; updates target/debug/
  # (the path the user's shell aliases resolve to) when source changed.
  for producer in panschema mdbook-listings mdbook-admonish; do
    repo="$PRODUCER_ROOT/$producer"
    if [ -d "$repo" ]; then
      echo "  - $producer"
      (cd "$repo" && cargo build 2>&1 | tail -3) || {
        echo "    ❌ $producer build failed — bailing this rebuild cycle."
        exit 1
      }
    else
      echo "  - $producer: ⚠ not cloned at $repo — skipping"
    fi
  done
fi

echo ""
echo "==> [$(ts)] Rebuild the combined site:"

# 1. Book — outputs to book/build/
(
  cd book
  # Admonish CSS/JS is gitignored (a produced asset). Generate it once if
  # missing so a fresh-clone dev loop is green — guarded, not every cycle,
  # because `mdbook-admonish install` can rewrite book.toml (watched by
  # dev.sh) and would otherwise risk a rebuild loop. Listings install stays
  # unconditional: it refreshes callout CSS/JS for producer dogfooding.
  [ -f mdbook-admonish.css ] || mdbook-admonish install . >/dev/null 2>&1
  mdbook-listings install >/dev/null 2>&1
  mdbook build
)

# 2. Versioned schema docs — site/schema/{main,current}/ (plus any
# release tags once they exist).
# --edge-from-worktree: render /schema/main/ from the working tree
# rather than `git show main:schema/myschema.yaml`, so local edits
# appear immediately. CI (.github/workflows/docs.yml) deliberately
# omits this flag so deployed docs always reflect committed state.
panschema publish --edge-from-worktree

# 3. Combine — book at site/ root, schema docs already at site/schema/
mkdir -p site
cp -r book/build/* site/

echo "==> [$(ts)] Done. Reload http://localhost:${PORT:-8000}/"
