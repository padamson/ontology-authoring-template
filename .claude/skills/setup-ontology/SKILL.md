---
name: setup-ontology
description: Bootstrap a freshly-cloned copy of the ontology-authoring-template — rename the `myschema` placeholder to a real schema name everywhere (schema file, prefixes, w3id namespace, freeze-tag convention, configs, book, scripts), set the schema id/namespace, fill in the domain purpose, and strip the template-bootstrap scaffolding. Use right after cloning / "Use this template", or when the user says "rename myschema", "set up the template", "initialize this ontology", or "do the SETUP steps".
metadata:
  internal: true
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

Finally, ask for the **licence for their ontology**. `schema/<name>.yaml`
ships `license: TODO`, and that field travels with the artifact and into
the generated RDF, so it is a claim about the user's work — never one to
guess or to inherit from the template. Offer the usual three and say what
each means in a clause: **CC BY 4.0** (published vocabulary, attribution
required), **Apache-2.0** (permissive, patent grant, the usual pick when
code is generated from the schema), **CC0** (public domain, no conditions).
Write the choice as a URL, matching the shape the field already expects
(e.g. `https://creativecommons.org/licenses/by/4.0/`), delete the
instructional comment above `license:`, and add a matching `LICENSE`
file plus a README line. The two Creative Commons legal texts ship with
this skill, because the sandbox allows network access to `localhost` only
and erect-scaffold has just deleted the one copy in the tree:

```bash
cp .claude/skills/setup-ontology/licenses/cc-by-4.0.txt LICENSE   # CC BY 4.0
cp .claude/skills/setup-ontology/licenses/cc0-1.0.txt LICENSE     # CC0
```

For Apache-2.0, `LICENSE-APACHE` already holds the text, so point the
README line at it rather than adding a second copy. For any other licence,
ask the user to put its text in `LICENSE` from their terminal.

If the user declines to decide, leave
`TODO` and say so in the hand-off — an unlicensed schema is a real gap,
not a cosmetic one. Say too that CI stays red until it is set:
`panschema generate --strict` refuses `TODO` as `Invalid IRI 'TODO'`.

Note the repo already carries `LICENSE-APACHE`. That covers the scaffold
this instance was built from and stays regardless; it is not a statement
about the user's ontology, and their choice above does not replace it.

## Step 1 — survey before touching anything

```bash
grep -rIl 'myschema' . \
  --exclude-dir=.git --exclude-dir=build --exclude-dir=site \
  --exclude-dir=.claude --exclude-dir=skills
```

Confirm the surface matches what's below. If extra files show up, fold
them in — don't silently skip them.

**Never rename inside `.claude/` or `skills/`** — these skill files
*document* `myschema` as the placeholder name; rewriting them would
corrupt the skills (including this one). That's why every command here
excludes both. (`skills/` is the carried copy of the authoring skill,
which Step 8 drops anyway.)

## Step 2 — rename the schema file

```bash
git mv schema/myschema.yaml schema/<name>.yaml
git mv data/myschema-benchmark.yaml data/<name>-benchmark.yaml
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
  names, the `site/artifacts/<name>-*` output paths, the
  `data/<name>-benchmark.yaml` instances path under `[generate.cqa]`,
  and `resolve_against = ["<name>"]` in the commented `[check.cqa]`
  block (the `[schemas.cqa]` entry itself is not renamed: it names the
  dependency)
- `data/<name>-benchmark.yaml` — the benchmark's `id:`/`name:`, the
  `https://w3id.org/myschema/` target namespace (set it to the confirmed
  namespace, matching the schema's `id:`)
- `panschema-publish.toml` — the `[[instances]]` benchmark `data` path
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

A straight `myschema` → `<name>` replace handles these correctly. Run it
over the files listed here, **never repo-wide**: a token elsewhere may be
documenting the placeholder, and renaming it makes the documentation
false. Steps 4 and 5 cover the files where a blind replace produces
nonsense.

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
  --exclude-dir=.git --exclude-dir=build --exclude-dir=site \
  --exclude-dir=.claude --exclude-dir=skills
