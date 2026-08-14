#!/usr/bin/env bash
# scripts/dev.sh
#
# Simulate GitHub Pages locally with hot reload across:
#   - the schema source (`schema/`)
#   - the book source (`book/src/`, `book/*.toml`)
#   - PRODUCER source code, for any producer set to the `sibling` source
#
# Editing any of these triggers a full rebuild. A `sibling` producer is
# refreshed first (incremental `cargo build`), then the book and versioned
# schema docs are regenerated into `site/`. Which binary each producer
# resolves to is decided by scripts/tool-source.sh and applied as a $PATH
# prepend in scripts/rebuild.sh, which prints the result every cycle.
#
# With `live-server` (npm) installed, the browser auto-refreshes after
# each rebuild. Otherwise falls back to `python3 -m http.server`, where
# you refresh manually.
#
# NOT watched: the generated book assets (book/*.js, book/*.css from the
# admonish/listings/schema-link installers) — rebuild.sh regenerates them,
# so watching them would loop the watcher. If you hand-edit one to test,
# nudge a rebuild with `touch book/book.toml`.
#
# Usage:
#   ./scripts/dev.sh                 # PORT=8000 (default)
#   PORT=8080 ./scripts/dev.sh
#
#   Choosing where the producers come from (default: whatever is on PATH,
#   which is what CI does). TOOL_SOURCE sets both; the per-producer
#   variables override it, so you can move one and leave the other alone:
#
#     TOOL_SOURCE=sibling ./scripts/dev.sh
#         All of them from ../<producer>, `cargo build`, used from
#         target/debug. Their source is watched, so editing a producer
#         retriggers the loop.
#     PANSCHEMA_SOURCE=git:21eb8fb ./scripts/dev.sh
#         panschema from that commit on GitHub; mdbook-listings unchanged.
#     MDBOOK_LISTINGS_SOURCE=crates:0.2.0 PANSCHEMA_SOURCE=sibling ./scripts/dev.sh
#         The published listings crate against a local panschema.
#
#   git and crates installs are cached under .dev-tools/ and reused, so
#   flipping between them costs nothing after the first build.
#
#   SKIP_PRODUCER_BUILD=1 ./scripts/dev.sh
#       For a `sibling` source, don't run its `cargo build` and don't watch
#       its source; use whatever that checkout last built (the rebuild stops
#       with an error if that checkout has no binaries). Use when you're
#       driving the producer's build in its own repo and don't want its slow
#       build (linking a ~35 MB debug binary) on every schema change. After
#       rebuilding the producer yourself, trigger a site refresh by touching
#       a watched file (e.g. `touch` the schema file).
#
# Stop with Ctrl+C.
#
# Requires (in this repo):
#   - mdbook on PATH, plus any producer left on the default `path` source
#     (see README "Dogfooding the tooling"). A producer set to sibling, git
#     or crates is resolved by this script and need not be on PATH.
#   - watchexec (general-purpose file watcher; cargo-watch is the wrong
#     tool here because this is not a Cargo project):
#       cargo install watchexec-cli

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# --- Stop any prior dev loop for THIS repo ---

# A previous run that wasn't fully torn down leaves a stale watcher racing
# our rebuilds and a stale server serving the OLD site/ (the "callouts seem
# missing" foot-gun, now invisible). The PID file scopes cleanup to this
# repo: a pkill by command line would also kill other books' identical
# watchexec/rebuild.sh loops running at the same time.
PID_FILE=".dev.pid"
if [ -f "$PID_FILE" ]; then
  old_pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
    echo "Stopping previous dev loop (PID $old_pid)"
    pkill -TERM -P "$old_pid" 2>/dev/null || true
    kill -TERM "$old_pid" 2>/dev/null || true
    # Give it a moment to release its port before we scan.
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      kill -0 "$old_pid" 2>/dev/null || break
      sleep 0.2
    done
  fi
  rm -f "$PID_FILE"
fi
echo $$ > "$PID_FILE"

# --- Pick a port ---

# First free TCP port at or above PORT (default 8000). Other servers on the
# starting port (another book's dev loop, an unrelated project) are stepped
# over, not killed — only this repo's own stale instance is cleaned up above.
if ! command -v lsof >/dev/null 2>&1; then
  echo "warning: lsof not found — can't check for busy ports; using PORT as-is." >&2
fi
free_port() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    while lsof -iTCP:"$port" -sTCP:LISTEN -t >/dev/null 2>&1; do
      port=$((port + 1))
    done
  fi
  echo "$port"
}
PORT="$(free_port "${PORT:-8000}")"
export PORT

# When set, don't build or watch producers set to `sibling`; use whatever
# their target/debug already holds and only regenerate the site.
SKIP_PRODUCER_BUILD="${SKIP_PRODUCER_BUILD:-}"
export SKIP_PRODUCER_BUILD

# Producer source selection (path | sibling | git[:rev] | crates[:version]),
# per producer. Sourcing this here lets the watch list below ask each producer
# what it is set to; rebuild.sh sources it again to do the resolving.
# shellcheck source=scripts/tool-source.sh
. scripts/tool-source.sh

# Exported so scripts/rebuild.sh (invoked below and on every watch trigger)
# resolves exactly what this process decided to watch.
export TOOL_SOURCE="${TOOL_SOURCE:-}"
export MDBOOK_LISTINGS_SOURCE="${MDBOOK_LISTINGS_SOURCE:-}"
export PANSCHEMA_SOURCE="${PANSCHEMA_SOURCE:-}"
export MDBOOK_ADMONISH_SOURCE="${MDBOOK_ADMONISH_SOURCE:-}"
export SIBLING_ROOT
export PRODUCER_ROOT="${PRODUCER_ROOT:-}"

