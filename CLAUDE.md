# wine

> **This repo is the worked showcase for the ontology-authoring-template.**
> It builds a small wine ontology from scratch to demonstrate the method.
> A consumer who wants their own ontology runs the **erect-scaffold** skill,
> which discards this showcase and restores the blank template baseline
> (then **setup-ontology** renames it). See README "Start your own".

A [LinkML](https://linkml.io) ontology grounded in BFO 2020 (ISO/IEC
21838-2:2020) and the Common Core Ontologies (CCO), authored following
*Ontology Development 101* (Noy & McGuinness, 2001 — "N&M") adapted to
LinkML. It models wines, the grapes and regions behind them, and the
pairing and vintage-quality judgments made about them.

The repo is two things at once:

- **`schema/wine.yaml`** — the schema artifact itself.
- **`book/`** — *Building wine*, an mdbook that is the public log of
  building the schema from scratch, following N&M adapted to LinkML.
  Each N&M step gets a chapter; the schema grows incrementally with
  **frozen listings** embedded at each stage.

## Chapter ↔ N&M step

Chapters map to the seven N&M steps and live at
`book/src/chNN-<kebab-title>.md`, listed in `book/src/SUMMARY.md`:

1. Determine domain and scope · 2. Reuse existing ontologies ·
3. Enumerate important terms · 4. Define classes and hierarchy ·
5. Define slots · 6. Facets (`slot_usage`) · 7. Instances + validate

(The Introduction is the unnumbered prefix chapter `introduction.md`;
the seven steps are `ch01`–`ch07`, so the rendered Chapter N is N&M
Step N.) Match the existing voice: design discussion aimed at a reader
comfortable with LinkML and ontology basics, N&M quotes in
`admonish quote` blocks,
external claims backed by citations.

## Authoring with mdbook-listings

This repo consumes the **mdbook-listings** skill as a managed install
(see "Agent skills" below). It documents the full mechanics —
`freeze`/`list`, the `{{#include}}` / `{{#callout}}` / `{{#diff}}`
directives, inline `# CALLOUT:` markers vs. sidecar TOML, the caption
rules, and the tag/SHA-256 identity model. **Consult that skill
(`references/cli.md`, `references/directives.md`,
`references/captions.md`) for how the tool works** — this section records
only what's specific to *this* repo.

The book embeds **frozen snapshots** of `schema/wine.yaml` so a
later edit can't silently change what a chapter renders. Repo
conventions on top of the tool:

- **Freeze from `book/`**, source `../schema/wine.yaml`, tag
  `wine-yaml-v<N>`. Each chapter that advances the schema bumps
  the tag so earlier chapters keep pointing at the snapshot they
  froze:
  `cd book && mdbook-listings freeze ../schema/wine.yaml --tag wine-yaml-v2 --force`
- **Captions never name the artifact.** `show-listing-provenance = true`
  in `book.toml` renders the source path and frozen tag under every
  caption, so a caption that repeats `schema/wine.yaml` or its tag says it twice. A
  caption states what the reader is looking at *and why it is here*, or
  it is omitted — the provenance line already covers what the listing is.
  The full rule set is `references/captions.md` in the mdbook-listings
  skill. Keep the local binary at or past the CI pin: 0.2.0 ignores the
  key silently, so a stale local binary previews without the line CI
  renders with.
- **Callouts on files we author here** (e.g. `schema/wine.yaml`)
  go *inline* as `# CALLOUT:` markers — never sidecar TOML, which is
  reserved for generated/third-party/no-comment-syntax listings.
- **Integrity check:** two gates run. `mdbook-listings verify
  --book-root book` fails on a frozen snapshot whose bytes no longer
  match `listings.toml` (edited but not re-frozen) or a broken
  `{{#include}}` / `{{#callout}}`; it is wired into both the
  `.pre-commit-config.yaml` hook and the `docs.yml` CI (before the
  build). `mdbook build` additionally fails on a missing `{{#callout}}`
  label or an include of an unfrozen listing. One hole is left: an
  `{{#include}}` the listings preprocessor does not handle (one inside
  an HTML comment, say) reaches mdbook's own include handling, which
  logs an `ERROR` and still exits 0. `scripts/build-book.sh`, which CI
  runs, fails on that `ERROR` line; a bare `mdbook build` does not.

### Dev loop (`scripts/dev.sh`) and the freeze foot-gun

`scripts/dev.sh` watches `schema/`, `book/src/`, and `book/*.toml`
and rebuilds the combined `site/` on change (via `scripts/rebuild.sh`,
which also runs `mdbook-listings install` to refresh callout CSS/JS).
But **editing `schema/wine.yaml` does not re-freeze the listing**
— a frozen listing is a point-in-time snapshot by design. The watcher
will rebuild from the *old* frozen bytes, so callout/listing changes
won't appear until you re-freeze. The loop:

1. Edit `schema/wine.yaml` (markers and all).
2. `cd book && mdbook-listings freeze ../schema/wine.yaml --tag <tag> --force`
   (writing `book/src/listings/<tag>.yaml` — itself watched — triggers the rebuild).
