# ontology-authoring-template

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

Two one-time bootstrap steps turn the wine showcase into your own blank
ontology. **Claude Code** runs both as skills (in `.claude/skills/`; not
using Claude Code? each skill's `SKILL.md` is the by-hand spec):

1. **Erect the scaffold** — say *"erect the scaffold"* (the
   **`erect-scaffold`** skill). It discards the wine showcase — schema,
   data, chapters, frozen listings — and raises the blank `scaffold/`
   baseline in its place. The infrastructure (CI, hooks, scripts) reads
   the schema path from `panschema-publish.toml`, so none of it needs
   editing.
2. **Name it** — say *"set up the template"* (the **`setup-ontology`**
   skill). It renames the `myschema` placeholder to your schema's name
   everywhere, sets your `https://w3id.org/<name>/` namespace, and fills
   in the domain purpose. Grounding is by URI: reference reuse
   vocabularies as prefixes, never LinkML `imports:`.

Then author the ontology one N&M step at a time with the **`advance-step`**
skill (*"do Step 1"*): write `introduction.md`, then work
`book/src/ch01`…`ch07` so the rendered Chapter N is N&M Step N. Each step
stub ships pre-seeded with the verbatim N&M quote(s), a charter, a section
outline, a deferrals block, and an authoring checklist. Freeze a listing
per chapter that advances the schema (see "Dogfooding the tooling" and
`CLAUDE.md`).

## Layout

```
schema/
  wine.yaml               # source of truth (LinkML)
data/                     # A-box instance data (each file validated against its schema in CI)
book/                     # mdbook documenting the N&M build (Building wine)
scaffold/                 # blank baseline erect-scaffold restores (Start your own)
scripts/
  dev.sh                  # local hot-reload preview (book + versioned schema docs)
  rebuild.sh              # one-shot rebuild (mirrors CI)
  check-line-width.sh     # schema content line-width gate (<=72 cols)
  schema-path.sh          # resolves the schema path from panschema-publish.toml
panschema.toml            # panschema manifest: generate (ttl/shacl/...) + check gates
panschema-publish.toml    # panschema's release + publish manifest
.claude/skills/           # erect-scaffold, setup-ontology, advance-step
.github/workflows/
  docs.yml                # builds book + versioned schema docs; deploys to Pages
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
cargo install mdbook --locked
cargo install --git https://github.com/padamson/mdbook-admonish \
  --branch feat/mdbook-0.5-compat --locked mdbook-admonish

# the frozen-listings preprocessor (central to this template)
cargo install --git https://github.com/padamson/mdbook-listings --locked mdbook-listings

# panschema (schema docs + graph + RDF); wasm-pack builds its embedded viz.
# mdbook-panschema (same workspace) installs the book→schema toolbar link.
cargo install wasm-pack --locked
cargo install --git https://github.com/padamson/panschema --locked panschema
cargo install --git https://github.com/padamson/panschema --locked mdbook-panschema

# the dev-loop file watcher
cargo install watchexec-cli --locked

# optional: in-browser auto-reload (else refresh manually after each rebuild)
npm install -g live-server
```

Confirm the six required tools are on `PATH`: `mdbook`, `mdbook-admonish`,
`mdbook-listings`, `panschema`, `mdbook-panschema`, `watchexec`
(`live-server` is optional).

> The exact pinned revisions CI installs are in
> [`.github/workflows/docs.yml`](.github/workflows/docs.yml); the commands above
> track the latest of each, which is what you want for local authoring.

### Math (optional)

The stock template ships **without** math rendering, so a bare clone has
no extra dependency. If your ontology's prose needs math (energies,
Greek symbols, units — `$E_b$`, `$\hbar\omega_\nu$`, `$\pm$`), enable
build-time KaTeX with [`mdbook-katex`](https://github.com/lzanini/mdbook-katex):

```bash
# pin 0.10.0-alpha — it targets official mdbook 0.5. The stable 0.9.x
# depends on a *fork* of mdbook and fails against 0.5 with
# "invalid type: null, expected any valid TOML value".
cargo install mdbook-katex --version 0.10.0-alpha --locked
```

Then add the preprocessor to `book/book.toml`, ordered **after**
`admonish` (otherwise `$…$` inside ```` ```admonish ```` blocks is skipped
and renders literally):

```toml
[preprocessor.katex]
after = ["admonish"]
```

Chapters can then write `$…$` / `$$…$$`. Notes:

- **CSS:** 0.10.0-alpha links KaTeX CSS from a CDN (jsDelivr) by default —
  fine for the published site. For an offline/self-contained build, set
  `no-css = true` and vendor the KaTeX CSS+fonts (helper crate
  `mdbook_katex_css_download`), referenced via `additional-css`.
- **CI:** add a matching install step to
  [`.github/workflows/docs.yml`](.github/workflows/docs.yml) (mirror the
  `mdbook` install, cache key on the pinned `0.10.0-alpha`) so the
  published docs render math too.

## Versioning

The schema's `version:` field is the source of truth. Release tags
match the version (e.g. `v0.1.0` ↔ `version: 0.1.0`). Between
releases, the version field carries a `-dev` suffix (e.g.,
`0.1.0-dev` while the first version is being built).

## Authoring

> **Claude Code users:** the **`advance-step`** skill walks one N&M step
> at a time — advancing the schema (demand-driven), re-freezing the
> listing tag, writing the chapter, and reconciling deferrals. Say
> "write the next chapter" or "do Step N".

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

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — see [LICENSE](LICENSE).