# --- Tool availability ---

# Only producers left on the default `path` source have to be on PATH already.
# A git or crates source installs into .dev-tools/ and a sibling source builds
# into target/debug, so requiring those up front would reject a perfectly good
# setup.
missing=()
for cmd in mdbook watchexec; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
for producer in $TOOL_PRODUCERS; do
  [ "$(tool_source_for "$producer")" = "path" ] || continue
  command -v "$producer" >/dev/null 2>&1 || missing+=("$producer")
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "ERROR: required tools not on PATH:"
  for c in "${missing[@]}"; do echo "  - $c"; done
  echo ""
  echo "Setup:"
  echo "  - mdbook / mdbook-listings / mdbook-admonish / panschema:"
  echo "      see README 'Dogfooding the tooling' for the alias pattern"
  echo "  - watchexec: cargo install watchexec-cli"
  exit 1
fi

# --- Build watch path list ---

# This repo's source/config files.
watch_args=(
  --watch schema
  --watch book/src
  --watch book/book.toml
  --watch book/listings.toml
  --watch panschema-publish.toml
)

# Producer source paths. For each producer repo present locally, watch:
#   - top-level Cargo.toml
#   - top-level src/ if present (single-crate repos: mdbook-listings, mdbook-admonish)
#   - any workspace sub-crate's Cargo.toml + src/ (panschema's workspace
#     has panschema/, panschema-viz/)
# Crucially do NOT watch the whole repo — target/ would create a rebuild loop.
producer_dirs=()
for producer in $TOOL_PRODUCERS; do
  # Only a `sibling` source has local files worth watching. A git or crates
  # source is a fixed, already-built binary, and `path` is out of our hands.
  [ "$(tool_source_for "$producer")" = "sibling" ] || continue
  # SKIP_PRODUCER_BUILD: don't watch producer source — you're driving the
  # producer's build in its own repo, so leave it out of this loop.
  [ -n "${SKIP_PRODUCER_BUILD:-}" ] && break
  repo="$SIBLING_ROOT/$producer"
  [ -d "$repo" ] || continue

  [ -f "$repo/Cargo.toml" ] && watch_args+=( --watch "$repo/Cargo.toml" )
  [ -d "$repo/src" ] && watch_args+=( --watch "$repo/src" )

  # Workspace sub-crates
  for sub_toml in "$repo"/*/Cargo.toml; do
    [ -f "$sub_toml" ] || continue
    [ "$sub_toml" = "$repo/Cargo.toml" ] && continue
    sub_dir="$(dirname "$sub_toml")"
    watch_args+=( --watch "$sub_toml" )
    [ -d "$sub_dir/src" ] && watch_args+=( --watch "$sub_dir/src" )
  done

  producer_dirs+=("$producer")
done

# --- Initial build ---

# The sole build on startup: watchexec runs with --postpone (below), so it
# waits for the first change instead of also building on launch. Without it
# the site builds twice and --clear wipes the "Starting server" messages.
scripts/rebuild.sh

# --- HTTP server ---

# Launch the server directly, NOT in a `( cd site && … ) &` subshell: with a
# subshell, $! is the subshell's PID, not the server's, so cleanup would kill
# the wrapper and orphan the real server. Pass the directory as an argument
# instead, so SERVER_PID is the process we actually need to kill.
if command -v live-server >/dev/null 2>&1; then
  echo ""
  echo "Starting live-server on http://localhost:$PORT/ (browser auto-reload)"
  live-server --port="$PORT" --no-browser --quiet site &
else
  echo ""
  echo "Starting python3 -m http.server on http://localhost:$PORT/"
  echo "  (no auto-reload; refresh the browser manually after each rebuild)"
  echo "  Tip: npm install -g live-server  # for browser auto-reload"
  python3 -m http.server "$PORT" --directory site >/dev/null 2>&1 &
fi
SERVER_PID=$!

cleanup() {
  echo ""
  echo "Stopping server (PID $SERVER_PID)"
  kill "$SERVER_PID" 2>/dev/null || true
  rm -f "$PID_FILE"
}
# EXIT covers all paths (Ctrl+C, set -e bail-out, normal exit).
trap cleanup EXIT

# --- Watch + rebuild ---

echo ""
echo "Watching for changes in:"
echo "  schema/, book/src/, book/*.toml, panschema-publish.toml"
# `${arr[@]+"${arr[@]}"}` not `"${arr[@]}"`: under `set -u`, bash < 4.4 —
# including the /bin/bash 3.2 that ships with macOS — errors "unbound
# variable" on an empty array, and this array IS empty in the default case
# (no PRODUCER_ROOT) and under SKIP_PRODUCER_BUILD.
for p in ${producer_dirs[@]+"${producer_dirs[@]}"}; do
  echo "  $p source (producer dogfood)"
done
[ -n "${SKIP_PRODUCER_BUILD:-}" ] && echo "  (sibling producers not watched or rebuilt — SKIP_PRODUCER_BUILD set; using what their target/debug already holds)"
echo ""
echo "Edit any of those to trigger a rebuild. Ctrl+C to stop."
echo ""

watchexec \
  --debounce 500ms \
  --no-vcs-ignore \
  --postpone \
  --clear \
  "${watch_args[@]}" \
  -- scripts/rebuild.sh
