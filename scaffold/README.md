# `scaffold/` — the pristine blank template baseline

This directory is the **blank authoring surface** a fresh ontology starts
from: the unwritten Introduction, the seven empty N&M step stubs, the
empty `myschema` schema seed, and the matching `book.toml` /
`listings.toml` / `panschema-publish.toml`.

## Why it exists

The live `book/` and `schema/` build a **worked showcase** — the N&M wine
ontology, authored chapter by chapter as a demonstration of this template.
A consumer who clones the template (or uses "Use this template") doesn't
want the wine build; they want a clean blank start. So `setup-ontology`'s
reset step copies `scaffold/` back over the showcase to restore the blank
`myschema` baseline, then runs its usual `myschema` → `<your-name>` rename.

It lives **in the tree** (not a git tag) on purpose: GitHub's "Use this
template" creates a new repo with a single commit and no tags, so a
tag-based restore would not survive instantiation — a tracked directory
does.

`mdbook` and `panschema` only build `book/` and the schema named in
`panschema-publish.toml`, so nothing here is ever published.

## Keeping it in sync

If you change the **blank-template conventions** (a step stub's scaffold,
the schema seed, a config default), update the matching file here too —
this directory is the source of truth for what a reset restores. It is not
touched by the wine showcase build.

Authoring the wine showcase is also the template's own dogfooding: when a
chapter's build surfaces a lesson — a stub outline that didn't fit, a
missing checklist item, a schema-seed default that needed tweaking — fold
the fix back into the matching `scaffold/` file so a fresh clone inherits
it. The wine chapters are throwaway for consumers; the scaffold is what
they actually start from.
