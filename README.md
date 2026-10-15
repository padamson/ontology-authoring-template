# ontology-authoring-template

[![skills.sh](https://skills.sh/b/padamson/ontology-authoring-template)](https://skills.sh/padamson/ontology-authoring-template)

A GitHub-template-ready scaffold for authoring a [LinkML](https://linkml.io)
ontology — grounded in BFO 2020 and the Common Core Ontologies (CCO) —
via Noy & McGuinness's *Ontology Development 101* (N&M) method, with the
journey documented chapter-by-chapter as an mdbook.

The repo's **product** is a LinkML schema/ontology. The mdbook that
documents building it is a byproduct — but a load-bearing one: each N&M
step is a chapter, and each chapter embeds a **frozen snapshot** of the
schema as it stood at that step.

**This repo ships as a worked showcase:** the N&M *wine* ontology, built
chapter by chapter — read it as *Building wine*. The wine build is the
demonstration, not your starting point. To author your own ontology, you
discard the showcase first.

## Start your own

Two one-time bootstrap skills turn the wine showcase into your own blank
ontology, and a third, run once per chapter, writes it. They are written
for [Claude Code](https://claude.com/claude-code) running under the
sandbox this repo ships in `.claude/settings.json`, which allows network
access to `localhost` only. A few bootstrap steps (downloads, and writes
under `.claude/skills/`) fall outside it on purpose, so each skill hands
you one block to paste into your own terminal. (Not using Claude Code?
Each skill's `SKILL.md` is the by-hand spec.)

The sequence:

1. **Create the repo.** Use GitHub's "Use this template", or

   ```bash
   gh repo create <owner>/<name> --public --clone \
     --template padamson/ontology-authoring-template
   ```

   then open Claude Code in the clone. GitHub runs the docs workflow on the
   initial commit; it builds and verifies the showcase and skips
   publishing, because the copied manifest lists release tags your repo
   does not have.
2. **Erect the scaffold.** Say *"erect the scaffold"*. The
   **`erect-scaffold`** skill gives you a terminal block that discards the
   wine showcase (schema, data, chapters, and frozen listings) and raises
   the blank `scaffold/` baseline in its place, then checks the result.
   The infrastructure (CI, hooks, and scripts) reads the
   schema path from `panschema-publish.toml`, so none of it needs editing.
3. **Name it.** Say *"set up the template"*. The **`setup-ontology`**
   skill asks for the schema name, the `https://w3id.org/<name>/`
   namespace, a one-sentence domain purpose, and a licence for your
   ontology (the `license:` field ships in the generated RDF, so the skill
   will not guess it). It renames the `myschema` placeholder, rewrites the
   README and `CLAUDE.md` to describe your ontology, and builds the book
   to show the rename is clean. All of this runs inside the session.
4. **Enable GitHub Pages.** In the repo's Settings → Pages, set the source
   to "GitHub Actions" (`setup-ontology` offers to do it for you), or the
   first deploy fails. A private repo skips the deploy, so there is
   nothing to enable.
5. **Swap the carried skills for installs.** `setup-ontology` finishes
   with a second terminal block, which replaces the carried copy of the
   authoring skill with a managed install pinned in `skills-lock.json`
   and removes `setup-ontology` itself. The session then checks what got
   installed.
6. **Commit and push** to `main`. The docs workflow publishes the book and
   the schema site.
7. **Write the book.** Say *"do Step 1"*. The
   **`ontology-authoring-advance-step`** skill advances the schema one N&M
   step per chapter, freezes the listing the chapter embeds, and writes
   the chapter: `introduction.md`, then `book/src/ch01`…`ch07`, so the
   rendered Chapter N is N&M Step N. Each step stub ships with the
   verbatim N&M quote(s), a charter, a section outline, a deferrals block,
   and an authoring checklist. Grounding is by URI: reference reuse
   vocabularies as prefixes, never LinkML `imports:`.

## Layout

```
schema/
  wine.yaml               # source of truth (LinkML)
data/                     # A-box instance data (each file verified against its schema in CI)
book/                     # mdbook documenting the N&M build (Building wine)
scaffold/                 # blank baseline erect-scaffold restores (Start your own)
scripts/
  dev.sh                  # local hot-reload preview (book + versioned schema docs)
  rebuild.sh              # one-shot rebuild (mirrors CI)
  build-book.sh           # mdbook build that fails on a logged ERROR (CI's gate)
  check-line-width.sh     # schema content line-width gate (<=72 cols)
  schema-path.sh          # resolves the schema path from panschema-publish.toml
  check-tool-pins.sh      # reports docs.yml tool pins that crates.io has moved past
  grade-baseline.sh       # grades cqa-grader's baseline against the benchmark (CI's gate, Step 7 on)
panschema.toml            # panschema manifest: generate (ttl/shacl/...) + check gates
panschema.lock            # the cqa contract's resolved checksum (written by panschema fetch)
panschema-publish.toml    # panschema's release + publish manifest
skills/                   # shipped: ontology-authoring-advance-step
.claude/skills/           # this checkout only: erect-scaffold, setup-ontology
                          #   (+ a symlink to the shipped skill above)
.github/
  dependabot.yml          # weekly, grouped action bumps (one PR, merged by hand)
  workflows/
    docs.yml              # builds book + versioned schema docs, grades the benchmark's baseline; deploys to Pages
    tool-pins.yml         # weekly: opens an issue when a docs.yml tool pin is behind
```

## Toolchain

The build uses four Rust binaries and a file watcher (all required for
the dev loop), plus an optional static server for browser auto-reload.
Three of the binaries are maintained by this template's author and
installed **from Git rather than crates.io** — so don't expect a plain
`cargo install <name>` to find them.

> **Heads up — you're tracking pre-releases and a fork.** `mdbook-admonish`
> is a fork branch (`feat/mdbook-0.5-compat`, pending upstream release),
> and `mdbook-listings` and `panschema` are not yet published to crates.io.
> The template dogfoods these in-development tools; pin to a known-good
> revision if you need stability (see the CI-pinned revs in
> [`.github/workflows/docs.yml`](.github/workflows/docs.yml)).

**Prerequisites:** a Rust toolchain (`cargo`); optionally Node.js (for
in-browser auto-reload).

| Tool | What it does | Source |
|---|---|---|
| **mdbook** | renders `book/` to HTML | crates.io (rust-lang) |
| **mdbook-admonish** *(fork)* | the `admonish` blocks used for N&M quotes and jargon notes | a fork branch — upstream isn't yet compatible with mdbook 0.5; the `feat/mdbook-0.5-compat` branch adds that compat, pending an upstream release |
| **mdbook-listings** | the frozen-listing preprocessor at the heart of this template: `freeze` a schema snapshot, embed it with `{{#include}}`, annotate with `{{#callout}}`, diff versions with `{{#diff}}` | from Git (not yet on crates.io) |
| **panschema** | generates the versioned schema HTML docs, an interactive class-graph viz, and RDF from the LinkML schema; needs `wasm-pack` to build its embedded viz | from Git |
| **mdbook-panschema** | installs the book→schema toolbar link (`schema-link.js`/`.css`), configured by `[book_link]` in `panschema-publish.toml` | from Git (panschema workspace) |
| **watchexec** *(required)* | the file watcher that drives the `scripts/dev.sh` rebuild-on-save loop | crates.io |
| **live-server** *(optional)* | browser auto-reload for the combined `site/`; without it `dev.sh` falls back to `python3 -m http.server` (manual refresh). The merged book + schema-docs site is plain static files, so it needs a generic server, not `mdbook serve` | npm |

### Install

```bash
# mdbook + the admonish fork (adds mdbook 0.5 compatibility)
cargo install mdbook --version 0.5.4 --locked
cargo install --git https://github.com/padamson/mdbook-admonish \
  --branch feat/mdbook-0.5-compat --locked mdbook-admonish

# the frozen-listings preprocessor (central to this template)
cargo install mdbook-listings --version 0.2.2 --locked

# panschema (schema docs + graph + RDF); wasm-pack builds its embedded viz.
# One install, two binaries: the panschema crate also ships mdbook-panschema,
# which installs the book→schema toolbar link.
cargo install wasm-pack --version 0.15.0 --locked
cargo install --git https://github.com/padamson/panschema --locked panschema

# the dev-loop file watcher
cargo install watchexec-cli --locked

# optional: in-browser auto-reload (else refresh manually after each rebuild)
npm install -g live-server
```

The three `--version` pins match the `env:` block in
`.github/workflows/docs.yml`; when one moves, move both, or your preview
and the published book render differently.
[`.github/workflows/tool-pins.yml`](.github/workflows/tool-pins.yml) opens
an issue each week for a pin that crates.io has moved past.

Confirm the six required tools are on `PATH`: `mdbook`, `mdbook-admonish`,
`mdbook-listings`, `panschema`, `mdbook-panschema`, `watchexec`
(`live-server` is optional).

CI installs one more binary once `[check.cqa]` is on in `panschema.toml`:
**cqa-grader**, from Git (no release yet), whose naive baseline it grades
against the benchmark over the generated Turtle
(`scripts/grade-baseline.sh`). It is not part of the dev loop; install it
only to run that gate locally:
`cargo install --git https://github.com/padamson/cqa-grader --locked cqa-grader`.

> The exact pinned revisions CI installs are in
> [`.github/workflows/docs.yml`](.github/workflows/docs.yml); the commands above
> track the latest of each, which is what you want for local authoring.

### Math (optional)

The stock template ships **without** math rendering, so a bare clone has
no extra dependency. If your ontology's prose needs math (energies,
Greek symbols, units — `$E_b$`, `$\hbar\omega_\nu$`, `$\pm$`), enable
build-time KaTeX with [`mdbook-katex`](https://github.com/lzanini/mdbook-katex):

```bash
# 0.10.0 or later: it targets official mdbook 0.5. The older 0.9.x
# depends on a *fork* of mdbook and fails against 0.5 with
# "invalid type: null, expected any valid TOML value".
cargo install mdbook-katex --version 0.10.0 --locked
```

Then add the preprocessor to `book/book.toml`, ordered **after**
`admonish` (otherwise `$…$` inside ```` ```admonish ```` blocks is skipped
and renders literally):

```toml
[preprocessor.katex]
after = ["admonish"]
```

Chapters can then write `$…$` / `$$…$$`. Notes:

- **CSS:** 0.10.0 links KaTeX CSS from a CDN (jsDelivr) by default —
  fine for the published site. For an offline/self-contained build, set
  `no-css = true` and vendor the KaTeX CSS+fonts (helper crate
  `mdbook_katex_css_download`), referenced via `additional-css`.
- **CI:** add a matching install step to
  [`.github/workflows/docs.yml`](.github/workflows/docs.yml) so the
  published docs render math too. Mirror the `mdbook` install: an
  `MDBOOK_KATEX_VERSION: "0.10.0"` pin in the `env:` block, a cache keyed
  on it, and `cargo install mdbook-katex --version ${{ env.MDBOOK_KATEX_VERSION }} --locked`.
  Installed that way, the weekly tool pin check covers it too.

## Versioning

The schema's `version:` field is the source of truth. Release tags
match the version (e.g. `v0.1.0` ↔ `version: 0.1.0`). Between
releases, the version field carries a `-dev` suffix (e.g.,
`0.1.0-dev` while the first version is being built).

## Authoring

> **Claude Code users:** the **`ontology-authoring-advance-step`** skill
> walks one N&M step at a time — advancing the schema (demand-driven),
> re-freezing the listing tag, writing the chapter, and reconciling
> deferrals. Say "write the next chapter" or "do Step N".
>
> Install it from a plain terminal, not from inside a Claude Code session
> — the sandbox denies writes under `.claude/skills/`:
>
> ```bash
> npx skills add padamson/ontology-authoring-template \
>   -s ontology-authoring-advance-step -a claude-code -y
> ```
>
> Name the skill with `-s`: a bare `add` takes everything a repo publishes.
> Commit the resulting `skills-lock.json` and ignore the materialized
> copies; `npx skills update -p` refreshes, and the installed
> `SKILL.md`'s `metadata.version` is how you check what you actually have.
> A repo seeded from this template gets the same install wired up by
> **erect-scaffold** and **setup-ontology**.

The combined book + versioned schema docs run locally via:

```bash
./scripts/dev.sh
# → http://localhost:8000/
```

This builds the book at `/` and panschema-published versioned schema
docs at `/schema/{main,current}/` (plus `/schema/<tag>/` once releases
exist), serves the combined site over HTTP, and rebuilds on any save in
`schema/`, `book/`, or (if you have the producer repos cloned locally —
see "Dogfooding the tooling" below) `panschema/`, `mdbook-listings/`,
`mdbook-admonish/` sources.

You can also build the book alone:

```bash
cd book && mdbook serve   # local preview with live reload
cd book && mdbook build   # output to book/build/
./scripts/build-book.sh   # the CI gate: mdbook build, failing on a logged ERROR
```

First time? Install the toolchain — see **[Toolchain → Install](#install)** above.

> **Fresh clone:** the admonish/listings/schema-link CSS+JS are generated
> assets, intentionally gitignored (see [`.gitignore`](.gitignore)), so a
> bare `mdbook build` fails with *"Unable to copy across static files …
> mdbook-admonish.css"* until you generate them once:
>
> ```bash
> ./scripts/install-assets.sh
> ```
>
> Run that after cloning (and any time the assets go missing); then
> `mdbook build` / `mdbook serve` work. (The `./scripts/dev.sh` loop
> regenerates them on its own, so this is only for the standalone
> `mdbook build` path.)
>
> Also once after cloning: `panschema fetch`. The benchmark's schema (the
> cqa contract) is a pinned dependency, and `fetch` downloads the release
> `panschema.lock` names into panschema's local cache, after which
> `panschema verify` / `generate` and the pre-commit hook run offline.

### Other formats

The book's HTML is one of several outputs. `panschema.toml` drives
`panschema generate` (run in CI), which emits SHACL shapes, JSON Schema,
TTL (schema + the A-box knowledge graph), and the instance-graph JSON into
`site/artifacts/`, deployed with the docs site. panschema can also emit
`jsonld`, `rdfxml`, `ntriples`, and more — see `panschema generate --help`.

## Dogfooding the tooling

This template exercises [panschema](https://github.com/padamson/panschema),
`mdbook-listings`, and the `mdbook-admonish` fork. The scripts resolve
every producer by name via `$PATH` — the same contract CI uses — and each
rebuild prints which binary answered and its version, which is what
catches a stale install masquerading as a fresh one.

### The alias pattern

To make your **interactive shell** use local debug builds, clone the
producers wherever you like, point `PRODUCER_ROOT` at that directory, and
alias each producer to its `target/debug` binary:

```zsh
# ~/.zshrc
export PRODUCER_ROOT="/path/to/producers"    # wherever you cloned them
alias panschema="$PRODUCER_ROOT/panschema/target/debug/panschema"
alias mdbook-listings="$PRODUCER_ROOT/mdbook-listings/target/debug/mdbook-listings"
alias mdbook-admonish="$PRODUCER_ROOT/mdbook-admonish/target/debug/mdbook-admonish"
```

Aliases only load in interactive shells, so they never reach the scripts —
for those, prepend the directory to `PATH` instead:

```bash
PATH="$PRODUCER_ROOT/panschema/target/debug:$PATH" ./scripts/dev.sh
```

`install-assets.sh` ignores `PRODUCER_ROOT` entirely — it's a
fresh-clone/consumer helper that relies on whatever the README "Install"
step put on `PATH`.

### Seams for external tooling

`scripts/dev.sh` honors two optional environment variables, so a wrapper
that manages producer binaries can drive the loop without the repo
knowing about it:

- **`DEV_WATCH_EXTRA`** — space-separated extra paths to watch; edits
  there trigger a rebuild like any watched source. Never hand it a
  directory containing build output (a `target/`), which would loop the
  watcher.
- **`REBUILD_CMD`** — what to run on each change (default
  `scripts/rebuild.sh`). A wrapper that resolves producer binaries can
  point this back through itself so every cycle re-resolves — that is
  how edit-producer → site-rebuilds loops are wired.

> **panschema wasm note:** editing `panschema-viz/src` (the graph viz) does
> not rebuild the embedded wasm via `cargo build` — `build.rs` only runs
> `wasm-pack` when `panschema-viz/pkg/` is missing. Rebuild it with
> `wasm-pack build` in `panschema-viz`, or `rm -rf panschema-viz/pkg`.

## License

Two licenses, split by what the file is for.

| | License | Covers |
|---|---|---|
| **Tooling** | [Apache-2.0](LICENSE-APACHE) | `skills/`, `scaffold/`, `scripts/`, `.github/`, and the hook and lint configs |
| **The book** | [CC BY 4.0](LICENSE) | `book/`, `schema/wine.yaml`, and `data/` — the wine showcase and its prose |

The split follows what each part is *for*. `scaffold/` exists to be derived
from: every repo seeded from this template is a derivative work of it, and
Apache-2.0 asks such a repo for a preserved notice rather than attribution
across everything it goes on to build. The same applies to the authoring
skill, which is functional — Creative Commons recommends against CC licenses
for software, and Apache-2.0 also carries a patent grant. Apache-2.0 is also
available across the sibling tools —
[panschema](https://github.com/padamson/panschema) is Apache-2.0 and
[mdbook-listings](https://github.com/padamson/mdbook-listings) is
MIT OR Apache-2.0 — so a consumer of all three can read them under one.

*Building wine* is public teaching, and attribution is the point — so the
book, the wine schema it builds, and its instance data stay CC BY 4.0. A repo
seeded from this template keeps `LICENSE-APACHE` (covering the scaffold it
derived) and chooses its own license for its own ontology and book.
