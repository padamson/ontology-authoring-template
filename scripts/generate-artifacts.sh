#!/usr/bin/env bash
# Generate the machine-readable artifacts from the wine schema — the formats
# the book mentions ("Other formats") but the publish/build path never
# produces. Output lands under site/artifacts/ (gitignored, deployed with
# the site). panschema must be on PATH.
#
# Own-schema note: these are explicit `generate --schema` calls, NOT a
# panschema.toml manifest. The manifest's [generate.<name>] fan-out resolves
# a schema through a [schemas.<name>] *dependency* (a github:/path: package),
# which a repo can't use to reference its own local schema — so a repo emits
# its own non-HTML formats with explicit commands (HTML comes from
# `panschema publish`). Postgres is deliberately omitted: wine's nine
# multivalued attributes make its writer skip most classes.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

SCHEMA="schema/wine.yaml"
DATA="data/wine-instances.yaml"
OUT="site/artifacts"
mkdir -p "$OUT"

# `--strict` turns panschema's warnings into a non-zero exit, so a bad schema
# or A-box fails CI here. Note it is narrower than its name: it fails on
# unmodeled constructs, dangling references, and (with --instances)
# instance-data violations — but NOT on unprojected-construct, Postgres-skip,
# or SHACL-skip warnings. A green run means "no hard errors," not "perfect."

# Schema-only (T-box): SHACL shapes + the JSON Schema (LLM structured-output
# / instance-validation contract).
panschema generate --strict --schema "$SCHEMA" --format shacl       --output "$OUT/wine-shapes.ttl"
panschema generate --strict --schema "$SCHEMA" --format json-schema --output "$OUT/wine.schema.json"

# Carrying the A-box: a self-contained knowledge graph (schema + data) and
# the traversal-map graph JSON.
panschema generate --strict --schema "$SCHEMA" --format ttl \
  --instances "$DATA" --output "$OUT/wine.ttl"
panschema generate --strict --schema "$SCHEMA" --format instance-graph-json \
  --instances "$DATA" --output "$OUT/wine-instances.graph.json"

echo "Generated artifacts in $OUT/:"
ls -1 "$OUT"
