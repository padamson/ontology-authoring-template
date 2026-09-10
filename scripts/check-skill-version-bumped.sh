#!/usr/bin/env bash
#
# Fail the commit when the shipped skill or the plugin manifest changes
# without a version bump.
#
# The skill reaches consumers through two channels that version differently.
# `/plugin update` gates on plugin.json's version: until it moves, an update
# reports "already at the latest version", so a skill edit reaches nobody.
# The Agent Skills CLI has no version concept and re-pulls, so the
# frontmatter's `metadata.version` is the only version that channel's reader
# can compare. The two have to agree or the channels disagree about what is
# installed.
#
# The version is the skill's own, tied to nothing else in the repo. This repo
# has no crate, but the schema does carry a `version:` — do not pin to it.
# Schema versions are ontology metadata (`owl:versionInfo`), so moving one to
# announce a skill edit would claim a model change that did not happen.
#
# Compares the staged manifest against HEAD's, so it checks what is actually
# being committed.
set -euo pipefail

manifest=.claude-plugin/plugin.json
skill=skills/ontology-authoring-advance-step/SKILL.md

# Initial commit: nothing to compare against.
git rev-parse -q --verify HEAD >/dev/null 2>&1 || exit 0

# Empty input is expected, not an error: on the commit that first adds the
# manifest, `git show HEAD:...` yields nothing. Report no version and let the
# old/new comparison below decide.
read_manifest_version() {
  python3 -c '
import json, sys
raw = sys.stdin.read().strip()
if not raw:
    print("")
else:
    try:
        print(json.load(__import__("io").StringIO(raw)).get("version", ""))
    except (ValueError, AttributeError):
        print("")
'
}

old=$(git show "HEAD:$manifest" 2>/dev/null | read_manifest_version || echo "")
new=$(git show ":$manifest" 2>/dev/null | read_manifest_version || echo "")

if [ -z "$new" ]; then
  echo "skill version guard: $manifest has no version field." >&2
  echo "Add one -- it is the update gate for installed consumers." >&2
  exit 1
fi
if [ "$old" = "$new" ]; then
  echo "skill version guard: skill or plugin content changed but $manifest is still $new." >&2
  echo "Bump the version so installed consumers see the update." >&2
  exit 1
fi

skill_version=$(git show ":$skill" 2>/dev/null | python3 -c '
import re, sys
try:
    import yaml
except ModuleNotFoundError:
    yaml = None
text = sys.stdin.read()
m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
if not m:
    sys.exit("no frontmatter")
front = m.group(1)
if yaml is not None:
    meta = (yaml.safe_load(front) or {}).get("metadata") or {}
    print(str(meta.get("version", "")).strip())
else:
    m = re.search(r"^metadata:\s*\n(?:[ \t]+.*\n)*?[ \t]+version:[ \t]*\"?([^\"\n]+)\"?", front, re.M) \
        or re.search(r"^metadata:\s*\{[^}]*version:[ \t]*\"?([^\",}]+)\"?", front, re.M)
    print(m.group(1).strip() if m else "")
') || {
  echo "skill version guard: could not read frontmatter from $skill." >&2
  exit 1
}

if [ -z "$skill_version" ]; then
  echo "skill version guard: $skill has no metadata.version." >&2
  echo "Add one matching $manifest ($new) -- it is the only version a" >&2
  echo "consumer installing outside /plugin can see." >&2
  exit 1
fi
if [ "$skill_version" != "$new" ]; then
  echo "skill version guard: $manifest is $new but $skill says $skill_version." >&2
  echo "Move them together." >&2
  exit 1
fi
