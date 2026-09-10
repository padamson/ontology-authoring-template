# Skills in this repo

Two audiences, two locations — the split is deliberate, so keep it when
adding a skill or a plugin manifest.

## `skills/<name>/` — shipped

`ontology-authoring-advance-step` lives in the root `skills/` directory
and is symlinked here for in-repo auto-loading (Claude Code discovers
project skills at `.claude/skills/` only; `npx skills add` discovers
`skills/<name>/`). One source of truth, both audiences.

A repo seeded from this template needs it for the life of its ontology,
so it installs the skill rather than carrying a copy. Two channels reach
it, and `.claude-plugin/` is what makes the first one work:

```
/plugin marketplace add padamson/ontology-authoring-template
/plugin install ontology-authoring-template@ontology-authoring-template
```

```bash
npx skills add padamson/ontology-authoring-template \
  --skill ontology-authoring-advance-step
```

Prefer the plugin in Claude Code: nothing lands in the consumer's tree, so
nothing can fork, and `/plugin update` gates on `plugin.json`'s version.
The Skills CLI is for the other agents it supports, and it copies files in,
which may result in diverged copies of the skill.
Name the skill either way; a bare `add` takes everything.

The two versions must agree, and a pre-commit hook
(`scripts/check-skill-version-bumped.sh`) enforces it: `/plugin update`
reads `plugin.json`, the Skills CLI reads the frontmatter's
`metadata.version`, and a reader on either channel compares against the
one they can see. The version is the skill's own — do **not** pin it to
the schema's `version:`, which is ontology metadata and means something
else entirely.

Its name carries the `ontology-authoring-` prefix because a shipped
skill's name and description are the only things preventing it from
activating where it makes no sense.

## `.claude/skills/<name>/` — this checkout only

`erect-scaffold` and `setup-ontology` are **bootstrap** skills: they act
on a fresh clone of this template, and they are spent once they have run
(one discards the showcase, the other renames the placeholder). You get
them by cloning; installing them into an already-bootstrapped repo would
be meaningless at best and destructive at worst — `erect-scaffold`
deletes a showcase.

So they stay here, and both carry `metadata.internal: true` (a
**boolean** — the CLI silently ignores the string `"true"`) to keep them
that way.

That marking is load-bearing, and the reason is worth recording: this
directory is **not** private. `npx skills add` clones the repo and scans
`.claude/skills/` alongside `skills/<name>/`, so once the root `skills/`
directory existed the CLI offered all three — including `erect-scaffold`,
which deletes a showcase. The trigger was the root `skills/` directory,
not a `.claude-plugin/` manifest (this repo still has none). Adding
either one re-opens the question for every skill in here.

Assert it rather than assuming it — the count is the test:

```bash
npx skills add padamson/ontology-authoring-template --list   # expect: Found 1 skill
```
