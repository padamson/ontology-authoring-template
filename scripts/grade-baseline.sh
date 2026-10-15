#!/usr/bin/env bash
# scripts/grade-baseline.sh
#
# Grade cqa-grader's naive baseline against this package's competency-
# question benchmark, over the Turtle `panschema generate` wrote. CI runs
# it right after generating; run it the same way locally with `cqa-grader`
# on PATH (`cargo install --git https://github.com/padamson/cqa-grader
# --locked cqa-grader`; there is no crates.io release yet).
#
# What it proves: every record a correct answer needs can be reached in
# the published graph by a retriever with no thesis, so the benchmark is
# answerable and not just well-formed. The baseline never says "none on
# record", so a closed-world negative ends unanswered; `--require
# no-wrong-answers` tolerates that and still fails a wrong answer or a
# question not attempted.
#
# Inert before Step 7. The benchmark is held against the graph once
# `[check.cqa]` is on in panschema.toml, and that is also when a worked
# example exists for the baseline to read, so the same switch turns this
# on. Until then it exits 0 with a notice. `--enabled` answers only that
# question (exit 0 on, 1 off, nothing graded), which is how CI decides
# whether to build the grader at all.
#
# Nothing here names the schema: the name and version come from
# panschema-publish.toml, the worked example's dataset label from its
# [[instances]] entry, and the Turtle paths from panschema.toml, so the
# script survives the eject and the rename the way schema-path.sh does.
# The version is `[schema] version`, the field panschema's own pin check
# holds the benchmark's `target_dataset_version` against, so the two
# gates agree on which release the graph is (the schema file's `version:`
# runs ahead of it between releases, with a `-dev` suffix, and is synced
# at `panschema release`). The worked example ships with the schema under
# one tag, so that version is the dataset's too. Grading exits 2 when it
# is not the release the benchmark pins; panschema's check fails the same
# drift first.
#
# Usage: scripts/grade-baseline.sh [--enabled]
# Exit 0 when the baseline meets the requirement, 1 when it does not, 2
# when the inputs are unusable (the grader's own convention).

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

enabled() { grep -q '^\[check\.cqa\]' panschema.toml; }

case "${1:-}" in
  --enabled) if enabled; then exit 0; else exit 1; fi ;;
  "") ;;
  *) echo "usage: scripts/grade-baseline.sh [--enabled]" >&2; exit 2 ;;
esac

if ! enabled; then
  echo "grade-baseline: [check.cqa] is not on in panschema.toml (Step 7 work), so nothing is graded yet."
  exit 0
fi

die() { echo "grade-baseline: $*" >&2; exit 2; }

command -v cqa-grader >/dev/null || die "cqa-grader is not on PATH"

# The first quoted string on the `key = ...` line of the TOML table
# `[table]`, so an array value yields its first element. Enough for these
# two manifests, which keep one key per line; a header may carry trailing
# whitespace or a comment.
toml_value() {
  awk -F'"' -v table="[$1]" -v key="$2" '
    /^\[/ { h = $0; sub(/[ \t]*(#.*)?$/, "", h); in_table = (h == table) }
    in_table && $0 ~ ("^" key "[ =]") { print $2; exit }
  ' "$3"
}

# The `name` of the [[instances]] entry in panschema-publish.toml whose
# `data` is the given file: the dataset label the benchmark's
# target_dataset names. Any header ends the entry.
dataset_name() {
  awk -F'"' -v want="$1" '
    /^\[/ { if (hit) exit; name = "" }
    /^name[ =]/ { name = $2 }
    /^data[ =]/ { hit = ($2 == want) }
    END { if (hit) print name }
  ' panschema-publish.toml
}

name=$(toml_value schema name panschema-publish.toml)
[ -n "$name" ] || die "no name under [schema] in panschema-publish.toml"
version=$(toml_value schema version panschema-publish.toml)
[ -n "$version" ] || die "no version under [schema] in panschema-publish.toml"
graph=$(toml_value "generate.$name" ttl panschema.toml)
[ -n "$graph" ] || die "no ttl under [generate.$name] in panschema.toml"
abox=$(toml_value "generate.$name" instances panschema.toml)
[ -n "$abox" ] || die "no instances under [generate.$name] in panschema.toml, so there is no graph to grade"
benchmark=$(toml_value generate.cqa ttl panschema.toml)
[ -n "$benchmark" ] || die "no ttl under [generate.cqa] in panschema.toml"
dataset=$(dataset_name "$abox")
[ -n "$dataset" ] || die "no [[instances]] entry in panschema-publish.toml has data = \"$abox\""
for f in "$graph" "$benchmark"; do
  [ -f "$f" ] || die "$f is missing; run \`panschema generate\` first"
done

# An explicit template: without one, macOS mktemp ignores TMPDIR.
out=$(mktemp -d "${TMPDIR:-/tmp}/grade-baseline.XXXXXX")
trap 'rm -rf "$out"' EXIT

echo "grade-baseline: $name $version, dataset $dataset, graph $graph, benchmark $benchmark"
cqa-grader baseline --graph "$graph" \
  --dataset "$dataset" --dataset-version "$version" \
  --benchmark "$benchmark" --output "$out/trace.json"
cqa-grader grade --benchmark "$benchmark" --trace "$out/trace.json" \
  --require no-wrong-answers || {
  status=$?
  # A failed grade (exit 1): the table above names the question, and the
  # trace says what the baseline retrieved for it, which is where a fix
  # starts. A usage error (exit 2) has already said what is wrong.
  if [ "$status" -eq 1 ]; then
    echo "grade-baseline: the baseline's trace follows" >&2
    cat "$out/trace.json" >&2
  fi
  exit "$status"
}
