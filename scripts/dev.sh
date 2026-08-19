#!/usr/bin/env bash
# scripts/dev.sh
#
# Simulate GitHub Pages locally with hot reload across:
#   - the schema source (`schema/`)
#   - the book source (`book/src/`, `book/*.toml`)
#   - any extra paths named in DEV_WATCH_EXTRA (see below)
#
# Editing any of these triggers a full rebuild: the book and versioned
# schema docs are regenerated into `site/`. Producers (`panschema`,
# `mdbook-listings`, `mdbook-admonish`, `mdbook-panschema`) resolve via
# $PATH, and every rebuild prints which binary answered — the consumer
# story, and what CI does.
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
# Two seams for wrappers (both optional, both plain environment):
#
#   DEV_WATCH_EXTRA   Space-separated extra paths to watch. Anything a
#                     wrapper wants the loop to rebuild on — e.g. a
#                     producer's source tree — goes here. Paths are
#                     watched as given; never hand this a directory
#                     containing build output (a `target/`), which would
#                     loop the watcher.
#   REBUILD_CMD       What to run on each change (default:
#                     scripts/rebuild.sh). A wrapper that resolves
#                     producer binaries can point this back through
#                     itself so every cycle re-resolves.
#
# Stop with Ctrl+C.
#
# Requires:
#   - mdbook plus the producers on PATH: mdbook-listings, mdbook-admonish
#     (the fork), panschema, mdbook-panschema — see README "Toolchain".
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

REBUILD_CMD="${REBUILD_CMD:-scripts/rebuild.sh}"

# --- Tool availability ---

missing=()
for cmd in mdbook watchexec panschema mdbook-panschema mdbook-listings mdbook-admonish; do
  command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "ERROR: required tools not on PATH:"
  for c in "${missing[@]}"; do echo "  - $c"; done
  echo ""
  echo "Setup:"
  echo "  - mdbook-listings / mdbook-admonish / panschema / mdbook-panschema:"
  echo "      see README 'Toolchain'"
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

# Wrapper-supplied extras (word-split on purpose; paths are one token each).
extra_paths=()
for p in ${DEV_WATCH_EXTRA:-}; do
  [ -e "$p" ] || continue
  watch_args+=( --watch "$p" )
  extra_paths+=("$p")
done

# --- Initial build ---

# The sole build on startup: watchexec runs with --postpone (below), so it
# waits for the first change instead of also building on launch. Without it
# the site builds twice and --clear wipes the "Starting server" messages.
sh -c "$REBUILD_CMD"

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
# variable" on an empty array, and this array IS empty in the default case.
for p in ${extra_paths[@]+"${extra_paths[@]}"}; do
  echo "  $p (DEV_WATCH_EXTRA)"
done
echo ""
echo "Edit any of those to trigger a rebuild. Ctrl+C to stop."
echo ""

watchexec \
  --debounce 500ms \
  --no-vcs-ignore \
  --postpone \
  --clear \
  "${watch_args[@]}" \
  -- sh -c "$REBUILD_CMD"
