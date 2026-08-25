---
name: setup-ontology
description: Bootstrap a freshly-cloned copy of the ontology-authoring-template — rename the `myschema` placeholder to a real schema name everywhere (schema file, prefixes, w3id namespace, freeze-tag convention, configs, book, scripts), set the schema id/namespace, fill in the domain purpose, and strip the template-bootstrap scaffolding. Use right after cloning / "Use this template", or when the user says "rename myschema", "set up the template", "initialize this ontology", or "do the SETUP steps".
---

# Setup a new ontology from the template

One-time bootstrap that turns the `myschema` placeholder into a real
schema. Run it once, right after **erect-scaffold** has raised the blank
baseline (a consumer starting their own ontology ejects the wine showcase
first; on a repo that is already blank `myschema`, run this directly).
README "Start your own" frames the whole flow; this skill executes the
rename with the judgment a blind find-replace can't.

## When NOT to run

If the repo is already renamed (no `schema/myschema.yaml`, and
`grep -rIl myschema` returns only historical book prose), the bootstrap
is done — don't re-run it. Say so instead.

## Step 0 — get the name

Ask the user for the schema name unless it's already given. Validate it:

- matches `^[a-z][a-z0-9_]*$` (lowercase, starts with a letter) — it has
  to be valid as a LinkML `name`, a CURIE prefix, and a filename stem
- is not `myschema`

Also confirm the **w3id namespace** (default `https://w3id.org/<name>/`)
and grab a **one-sentence domain purpose** for CLAUDE.md / the
Introduction (`introduction.md`). If the
user only gives a name, proceed with the default namespace and leave the
purpose as a clearly-marked TODO rather than inventing a domain.

## Step 1 — survey before touching anything

```bash
grep -rIl 'myschema' . \
  --exclude-dir=.git --exclude-dir=build --exclude-dir=site --exclude-dir=.claude
```

Confirm the surface matches what's below. If extra files show up, fold
them in — don't silently skip them.

**Never rename inside `.claude/`** — these skill files *document*
`myschema` as the placeholder name; rewriting them would corrupt the
skills (including this one). That's why every command here excludes
`.claude`.

## Step 2 — rename the schema file

```bash
git mv schema/myschema.yaml schema/<name>.yaml
```

## Step 3 — the global identifier rename

Every remaining `myschema` token maps to `<name>` — the prefix, the
`default_prefix`, the `name:`, the `https://w3id.org/myschema/`
namespace, the `myschema-yaml-vN` freeze-tag convention, and every
path/comment reference across configs, scripts, and the book. The
mechanical files (do a straight replace):

- `schema/<name>.yaml` — `id:`, `name:`, the `<name>:` prefix line,
  `default_prefix:` (set `id:` to the confirmed namespace)
- `panschema-publish.toml` — `[schema].name`, `[files].main`
- `panschema.toml` — the `[schemas.<name>]` / `[generate.<name>]` table
  names and the `site/artifacts/<name>-*` output paths
- `book/book.toml` — `title` ("Building <name>") and `description`. The
  stock description carries a `myschema` token so the blind replace
  catches it, but it's otherwise generic — offer to refine it into a
  schema-specific sentence (it's a judgment item, not just a rename).
- `book/listings.toml` — the example freeze command + tag

The **infrastructure needs no rename**: CI, the pre-commit hooks,
`scripts/`, and `.yamllint` read the schema path from
`panschema-publish.toml` (`[files].main`, via `scripts/schema-path.sh`) and
match the schema file with a name-agnostic `schema/*.yaml` glob, so the
`[files].main` rename above carries them.

A repo-wide `myschema` → `<name>` replace handles these correctly. **But
do not blindly run it everywhere** — Steps 4 and 5 cover the files where
a blind replace produces nonsense.

## Step 4 — README & CLAUDE.md: rewrite, don't find-replace

These contain `myschema` *inside template-bootstrap instructions*. A
find-replace would leave self-referential nonsense like "rename `<name>`
to your schema's name". Instead:

- **README.md** — remove the "Use this template / SETUP" section and the
  "placeholder schema name … Rename it" callout; rename the remaining
  identifier/path references (`schema/myschema.yaml`, the freeze tag) to
  `<name>`. The README should now describe *this* ontology, not the
  template.
- **CLAUDE.md** — delete the top "> **This is a template.** …" blockquote
  and replace the `# myschema` heading with `# <name>`; rename the
  identifier/path references in the body; fill the domain purpose with
  the user's one-sentence answer (or a marked TODO).

## Step 5 — the book chapters

`book/src/introduction.md` and the step stubs reference `myschema`
in prose. Rename the identifier to `<name>`. These are mostly safe
replaces, but `introduction.md` is the Introduction the author still has
to write — don't fabricate content, just fix the name.

## Step 6 — verify

```bash
grep -rIn 'myschema' . \
  --exclude-dir=.git --exclude-dir=build --exclude-dir=site --exclude-dir=.claude
# fresh clones need the gitignored CSS/JS generated once, or mdbook build
# fails on a missing mdbook-admonish.css (see README "Fresh clone"):
./scripts/install-assets.sh
cd book && mdbook build      # must exit 0
```

The grep should return nothing (or only an intentional historical
mention you can point to). `.claude/` is excluded on purpose (the skill
docs keep saying `myschema`). Report any stragglers rather than
declaring done.

## Step 7 — hand off

Don't commit unless asked (trunk-based on `main` — see CLAUDE.md). Tell
the user what changed and what's left to them: writing the Introduction
(`introduction.md`), setting the schema `version:`, and starting Step 1 —
which is the
[[ontology-authoring-advance-step]] skill's job.

## Step 8 — remove the bootstrap tooling (self-clean)

This skill is one-time bootstrap tooling. Once the rename is verified and
handed off, it's dead weight in the instance — pure template scaffolding
that still says `myschema` throughout (correct for the *template*, stale
and confusing inside an instantiated repo). Make the instance born clean
by removing it as the **final** action:

1. **Confirm first** — this is an irreversible cleanup of checked-in
   files. Ask: "Bootstrap done — remove the template's bootstrap
   tooling from this repo? The per-chapter authoring skill is installed
   from the template instead of carried, so it stays available." If the
   user declines, stop here and leave everything in place.

2. **Drop the carried copy of the authoring skill and install it
   instead.** The clone arrived with `skills/` and a symlink to it, but
   a copy is a fork the moment either side is edited — which is how
   five instances of this template ended up with five different
   versions. Take it from the template as a tracked install:

   ```bash
   git rm -r skills/ .claude/skills/ontology-authoring-advance-step
   npx skills add padamson/ontology-authoring-template
   ```

   Re-run that `npx` command to pick up later improvements. If the user
   prefers to keep and adapt a local copy, that is a legitimate choice —
   record it in the repo's CLAUDE.md so the fork is deliberate rather
   than discovered later.

3. **Remove this skill** (the last action — its instructions are already
   loaded, so deleting the files mid-run is fine):

   ```bash
   git rm -r .claude/skills/setup-ontology/
   ```

The bootstrapped instance then carries no template tooling of its own,
which is the point: its authoring skill tracks the template rather than
drifting from it. The deletions are staged, not committed; commit only
if the user asks.

## Boundaries

- Tool mechanics (freezing, directives) → the **mdbook-listings** skill.
- Standing conventions (grounding-by-URI, voice, lessons) → **CLAUDE.md**.
- The per-step authoring loop → the **ontology-authoring-advance-step**
  skill (installed from the template, not carried).
