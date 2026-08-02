---
name: erect-scaffold
description: Discard the wine worked-showcase from a freshly-cloned ontology-authoring-template and raise the blank scaffold in its place — delete the showcase schema, data, book chapters, and frozen listings, promote scaffold/ to the repo root, and hand off to setup-ontology for the rename. Use right after cloning / "Use this template" when the user wants their OWN ontology rather than the wine demo, or when they say "erect the scaffold", "discard the showcase", "start from a blank slate", "eject the wine demo".
---

# Erect the scaffold (discard the wine showcase)

The published repo is a **worked showcase**: the N&M wine ontology, built
chapter by chapter to demonstrate the template. A consumer who wants their
own ontology doesn't want the wine build — they want the blank baseline.
This skill tears down the showcase and raises the `scaffold/` baseline in
its place, then hands off to `setup-ontology` for the `myschema` → real-name
rename. Run it once, right after cloning.

The flow for a new ontology is: **erect-scaffold → [[setup-ontology]] →
[[advance-step]]** (per chapter).

## What stays vs. what goes

Only the **showcase content** is discarded. The **infrastructure** is
schema-name-agnostic (CI, hooks, and scripts read the schema path from
`panschema-publish.toml` via `scripts/schema-path.sh`), so it needs no
edits and stays exactly as is:

- **Kept:** `.github/`, `.pre-commit-config.yaml`, `.yamllint`,
  `.gitignore`, `LICENSE`, `scripts/`, and `.claude/skills/`
  (`advance-step`, `setup-ontology`).
- **Replaced from `scaffold/`:** `schema/`, `book/src/`, `book/book.toml`,
  `book/listings.toml`, `panschema.toml`, `panschema-publish.toml`,
  `README.md`, `CLAUDE.md`.
- **Deleted outright** (no scaffold counterpart): `data/` and
  `book/src/listings/` (the wine A-box and the frozen wine snapshots).

`scaffold/` is a tracked directory, not a git tag, on purpose: GitHub's
"Use this template" makes a single-commit repo with no tags, so a
tag-based restore wouldn't survive instantiation — a tracked directory
does.

## When NOT to run

If the showcase is already gone — no `schema/wine.yaml`, no `scaffold/`
directory — the eject is done. Say so instead of running it again.

## Step 1 — confirm (destructive)

This removes the wine showcase from the working tree. The git *history*
is untouched (the showcase stays reachable in earlier commits), but the
current tree is overwritten. Confirm before proceeding:

> "Discard the wine showcase and raise the blank scaffold? This replaces
> the schema, data, and all book chapters with the empty baseline. The
> next step (setup-ontology) renames `myschema` to your schema's name."

If the user declines, stop and leave everything in place.

## Step 2 — sanity-check the scaffold is complete

Before deleting anything, confirm `scaffold/` carries every file the root
promote needs, so a partial scaffold can't leave the repo half-built:

```bash
for f in schema/myschema.yaml book/src/SUMMARY.md book/src/introduction.md \
         book/book.toml book/listings.toml panschema.toml \
         panschema-publish.toml README.md CLAUDE.md; do
  test -e "scaffold/$f" || echo "MISSING: scaffold/$f"
done
```

If anything is missing, stop and report it — do not proceed with a
partial promote.

## Step 3 — tear down the showcase and promote the scaffold

```bash
cd "$(git rev-parse --show-toplevel)"

# Remove the wine showcase working tree.
rm -rf schema data book/src book/book.toml book/listings.toml \
       panschema.toml panschema-publish.toml README.md CLAUDE.md

# Promote the blank scaffold baseline to the repo root.
cp -R scaffold/schema schema
cp -R scaffold/book/src book/src
cp scaffold/book/book.toml scaffold/book/listings.toml book/
cp scaffold/book/soft-wrap.css book/            # harmless if identical
cp scaffold/panschema.toml scaffold/panschema-publish.toml .
cp scaffold/README.md scaffold/CLAUDE.md .
```

## Step 4 — remove the scaffold and this skill (self-clean)

Both are one-time bootstrap tooling. Once the baseline is raised they are
dead weight in the instance (and `scaffold/` still says `myschema`, which
is correct for the template but stale inside an instantiated repo). Remove
them as the final tree change — this skill's instructions are already
loaded, so deleting its files mid-run is fine:

```bash
rm -rf scaffold
rm -rf .claude/skills/erect-scaffold
```

`setup-ontology` and `advance-step` are the only skills left, which is
correct — they are the bootstrap-rename and per-chapter authoring tools a
fresh ontology still needs.

## Step 5 — hand off

Don't commit unless asked (trunk-based on `main` — see the new `CLAUDE.md`).
Tell the user what changed and what's next: run **setup-ontology** to
rename `myschema` to their schema's name and set the namespace, then start
Step 1 with **advance-step**. A quick `git status` shows the swap as a
large delete/add set staged for their review.

## Maintainer note (template repo only)

`scaffold/` is the source of truth for what this skill restores, so when a
wine chapter's build surfaces a template lesson — a stub outline that
didn't fit, a config default that needed tweaking — fold the fix back into
the matching `scaffold/` file. The wine chapters are throwaway for
consumers; the scaffold is what they actually start from. (This note is
for whoever maintains the showcase; a consumer who has ejected never sees
it, because the skill is gone.)
