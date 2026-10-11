#!/usr/bin/env bash
# scripts/build-book.sh
#
# Build the book, and fail if mdbook logs an ERROR.
#
# The listings preprocessor fails the build on a directive it handles (an
# unfrozen listing, a missing callout label). An {{#include}} it leaves
# alone falls through to mdbook's own handling, which logs an ERROR when
# the file is missing and still exits 0. One inside an HTML comment is
# the live case: mdbook expands includes in raw markdown, comments and
# backticks included, and `mdbook-listings verify` skips it too. So the
# gate reads the log, not just the exit status.
#
# Usage: scripts/build-book.sh [mdbook build args ...]

set -euo pipefail
cd "$(dirname "$0")/../book"

# One pass streams the log to stderr and watches it for ERROR as a word,
# with color codes stripped first. Under pipefail a failing mdbook still
# fails the script with mdbook's own status.
mdbook build "$@" 2>&1 | awk '
  { print; fflush() }
  { line = $0; gsub(/\033\[[0-9;]*m/, "", line) }
  line ~ /(^|[^[:alpha:]])ERROR([^[:alpha:]]|$)/ { err = 1 }
  END {
    if (err) print "build-book: mdbook logged an ERROR above; failing the build"
    exit err
  }
' >&2
