#!/usr/bin/env bash
# scripts/tool-source.sh
#
# Resolve where the book's producer binaries come from, so a dev loop can
# test the build against a sibling checkout, a GitHub ref, or a published
# crate without touching ~/.cargo/bin.
#
# Sourced by scripts/rebuild.sh and scripts/dev.sh; not meant to be run
# directly.
#
# Environment:
#   TOOL_SOURCE               default for every producer below
#   MDBOOK_LISTINGS_SOURCE    overrides TOOL_SOURCE for mdbook-listings
#   PANSCHEMA_SOURCE          overrides TOOL_SOURCE for panschema
#   MDBOOK_ADMONISH_SOURCE    overrides TOOL_SOURCE for mdbook-admonish
#
# Each takes one of:
#   path                (default) whatever is already on PATH — the
#                       consumer story, and what CI does
#   sibling             ../<producer>, built with `cargo build`, used from
#                       target/debug. Set SIBLING_ROOT to look elsewhere.
#   git                 github.com/padamson/<producer> at its useful default
#                       branch
#   git:<ref>           ...at a branch, tag, or commit hash. The flag cargo
#                       gets (--branch/--tag/--rev) is chosen from the ref's
#                       shape, since cargo cannot resolve a branch via --rev.
#   crates              the latest published version
#   crates:<version>    ...at an exact version
#
# git and crates installs land in .dev-tools/<producer>/<key>/bin (gitignored)
# and are reused on later runs, so switching back and forth is cheap. Delete
# that directory to force a reinstall.
#
# mdbook-admonish is only ever the feat/mdbook-0.5-compat fork, so it has no
# crates source and its bare `git` means that branch rather than the default
# one. It is listed here so that using a local build of it stays opt-in and
# shows up in the version report, rather than being picked up silently.

# Where sibling checkouts live. PRODUCER_ROOT is the older name for this and
# still works.
SIBLING_ROOT="${SIBLING_ROOT:-${PRODUCER_ROOT:-..}}"

TOOL_CACHE=".dev-tools"

# producer → the crates.io crate name
_crate_for() {
  case "$1" in
    mdbook-listings) echo "mdbook-listings" ;;
    panschema)       echo "panschema" ;;
    mdbook-admonish) echo "" ;;   # fork only; never published
  esac
}

# producer → git remote
_git_url_for() {
  case "$1" in
    mdbook-listings) echo "https://github.com/padamson/mdbook-listings" ;;
    panschema)       echo "https://github.com/padamson/panschema" ;;
    mdbook-admonish) echo "https://github.com/padamson/mdbook-admonish" ;;
  esac
}

# producer → every binary that must end up installed. panschema's repo is a
# workspace and the book needs two of its members: `panschema` itself and the
# `mdbook-panschema` preprocessor that generates the schema-link assets.
_bins_for() {
  case "$1" in
    mdbook-listings) echo "mdbook-listings" ;;
    panschema)       echo "panschema mdbook-panschema" ;;
    mdbook-admonish) echo "mdbook-admonish" ;;
  esac
}

# Every producer whose source is selectable, in the order they are resolved.
TOOL_PRODUCERS="mdbook-listings panschema mdbook-admonish"

# The configured source for one producer: its own variable, else TOOL_SOURCE,
# else `path`.
tool_source_for() {
  local producer="$1" specific=""
  case "$producer" in
    mdbook-listings) specific="${MDBOOK_LISTINGS_SOURCE:-}" ;;
    panschema)       specific="${PANSCHEMA_SOURCE:-}" ;;
    mdbook-admonish) specific="${MDBOOK_ADMONISH_SOURCE:-}" ;;
  esac
  echo "${specific:-${TOOL_SOURCE:-path}}"
}

# A filesystem-safe cache key for a spec: git:abc123 → git-abc123.
_cache_key() {
  local spec="$1"
  case "$spec" in
    git)     echo "git-default" ;;
    crates)  echo "crates-latest" ;;
    *)       echo "${spec//[:\/]/-}" ;;
  esac
}

# The latest published version of a crate. crates.io rejects requests with no
# User-Agent, so send one.
_latest_crate_version() {
  curl -sf -H "User-Agent: ontology-authoring-template-dev-loop" \
    "https://crates.io/api/v1/crates/$1" |
    python3 -c 'import json,sys; print(json.load(sys.stdin)["crate"]["max_version"])'
}

# cargo takes --rev, --tag and --branch, and they are not interchangeable:
# --rev cannot resolve a bare remote branch name. Pick by shape — a hex string
# is a commit, a leading `v` on a version is a release tag, anything else is a
# branch.
_git_ref_flag() {
  case "$1" in
    v[0-9]*)                 echo "--tag" ;;
    *[!0-9a-f]*)             echo "--branch" ;;
    ???????*)                echo "--rev" ;;
    *)                       echo "--branch" ;;
  esac
}

# Producers whose useful ref is not their default branch.
_default_git_ref_for() {
  case "$1" in
    # The fork exists for this branch; its default branch is upstream's.
    mdbook-admonish) echo "feat/mdbook-0.5-compat" ;;
    *)               echo "" ;;
  esac
}

# Absolute form of a directory. Every path this file hands back must be
# absolute: rebuild.sh builds the book from inside `(cd book && ...)`, where a
# relative PATH entry like ../panschema/target/debug quietly stops resolving
# and the build falls back to whatever is on PATH.
_abs_dir() {
  (cd "$1" 2>/dev/null && pwd)
}

