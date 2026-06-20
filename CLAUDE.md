# myschema

> **This is a template.** After cloning, rename `myschema` to your
> schema's name everywhere (see README "Use this template / SETUP"),
> then fill in the domain purpose below.

A [LinkML](https://linkml.io) ontology grounded in BFO 2020 (ISO/IEC
21838-2:2020) and the Common Core Ontologies (CCO), authored following
*Ontology Development 101* (Noy & McGuinness, 2001 — "N&M") adapted to
LinkML.

The repo is two things at once:

- **`schema/myschema.yaml`** — the schema artifact itself.
- **`book/`** — *Building myschema*, an mdbook that is the public log of
  building the schema from scratch, following N&M adapted to LinkML.
  Each N&M step gets a chapter; the schema grows incrementally with
  **frozen listings** embedded at each stage.

<!-- TEMPLATE: replace with this ontology's specific domain/purpose, and
     record the version history once releases exist. The schema starts at
     `version: 0.1.0-dev`. Prior releases (once cut) are reachable via
     their git tags. -->

## Chapter ↔ N&M step

Chapters map to the seven N&M steps and live at
`book/src/chNN-<kebab-title>.md`, listed in `book/src/SUMMARY.md`:

1. Determine domain and scope · 2. Reuse existing ontologies ·
3. Enumerate important terms · 4. Define classes and hierarchy ·
5. Define slots · 6. Facets (`slot_usage`) · 7. Instances + validate

(ch01 is the Introduction; the seven steps start at ch02.) Match the
existing voice: design discussion aimed at a reader comfortable with
LinkML and ontology basics, N&M quotes in `admonish quote` blocks,
external claims backed by citations.

## Authoring with mdbook-listings

This repo uses the **mdbook-listings** plugin, installed at project
scope (see `.claude/settings.json`). Its bundled skill documents the
full mechanics — `freeze`/`list`, the `{{#include}}` / `{{#callout}}`
/ `{{#diff}}` directives, inline `# CALLOUT:` markers vs. sidecar
TOML, and the tag/SHA-256 identity model. **Consult that skill
(`references/cli.md`, `references/directives.md`) for how the tool
works** — this section records only what's specific to *this* repo.

The book embeds **frozen snapshots** of `schema/myschema.yaml` so a
later edit can't silently change what a chapter renders. Repo
conventions on top of the plugin:

- **Freeze from `book/`**, source `../schema/myschema.yaml`, tag
  `myschema-yaml-v<N>`. Each chapter that advances the schema bumps
  the tag so earlier chapters keep pointing at the snapshot they
  froze:
  `cd book && mdbook-listings freeze ../schema/myschema.yaml --tag myschema-yaml-v2 --force`
- **Callouts on files we author here** (e.g. `schema/myschema.yaml`)
  go *inline* as `# CALLOUT:` markers — never sidecar TOML, which is
  reserved for generated/third-party/no-comment-syntax listings.
- **Integrity check:** `mdbook build` exiting 0 already fails on a
  missing `{{#callout}}` label or a broken `{{#include}}`
  (`mdbook-listings verify` is still a stub).

### Dev loop (`scripts/dev.sh`) and the freeze foot-gun

`scripts/dev.sh` watches `schema/`, `book/src/`, and `book/*.toml`
and rebuilds the combined `site/` on change (via `scripts/rebuild.sh`,
which also runs `mdbook-listings install` to refresh callout CSS/JS).
But **editing `schema/myschema.yaml` does not re-freeze the listing**
— a frozen listing is a point-in-time snapshot by design. The watcher
will rebuild from the *old* frozen bytes, so callout/listing changes
won't appear until you re-freeze. The loop:

1. Edit `schema/myschema.yaml` (markers and all).
2. `cd book && mdbook-listings freeze ../schema/myschema.yaml --tag <tag> --force`
   (writing `book/src/listings/<tag>.yaml` — itself watched — triggers the rebuild).
3. Hard-refresh the browser (Cmd+Shift+R) to bust cached CSS/JS/HTML.

If callouts seem missing, suspect a **stale `site/`** first: confirm
the freshly built `book/build/<chapter>.html` has `callout-badge`
elements before debugging anything deeper.

For anything not covered above, defer to the installed mdbook-listings
plugin skill, then `mdbook-listings <cmd> --help`.

## Building

```
cd book && mdbook serve   # local preview with live reload
cd book && mdbook build   # output to book/build/
```

Preprocessors must be on `PATH`: `mdbook-listings`, and the
`mdbook-admonish` fork (`feat/mdbook-0.5-compat`). The published docs
site (schema HTML + the book) is built and deployed by
`.github/workflows/docs.yml` via the panschema toolchain on push to
`main` and on `v*` tags.

## Conventions

- **Trunk-based on `main`.** Commit directly to `main`; don't propose
  feature branches as a workflow.
- **Schema edits are chapter-scoped.** When a chapter advances the
  schema, freeze a new listing tag in the same change so the prose and
  the snapshot stay consistent.
- **Demand-driven dogfood.** The schema grows because the worked
  example (Appendix A) needs it, not speculatively. The worked example
  should drive the build from Step 1 — if a class or slot only earns
  its keep at validation (Step 7), that is a smell.
- **External grounding is by URI, not import.** BFO/CCO/etc. are
  referenced via `class_uri`/`slot_uri` + prefixes (and mapping
  annotations), *not* LinkML `imports:` (which is for other LinkML
  schemas — only `linkml:types` is imported).
- **Deferrals are tracked in the target chapter's scaffold.** When
  prose defers work to a later chapter or N&M step ("deferred to
  Chapter 6", "Step 5 work", "Chapter 8 will revisit"), add a
  matching `[ ]` TODO line in that chapter's `.md` scaffold,
  inside the HTML-comment `CARRIED-IN DEFERRALS` block (every step
  stub ships with one), citing the source chapter/section. Write
  the prose deferral and the scaffold TODO *together* so nothing
  promised is dropped. The HTML comments never render.
  (Within-chapter "next increment" work — not yet deferred to a
  *later* chapter — stays in the buildout plan, not these blocks.)

## Lessons

These are lessons-learned baked into the template; each step-chapter
stub carries the matching one as a LESSON line in its authoring
checklist.

- **Worked example as demand-driver from Step 1.** Pick the worked
  example early and let it pull every class and slot into existence; if
  something only validates at Step 7, that is a smell.
- **Verify the upper-ontology CATEGORY, not just the IRI.** A resolving
  BFO/CCO IRI is not enough — confirm the category fit (e.g. don't
  ground a Quality as an Information Content Entity).
- **Graph viz as island detector.** Build the panschema class graph and
  treat island (disconnected) nodes as bugs to explain or remove.
- **A concern that fights the layer wants a companion ontology.** If a
  concept keeps resisting the foundational grounding, that is a signal
  it belongs in a separate companion ontology, not bolted on here.
- **The book is a chronological log, not a snapshot.** Narrate
  reversals and dead-ends as they happened; do not retro-edit earlier
  chapters to hide a path that was later abandoned.
- **Plain technical prose, not literary.** Keep the book's voice plain
  and technical, em-dash-lean; no purple prose.
- **Speculative forward-references stay in private notes.** Keep
  future-repo names, roadmap, and speculative plans out of the public
  book and commits.
