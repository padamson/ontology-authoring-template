# Skills in this repo

Two audiences, two locations — the split is deliberate, so keep it when
adding a skill.

## `skills/<name>/` — shipped

`ontology-authoring-advance-step` lives in the root `skills/` directory
and is symlinked here for in-repo auto-loading (Claude Code discovers
project skills at `.claude/skills/` only; `npx skills add` discovers
`skills/<name>/`). One source of truth, both audiences.

A repo seeded from this template needs it for the life of its ontology,
so it installs the skill rather than carrying a copy. **One channel:**

```bash
npx skills add padamson/ontology-authoring-template \
  -s ontology-authoring-advance-step -a claude-code -y
```

Name the skill with `-s`; a bare `add` takes everything a repo publishes.
Run it from a plain terminal — inside a Claude Code session the sandbox
denies writes under `.claude/skills/`, and the CLI exits 2 on
`EPERM: mkdir .claude/skills` having installed nothing.

The Claude Code plugin channel was tried here and **retired** ecosystem-wide
on 2026-09-15. Two channels tracked the same `main` and differed only in the
gate, so consumers picked one by accident of which note they read last, and
the plugin copies went stale — one sibling repo sat on a three-month-old
skill whose `references/` was missing a file the convention depended on. The
manifests carried no hooks, commands, agents or MCP servers: nothing the
skill directory does not. So there is no `.claude-plugin/` here, and adding
one back reopens that decision rather than just adding a file.

`metadata.version` in the frontmatter is the only version an installed copy
carries, and `scripts/check-skill-version-bumped.sh` enforces a bump on any
content change under `skills/` — pre-commit per commit, and a CI job against
the previous tip so `--no-verify` cannot slip past. The version is the
skill's own: do **not** pin it to the schema's `version:`, which is ontology
metadata and means something else entirely.

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
which deletes a showcase. The trigger was the root `skills/` directory
alone; no manifest was involved.

Assert it rather than assuming it — the count is the test:

```bash
npx skills add padamson/ontology-authoring-template --list   # expect: Found 1 skill
```
