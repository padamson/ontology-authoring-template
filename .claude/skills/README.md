# Skills in this repo

Two audiences, two locations — the split is deliberate, so keep it when
adding a skill or a plugin manifest.

## `skills/<name>/` — shipped

`ontology-authoring-advance-step` lives in the root `skills/` directory
and is symlinked here for in-repo auto-loading (Claude Code discovers
project skills at `.claude/skills/` only; `npx skills add` discovers
`skills/<name>/`). One source of truth, both audiences.

A repo seeded from this template needs it for the life of its ontology,
so it installs the skill rather than carrying a copy:

```bash
npx skills add padamson/ontology-authoring-template
```

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

So they stay here, unshipped. If this repo ever gains a
`.claude-plugin/` manifest, keep these two out of it, or mark them
`metadata.internal: true` (a **boolean** — the CLI silently ignores the
string `"true"`).