# Install (or reuse) a producer for one spec and echo the directory holding
# its binaries. Echoes nothing for `path`, which means "leave PATH alone".
#
# Returns non-zero and explains itself if the spec cannot be satisfied.
tool_bin_dir() {
  local producer="$1" spec="$2"
  local crate git_url bins key root rev version

  crate="$(_crate_for "$producer")"
  git_url="$(_git_url_for "$producer")"
  bins="$(_bins_for "$producer")"

  case "$spec" in
    path)
      return 0
      ;;

    sibling)
      local repo="$SIBLING_ROOT/$producer"
      if [ ! -d "$repo" ]; then
        echo "ERROR: $producer source '$spec' needs a checkout at $repo" >&2
        return 1
      fi
      if [ -z "${SKIP_PRODUCER_BUILD:-}" ]; then
        # Everything this function writes to stdout is captured by the caller
        # as the bin directory, so cargo's output has to go to stderr — it
        # still reaches the terminal, and a "Blocking waiting for file lock"
        # is still visible, without being spliced into the path.
        (cd "$repo" && cargo build >&2) || {
          echo "ERROR: $producer failed to build at $repo" >&2
          return 1
        }
      fi
      # With SKIP_PRODUCER_BUILD there is no build to produce them, so check
      # the binaries are actually there. Prepending an empty target/debug
      # would fall through to whatever is on PATH and quietly run a source
      # nobody selected.
      if ! _all_debug_bins_present "$repo/target/debug" "$bins"; then
        echo "ERROR: $producer has no built binaries at $repo/target/debug" >&2
        if [ -n "${SKIP_PRODUCER_BUILD:-}" ]; then
          echo "       SKIP_PRODUCER_BUILD is set, so nothing built them. Run" >&2
          echo "       \`cargo build\` in $repo, or unset SKIP_PRODUCER_BUILD." >&2
        fi
        return 1
      fi
      _abs_dir "$repo/target/debug"
      ;;

    git|git:*)
      rev="${spec#git}"; rev="${rev#:}"
      key="$(_cache_key "$spec")"
      root="$TOOL_CACHE/$producer/$key"
      # A bare ref with no default is the repo's default branch, except for
      # the admonish fork, where the branch IS the point.
      [ -n "$rev" ] || rev="$(_default_git_ref_for "$producer")"
      if ! _all_bins_present "$root" "$bins"; then
        local ref_args=()
        [ -n "$rev" ] && ref_args=("$(_git_ref_flag "$rev")" "$rev")
        # shellcheck disable=SC2086
        cargo install --git "$git_url" ${ref_args[@]+"${ref_args[@]}"} \
          --locked --force --root "$root" $bins >&2 || {
          echo "ERROR: cargo install of $producer from $git_url${rev:+ at $rev} failed" >&2
          return 1
        }
      fi
      _abs_dir "$root/bin"
      ;;

    crates|crates:*)
      if [ -z "$crate" ]; then
        echo "ERROR: $producer is not published to crates.io, so '$spec' cannot work." >&2
        echo "       Use git[:<ref>] or sibling instead." >&2
        return 1
      fi
      version="${spec#crates}"; version="${version#:}"
      key="$(_cache_key "$spec")"
      root="$TOOL_CACHE/$producer/$key"
      if ! _all_bins_present "$root" "$bins"; then
        local ver_args=()
        [ -n "$version" ] && ver_args=(--version "$version")
        # shellcheck disable=SC2086
        cargo install "$crate" ${ver_args[@]+"${ver_args[@]}"} \
          --locked --force --root "$root" >&2 || {
          echo "ERROR: cargo install of $crate from crates.io failed" >&2
          return 1
        }
        # panschema publishes the library and CLI but NOT mdbook-panschema,
        # which the book's schema-link assets need. Take it from the git tag
        # matching the version just installed, so both halves are the same
        # code rather than a crates/git mix.
        if [ "$producer" = "panschema" ]; then
          local resolved="$version"
          [ -n "$resolved" ] || resolved="$(_latest_crate_version "$crate")" || {
            echo "ERROR: could not resolve the latest $crate version to pair mdbook-panschema with" >&2
            return 1
          }
          cargo install --git "$git_url" --tag "v$resolved" \
            --locked --force --root "$root" mdbook-panschema >&2 || {
            echo "ERROR: mdbook-panschema is not on crates.io and the matching tag v$resolved could not be installed." >&2
            echo "       Use PANSCHEMA_SOURCE=git or sibling instead." >&2
            return 1
          }
        fi
      fi
      _abs_dir "$root/bin"
      ;;

    *)
      echo "ERROR: unknown source '$spec' for $producer." >&2
      echo "       Expected: path | sibling | git[:<rev>] | crates[:<version>]" >&2
      return 1
      ;;
  esac
}

_all_bins_present() {
  local root="$1" bins="$2" b
  for b in $bins; do
    [ -x "$root/bin/$b" ] || return 1
  done
  return 0
}

# Same check against a cargo target/debug directory, which has no bin/ level.
_all_debug_bins_present() {
  local dir="$1" bins="$2" b
  for b in $bins; do
    [ -x "$dir/$b" ] || return 1
  done
  return 0
}

# One line per producer naming where its binary came from and what version it
# reports. The stale-alias case (a debug binary built weeks ago from a repo
# that has moved on) is invisible without this.
report_tool_versions() {
  local producer spec ver
  # PATH changed since this shell started; drop bash's remembered lookups so
  # the report names the binary the build will actually run.
  hash -r 2>/dev/null || true
  for producer in $TOOL_PRODUCERS; do
    spec="$(tool_source_for "$producer")"
    ver="$(command "$producer" --version 2>/dev/null | head -1)"
    printf '  %-16s %-18s %s\n' "$producer" "$spec" "${ver:-(not found)}"
  done
}
