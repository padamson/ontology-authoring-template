#!/usr/bin/env bash
#
# Report each build tool pinned in docs.yml that crates.io has moved past.
#
# A pin is a `cargo install <crate> --version ${{ env.<VAR> }}` step in
# .github/workflows/docs.yml together with the value of `<VAR>` in that
# file's `env:` block. Reading the install line names the crate directly,
# so any tool installed that way is checked without touching this script.
# Flags such as `--locked` may come before the crate, and the expression
# may be quoted, but the whole command sits on one line. A pin in any other
# form would go stale unreported, so any uncommented line that passes
# `--version` a value and is not in that form (`--version "$X"`,
# `--version=X`, a literal version, a `--version` continued from the line
# above) is unreadable.
# Dependabot cannot read these pins, and bumping one is a judgment call (a
# patch release of mdbook-listings once changed rendered output), so this
# only reports. tool-pins.yml runs it weekly and opens an issue per pin
# that is behind.
#
# Prints one tab-separated line per pin that is behind,
# `<crate>\t<VAR>\t<pinned>\t<latest>`, where latest is the newest stable
# release. A prerelease pin counts as behind once a stable release of the
# same version or later is out.
#
# Exit status: 0 when every pin is current, 1 when one is behind, 2 when a
# pin or a crates.io answer cannot be read. A pin that cannot be read does
# not stop the others from being checked and printed.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
workflow=.github/workflows/docs.yml

# crates.io refuses requests without a User-Agent that identifies the caller.
ua="tool-pin check (${GITHUB_REPOSITORY:-$(basename "$(pwd)")})"

pin='cargo install (--[a-z-]+ )*([A-Za-z0-9_-]+) --version "?\$\{\{ *env\.([A-Za-z0-9_]+) *\}\}"?'
status=0
installs=""
while IFS=: read -r n line; do
  if [[ $line =~ $pin ]]; then
    installs+="${installs:+$'\n'}${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
  else
    echo "unreadable pin at $workflow:$n: $line" >&2
    status=2
  fi
done < <(grep -nE -- '--version[ =]+[^ |&;)]' "$workflow" | sed -nE '/^[0-9]+: *#/d; s/^([0-9]+): */\1:/p')
[ -n "$installs" ] || { echo "no pinned cargo install in $workflow" >&2; exit 2; }

# True when version $1 sorts strictly before version $2.
older() { [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ]; }

while read -r crate var; do
  pinned=$(sed -nE "s/^  $var: *\"?([^\" #]+)\"?.*/\1/p" "$workflow")
  if [ -z "$pinned" ]; then
    echo "$crate: no value for $var in the env: block of $workflow" >&2
    status=2
    continue
  fi
  if ! latest=$(curl -sfS --retry 2 -A "$ua" "https://crates.io/api/v1/crates/$crate" \
                | jq -er '.crate.max_stable_version'); then
    echo "$crate: could not read its latest stable release from crates.io" >&2
    status=2
    continue
  fi
  # Compare by the release a pin leads up to, since sort -V ranks
  # 1.0.0-alpha above 1.0.0: a prerelease pin is behind once its release
  # is out.
  release=${pinned%%-*}
  if [ "$pinned" != "$latest" ] && ! older "$latest" "$release"; then
    printf '%s\t%s\t%s\t%s\n' "$crate" "$var" "$pinned" "$latest"
    [ "$status" -eq 2 ] || status=1
  fi
done <<< "$installs"
exit "$status"
