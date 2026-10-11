#!/usr/bin/env bash
# scripts/check-line-width.sh
#
# Fail if any *content* line in the schema exceeds the 72-column budget
# (see .yamllint). Long `description:` values must be folded with a `>-`
# block scalar.
#
# Why a budget at all, now that book/soft-wrap.css wraps long listing lines
# instead of scrolling them: soft-wrapped YAML reads worse than soft-wrapped
# code. Indentation carries the meaning, and a wrapped continuation has no
# indent marker, so a long `description:` can wrap into something that scans
# as a new key. GitHub's code view does not wrap at all. Those argue against
# long lines, not for 72 in particular; 72 is the budget the schema was
# written to.
#
# Width is counted in characters, not bytes: an em-dash is one column on
# screen and three bytes in UTF-8, and a byte count fails lines that fit.
#
# `# CALLOUT:` marker comments are exempt: mdbook-listings strips them from
# the rendered listing (their text moves to a hover popover), so they never
# appear in the book. yamllint's line-length rule can't exclude them, which
# is why .yamllint keeps line-length at `level: warning` (editor/manual
# lens) and the blocking check lives here.
#
# Usage: scripts/check-line-width.sh [file ...]   (defaults to the schema)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# Default target: the schema named as [files].main in the publish manifest,
# so this survives the eject and rename without a hardcoded path going stale.
files=("${@:-$(scripts/schema-path.sh)}")

# perl -CSD decodes input as UTF-8, so length() counts characters.
perl -CSD -ne '
  chomp;
  next if /# CALLOUT:/;
  if (length > 72) {
    printf "%s:%d: %d cols (>72)\n", $ARGV, $., length;
    $flag = 1;
  }
} continue {
  close ARGV if eof;    # reset $. per file, skipped lines included
} END {
  exit $flag
' "${files[@]}"