3. Hard-refresh the browser (Cmd+Shift+R) to bust cached CSS/JS/HTML.

If callouts seem missing, suspect a **stale `site/`** first: confirm
the freshly built `book/build/<chapter>.html` has `callout-badge`
elements before debugging anything deeper.

For anything not covered above, defer to the installed mdbook-listings
skill, then `mdbook-listings <cmd> --help`.

## Building

```
cd book && mdbook serve   # local preview with live reload
cd book && mdbook build   # output to book/build/
./scripts/build-book.sh   # the CI gate: mdbook build, failing on a logged ERROR
```

Preprocessors must be on `PATH`: `mdbook-listings`, and the
`mdbook-admonish` fork (`feat/mdbook-0.5-compat`); `mdbook-panschema`
(from the panschema workspace) must be there too — it generates the
gitignored book→schema toolbar-link assets that `book.toml` references
(`scripts/install-assets.sh` runs all three installers).

The cqa contract is a pinned dependency: `panschema.toml` names it by
`source = "github:padamson/cqa-schema"` plus `version`, and
`panschema.lock` (committed) records the checksum that pin resolved to.
Run `panschema fetch` once after cloning to populate the local cache
(`~/Library/Caches/dev.padamson.panschema` on macOS, `~/.cache/panschema` on Linux);
manifest-wide `panschema verify`, `generate`, and the pre-commit hook
then run offline. CI runs `panschema fetch --check` instead, which
fails on lockfile drift. Moving to a newer cqa release is one edit to
`version` and a re-run of `panschema fetch`. `mdbook build` does not
need the dependency.

The published
docs site (schema HTML + the book) is built and deployed by
`.github/workflows/docs.yml` via the panschema toolchain on push to
`main`. A tag push builds nothing on its own: every push to `main`
republishes each tag listed in `panschema-publish.toml`'s `versions`, so
push a release tag together with the commit that lists it.

Math is **opt-in** and not shipped in the stock template: to write `$…$`
in chapters, enable `mdbook-katex` (pin `0.10.0-alpha`, ordered
`after = ["admonish"]`) per the README "Math (optional)" section. Once
enabled it becomes a required preprocessor, so also add it to CI.

## Agent skills

Agent skills are pinned dependencies, the same as the cqa contract.
`skills-lock.json` (committed) records each source and a content hash;
`npx skills add` fetches the content. Run the installs once after cloning:

```bash
npx skills add padamson/mdbook-listings -s mdbook-listings -a claude-code -y
npx skills add padamson/panschema -s panschema-development -a claude-code -y
```

This repo is also a skill *producer*: `ontology-authoring-advance-step`
lives in `skills/` and is reached through a tracked symlink in
`.claude/skills/`, so it is never installed here. Nor are `erect-scaffold`
and `setup-ontology`, which are bootstrap-only and marked
`metadata.internal: true` so the CLI does not offer them.

**Run installs and refreshes from a plain terminal, never from inside a
Claude Code session.** The sandbox denies writes under `.claude/skills/`;
the CLI exits 2 on `EPERM: mkdir .claude/skills` having installed nothing
— no content, no lock entry. Older versions failed *silently* and still
printed `✓ Updated N skill(s)`, so treat the success message as no
evidence either way.

Refresh with `npx skills update -p`. Bare `npx skills update` prompts and
defaults to **Global** scope — choose **Project**. Verify by listing
`.claude/skills/` and reading `metadata.version` out of an installed
`SKILL.md`; that field is the only version an installed copy carries.

With `-a claude-code` the CLI writes a real directory per skill under
`.claude/skills/<name>/` and no `.agents/` hub, so the check is that the
*entry* exists, not that a symlink resolves. `.gitignore` names the fetched
skills one at a time rather than ignoring the directory, because most of
`.claude/skills/` here is tracked on purpose.

The Claude Code plugin channel is **not** used for ecosystem skills, and
this repo carries no `enabledPlugins` for them. Two channels on the same
`main` went stale in opposite directions; `.claude/skills/README.md` records
why.

## Conventions

- **Trunk-based on `main`.** Commit directly to `main`; don't propose
  feature branches as a workflow.
- **Schema edits are chapter-scoped.** When a chapter advances the
  schema, freeze a new listing tag in the same change so the prose and
  the snapshot stay consistent.
- **Demand-driven dogfood.** The schema grows because the worked
  example (Appendix A) needs it, not speculatively. The worked example
  should drive the build from Step 1 — if a class or slot only earns
  its keep once instances are built (Step 7), that is a smell.
- **External grounding is by URI, not import.** BFO/CCO/etc. are
  referenced via `subclass_of` + prefixes, *not* LinkML `imports:`
  (which is for other LinkML schemas — only `linkml:types` is
  imported). (`class_uri` asserts identity, which ch04 rejects as too
  strong; a slot that needs external grounding would use `slot_uri`,
  but none do yet.)
- **Declare `default_range` once; never repeat it per slot.** A slot
  whose range is the default omits `range:` entirely, so a `range:`
  line always means the slot differs (an enum, a class, a `uri`, a
  number).
