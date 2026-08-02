#!/usr/bin/env bash
# Echo the schema file path declared as [files].main in the publish manifest.
#
# Single source of truth for "which schema file" so CI, hooks, and scripts
# never hardcode the filename. This survives both template transitions with
# nothing to update: the eject (schema/wine.yaml -> schema/myschema.yaml, via
# the promoted scaffold manifest) and the setup-ontology rename
# (schema/myschema.yaml -> schema/<name>.yaml).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
sed -nE 's/^main = "([^"]+)".*/\1/p' panschema-publish.toml | head -1
