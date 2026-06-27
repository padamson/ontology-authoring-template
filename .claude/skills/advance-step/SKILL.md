---
name: advance-step
description: Author the next N&M step-chapter of the ontology book — advance the LinkML schema only as the Appendix A worked example demands, add inline callouts, re-freeze a new listing tag (avoiding the stale-frozen-bytes foot-gun), write the chapter prose in the N&M voice, reconcile carried-in deferrals, and verify the build. Use when the user says "write the next chapter", "do Step N", "advance the schema", "work on ch0N", or wants to move the book forward one Noy & McGuinness step.
---

# Advance one N&M step-chapter

The connective workflow for moving the book forward one *Ontology
Development 101* step. It orchestrates the schema edit, the re-freeze,
and the prose so they stay consistent — the thing neither CLAUDE.md (the
standing conventions) nor the mdbook-listings skill (the tool mechanics)
owns by itself.

Read **CLAUDE.md** first — its "Authoring with mdbook-listings",
"freeze foot-gun", and "Conventions" sections are binding and not
repeated here.

## Step 0 — orient

- Derive the schema name from `panschema-publish.toml` (`[schema].name`)
  or the `schema/*.yaml` filename — never assume `myschema` (the repo may
  already be renamed via the [[setup-ontology]] skill).
- Find the next chapter to advance. The Introduction is the unnumbered
  prefix chapter (`introduction.md`); the seven N&M steps are ch01…ch07,
  so the rendered Chapter N is N&M Step N (mapping in CLAUDE.md). The next
  target is the
  first step stub still at scaffold state (only seeded N&M quotes +
  HTML-comment CHARTER/OUTLINE/DEFERRALS/CHECKLIST, no authored prose).
- Read that chapter's scaffold in full. The HTML comments are the
  contract for this step:
  - **CHARTER** — what the chapter must establish.
  - **SECTION OUTLINE** — the section spine to follow.
  - **CARRIED-IN DEFERRALS** — work promised to *this* step by earlier
    chapters; each `[ ]` must be discharged or explicitly re-deferred.
  - **AUTHORING CHECKLIST** — including the step's **LESSON** line.

## Step 1 — advance the schema, demand-driven

Edit `schema/<name>.yaml` **only as the Appendix A worked example
requires** (demand-driven dogfood — CLAUDE.md). If a class or slot can't
be justified by the worked example yet, it doesn't go in. Grounding is by
URI (`class_uri`/`slot_uri` + prefixes + mapping annotations), never
LinkML `imports:`.

Verify the upper-ontology **category**, not just that the IRI resolves
(LESSON): don't ground a Quality as an Information Content Entity.

Put callouts on what the prose will reference as **inline**
`# CALLOUT:` markers in the YAML — never sidecar TOML (CLAUDE.md reserves
sidecar for generated/third-party listings).

## Step 2 — re-freeze (the foot-gun)

Editing the schema does **not** re-freeze the embedded listing — a frozen
listing is a point-in-time snapshot, and the dev watcher rebuilds from
the *old* bytes. Bump the tag and re-freeze from `book/`:

```bash
cd book && mdbook-listings freeze ../schema/<name>.yaml \
  --tag <name>-yaml-vN --force
```

Bump `N` so earlier chapters keep pointing at the snapshot they froze.
Wire the new tag into this chapter with `{{#include}}` / `{{#callout}}`
/ `{{#diff}}` against the previous tag as the prose needs. For directive
syntax and the tag/SHA identity model, consult the **mdbook-listings**
skill (`references/cli.md`, `references/directives.md`) — don't
reconstruct it here.

## Step 3 — write the prose

Follow the SECTION OUTLINE. Voice: plain, technical, em-dash-lean design
discussion for a reader comfortable with LinkML and ontology basics — no
purple prose (LESSON). The N&M quote(s) are already seeded as `admonish
quote` blocks; build the discussion around them. Jargon blocks at first
use. Back external claims with citations. Every `# CALLOUT:` marker needs
a matching `{{#callout}}` label or `mdbook build` fails.

The book is a **chronological log** — narrate reversals and dead-ends as
they happened; never retro-edit earlier chapters to hide an abandoned
path. Keep speculative forward-references (future repo names, roadmap)
out — those go in private notes.

## Step 4 — reconcile deferrals (both directions)

- Discharge each `[ ]` in this chapter's CARRIED-IN DEFERRALS block, or
  explicitly re-defer it (and move the TODO forward).
- For every new "deferred to Chapter X / Step N" you write in the prose,
  add a matching `[ ]` TODO in *that* chapter's CARRIED-IN DEFERRALS
  HTML-comment block, citing this chapter as the source. Write the prose
  deferral and the scaffold TODO **together** (CLAUDE.md) — nothing
  promised may be dropped.

## Step 5 — run the checklist & verify

- Walk the chapter's AUTHORING CHECKLIST and satisfy each item,
  including the freeze-a-new-tag and demand-check items.
- Build and confirm the listing actually rendered:

```bash
cd book && mdbook build      # must exit 0
```

On a fresh clone this fails on a missing `mdbook-admonish.css` — the
admonish/listings assets are gitignored and generated. If you hit that,
run `./scripts/install-assets.sh` once (see README "Fresh clone"), then
rebuild.

`mdbook build` exiting 0 already catches a missing `{{#callout}}` label
or broken `{{#include}}`. If callouts seem missing, suspect a **stale
`site/`** first — confirm the freshly built `book/build/<chapter>.html`
has `callout-badge` elements before debugging deeper (CLAUDE.md).

- Optional sanity check: build the panschema class graph and treat
  island (disconnected) nodes as bugs to explain or remove (LESSON).

## Step 6 — keep the change chapter-scoped

The schema edit, the new freeze tag, and the chapter prose are **one
change** (CLAUDE.md: schema edits are chapter-scoped; trunk-based on
`main`). Don't propose a feature branch. Commit only if the user asks.

## Boundaries

- Tool mechanics → the **mdbook-listings** skill.
- Standing conventions, voice, lessons → **CLAUDE.md**.
- The one-time placeholder rename → the **setup-ontology** skill.