- **Schema descriptions state domain and purpose, nothing else.**
  `description:` fields ship with the artifact (generated docs, RDF,
  downstream graphs), so they carry only what a consumer of the *artifact*
  needs: what the ontology is about and what it is for. They never
  reference the book's structure (no chapter/step numbers, no "N&M", no
  CQ numbers, no "a later chapter will…") — and, just as important, they
  never carry the *method* story: no "built following Ontology
  Development 101", no "grounded in BFO/CCO", no "adapted to LinkML". The
  grounding is self-documenting in the schema structure (prefixes,
  `subclass_of`); the methodology belongs to the book.
  Book-facing and method-facing context goes in `#` comments or
  `# CALLOUT:` markers (which stay out of the artifact's data), not in
  permanent metadata.
- **Deferrals are tracked in the target chapter's scaffold.** When
  prose defers work to a later chapter or N&M step ("deferred to
  Chapter 6", "Step 5 work", "Chapter 7 will revisit"), add a
  matching `[ ]` TODO line in that chapter's `.md` scaffold,
  inside the HTML-comment `CARRIED-IN DEFERRALS` block (every step
  stub ships with one), citing the source chapter/section. Write
  the prose deferral and the scaffold TODO *together* so nothing
  promised is dropped. The HTML comments never render.
  (Within-chapter "next increment" work — not yet deferred to a
  *later* chapter — stays in the buildout plan, not these blocks.)
- **Strip a chapter's scaffold once finalized.** When a chapter is
  authored, delete its whole HTML-comment scaffold block
  (`CHARTER`/`SECTION OUTLINE`/`AUTHORING CHECKLIST`, and its own
  now-discharged `CARRIED-IN DEFERRALS`). Only *unwritten* chapters keep
  scaffolds — their `CARRIED-IN DEFERRALS` blocks still hold live TODOs
  that earlier chapters wrote forward. A finished chapter's own forward
  deferrals live in the *later* chapters' scaffolds, not its own, so
  deleting its scaffold loses nothing. The same goes for the
  instructional comments above `description:` and `license:` in the
  schema: each says to delete it once its field is filled, and a frozen
  listing that still carries one shows the reader meta-commentary
  instead of the schema.

## Book editions

The book is the chronological N&M history of the schema, and it stays
that through every patch release and through any minor release that does
not need a retelling. A minor release *may* start a revised edition
instead. The call is made once per minor release (once per major release
after 1.0), and the default is not to revise.

- **Within an edition, the book is a log.** Narrate reversals and dead
  ends as they happened, and do not retro-edit earlier chapters to hide a
  path that was later abandoned. Work that comes from using the ontology
  rather than from an N&M step goes in the refinements chapter after the
  seven steps (`ch08-refinements.md` here), one section per refinement,
  in release order. Wine's `v0.2.0` and `v0.2.1` both landed this way: the
  model grew and tightened, and no decision ch01–ch07 derive was
  reversed.
- **A minor release revises the edition when the log would mislead.** If
  the release reverses a decision earlier chapters build on, a reader who
  follows the book from Chapter 1 ends up with a model the schema no
  longer has, and a refinement section at the back does not fix that. A
  revised edition rewrites the book in place as the derivation of the new
  model, with a short preface saying what changed from the previous
  edition (the way a textbook's second edition does). From then on the
  revised edition is a log in its own right.
- **A patch release never revises.** It narrates in the refinements
  chapter of its own line. A patch to an older line (`v0.1.2` while
  `main` carries v0.2) is a commit on that line's newest tag, tagged and
  pushed on its own. There is no long-lived release branch, and a fix
  that also applies to `main` lands there separately.
- **Listing tags on a second line carry the line.** A listing frozen on
  an older patch line, or for a revised edition, puts the minor version
  in its tag (`wine-yaml-0.1-v7`, `wine-yaml-0.3-v1`), so it cannot
  collide with a same-numbered tag frozen on `main`. A revised edition
  re-freezes all its listings under its own series.

## Lessons

These are lessons-learned baked into the template; each step-chapter
stub carries the matching one as a LESSON line in its authoring
checklist.

- **Worked example as demand-driver from Step 1.** Pick the worked
  example early and let it pull every class and slot into existence; if
  something only earns its keep at Step 7, that is a smell.
- **Verify the upper-ontology CATEGORY, not just the IRI.** A resolving
  BFO/CCO IRI is not enough — confirm the category fit (e.g. don't
  ground a Quality as an Information Content Entity).
- **Graph viz as island detector.** Build the panschema class graph and
  treat island (disconnected) nodes as bugs to explain or remove.
- **A concern that fights the layer wants a companion ontology.** If a
  concept keeps resisting the foundational grounding, that is a signal
  it belongs in a separate companion ontology, not bolted on here.
- **The book is a chronological log within an edition.** Narrate
  reversals and dead-ends as they happened; do not retro-edit earlier
  chapters to hide a path that was later abandoned. Only a revised
  edition, cut at a minor release, rewrites them ("Book editions").
- **Speculative forward-references stay in private notes.** Keep
  future-repo names, roadmap, and speculative plans out of the public
  book and commits.