# fresh clones need the gitignored CSS/JS generated once, or mdbook build
# fails on a missing mdbook-admonish.css (see README "Fresh clone"):
./scripts/install-assets.sh
./scripts/build-book.sh      # must exit 0
```

`build-book.sh` rather than a bare `mdbook build`, which can exit 0 on a
broken book (the script's header says when).

The grep should return nothing (or only an intentional historical
mention you can point to). `.claude/` and `skills/` are excluded on
purpose (the skill docs keep saying `myschema`). Report any stragglers
rather than declaring done.

Then check the two placeholders the rename does not touch:

```bash
grep -n 'license: TODO' schema/*.yaml
grep -n 'TODO (Step 1)' schema/*.yaml
```

A `license: TODO` left standing means Step 0's licence question went
unanswered — say so in the hand-off. The description TODO is Step 1's work
and is expected to survive setup.

## Step 7 — hand off

Don't commit unless asked (trunk-based on `main` — see CLAUDE.md). Tell
the user what changed and what's left to them: writing the Introduction
(`introduction.md`), setting the schema `version:`, and starting Step 1 —
which is the
[[ontology-authoring-advance-step]] skill's job.

Before the first push, a public repo needs GitHub Pages enabled with
GitHub Actions as its source, or the docs workflow's deploy job fails with
`HttpError: Not Found`. (A private repo skips the deploy, so there is
nothing to enable.) Offer to enable it:

```bash
gh api -X POST "repos/{owner}/{repo}/pages" -f build_type=workflow
```

`gh` fills `{owner}/{repo}` from the clone's remote and runs outside the
sandbox. It changes the repo's settings on GitHub, so ask before running
it. A `409` means Pages is already enabled. The user can do the same from
Settings → Pages → Source: "GitHub Actions".

## Step 8 — remove the bootstrap tooling (self-clean)

This skill is one-time bootstrap tooling. Once the rename is verified and
handed off, it's dead weight in the instance — pure template scaffolding
that still says `myschema` throughout (correct for the *template*, stale
and confusing inside an instantiated repo). Leave the instance's working
tree free of it by removing it as the **final** action. (The history keeps
it, and its removal lands as an ordinary deletion commit.)

1. **Confirm first** — this is an irreversible cleanup of checked-in
   files. Ask: "Bootstrap done — remove the template's bootstrap
   tooling from this repo? The per-chapter authoring skill is installed
   from the template instead of carried, so it stays available." If the
   user declines, stop here and leave everything in place.

2. **Hand the user one block for their terminal.** It drops the carried
   copy of the authoring skill and this skill, and installs the authoring
   skill and the two tool skills this repo consumes. It runs outside the
   session because `npx skills add` downloads and then writes under
   `.claude/skills/`, and the sandbox denies both (the CLI exits 2 having
   installed nothing). The `git rm` goes in the same block so the user
   copies once, and the block runs in a subshell with `set -e`, so a
   failed install stops it without closing the user's terminal:

   ```bash
   (
   set -e
   command -v npx >/dev/null || { echo "npx is not on PATH"; exit 1; }
   git rm -rq skills/ .claude/skills/ontology-authoring-advance-step \
     .claude/skills/setup-ontology
   npx skills add padamson/mdbook-listings -s mdbook-listings -a claude-code -y
   npx skills add padamson/panschema -s panschema-development -a claude-code -y
   npx skills add padamson/ontology-authoring-template \
     -s ontology-authoring-advance-step -a claude-code -y
   git add skills-lock.json
   )
   ```

   If an install fails, the carried copy is already staged for deletion.
   `git restore --source=HEAD --staged --worktree -- skills
   .claude/skills/ontology-authoring-advance-step
   .claude/skills/setup-ontology` puts it back until the install can be
   retried.

   The clone arrived with `skills/` and a symlink to it, but a copy is a
   fork the moment either side is edited, which is how five instances of
   this template ended up with five different versions. Deleting the
   local copy is also what makes the installed version authoritative: a
   project-local skill shadows an installed one of the same name.
   `skills-lock.json` is the pin; the fetched content is gitignored by the
   `.gitignore` **erect-scaffold** promoted. Removing this skill is safe
   mid-run, because its instructions are already loaded. (The template's
   skill-version guard stays behind and passes once `skills/` is gone.)

3. **Verify** once the user says the block ran: list `.claude/skills/`
   (three entries, no `setup-ontology`), read `metadata.version` out of
   each installed `SKILL.md`, and check that `skills-lock.json` is staged.
   Do not trust the CLI's success message; older versions printed
   `✓ Updated N skill(s)` even when the write was denied.

   If the user prefers to keep and adapt a local copy of the authoring
   skill, that is a legitimate choice. Leave it out of the `git rm` and
   the install, and record it in the repo's CLAUDE.md so the fork is
   deliberate rather than discovered later.

The bootstrapped instance then carries no template tooling of its own,
which is the point: its authoring skill tracks the template rather than
drifting from it. The deletions are staged, not committed; commit only
if the user asks.

## Boundaries

- Tool mechanics (freezing, directives) → the **mdbook-listings** skill.
- Standing conventions (grounding-by-URI, voice, lessons) → **CLAUDE.md**.
- The per-step authoring loop → the **ontology-authoring-advance-step**
  skill (installed from the template, not carried).
