# ontology-authoring-template

A GitHub-template-ready scaffold for authoring a [LinkML](https://linkml.io)
ontology — grounded in BFO 2020 and the Common Core Ontologies (CCO) —
via Noy & McGuinness's *Ontology Development 101* (N&M) method, with the
journey documented chapter-by-chapter as an mdbook.

The repo's **product** is a LinkML schema/ontology. The mdbook that
documents building it is a byproduct — but a load-bearing one: each N&M
step is a chapter, and each chapter embeds a **frozen snapshot** of the
schema as it stood at that step.

> The placeholder schema name throughout is **`myschema`**. Rename it to
> your schema's name after cloning (see SETUP below).

## Use this template / SETUP

1. **Create a repo from this template** (GitHub "Use this template"), or
   clone it and re-init git.
2. **Rename `myschema`** to your schema's name everywhere:
   - `schema/myschema.yaml` → `schema/<name>.yaml` (and the `id:`,
     `name:`, `default_prefix:`, and the `myschema:` prefix inside it)
   - `panschema-publish.toml` — `[schema].name`, `[files].main`
   - `book/book.toml` — `title`, `description`
   - `.pre-commit-config.yaml`, `scripts/*.sh`, `CLAUDE.md` — the
     comment/path references to `myschema.yaml`
   - the freeze tag convention `myschema-yaml-vN` → `<name>-yaml-vN`
3. **Set the schema `id:` and prefixes** in `schema/<name>.yaml` to your
   own `https://w3id.org/<name>/` namespace; add any domain reuse
   vocabularies as prefixes (grounding is by URI, never `imports:`).
4. **Write `ch01-introduction.md`**, then work **Steps 1–7** in
   `book/src/ch02`…`ch08`. Each step stub ships pre-seeded with the
   verbatim N&M quote(s), a CHARTER, a section outline, a deferrals
   block, and an authoring checklist (including the step's lesson).
5. **Freeze a listing per chapter** that advances the schema (see
   "Dogfooding the tooling" and `CLAUDE.md`).

## Layout

```
schema/
  myschema.yaml           # source of truth (LinkML); rename to <name>.yaml
book/                     # mdbook documenting the N&M build
scripts/
  dev.sh                  # local hot-reload preview (book + versioned schema docs)
  rebuild.sh              # one-shot rebuild (mirrors CI)
  check-line-width.sh     # schema content line-width gate (<=72 cols)
panschema-publish.toml    # panschema's release + publish manifest
.github/workflows/
  docs.yml                # builds book + versioned schema docs; deploys to Pages
```

## Toolchain

The build uses four Rust binaries plus a file watcher. Three of them are
maintained by this template's author and installed **from Git rather than
crates.io** — so don't expect a plain `cargo install <name>` to find them.

**Prerequisites:** a Rust toolchain (`cargo`); optionally Node.js (for
in-browser auto-reload).

| Tool | What it does | Source |
|---|---|---|
| **mdbook** | renders `book/` to HTML | crates.io (rust-lang) |
| **mdbook-admonish** *(fork)* | the `admonish` blocks used for N&M quotes and jargon notes | a fork branch — upstream isn't yet compatible with mdbook 0.5; the `feat/mdbook-0.5-compat` branch adds that compat, pending an upstream release |
| **mdbook-listings** | the frozen-listing preprocessor at the heart of this template: `freeze` a schema snapshot, embed it with `{{#include}}`, annotate with `{{#callout}}`, diff versions with `{{#diff}}` | from Git (not yet on crates.io) |
| **panschema** | generates the versioned schema HTML docs, an interactive class-graph viz, and RDF from the LinkML schema; needs `wasm-pack` to build its embedded viz | from Git |
| **watchexec** | file watcher that drives `scripts/dev.sh` | crates.io |

### Install

```bash
# mdbook + the admonish fork (adds mdbook 0.5 compatibility)
cargo install mdbook --locked
cargo install --git https://github.com/padamson/mdbook-admonish \
  --branch feat/mdbook-0.5-compat --locked mdbook-admonish

# the frozen-listings preprocessor (central to this template)
cargo install --git https://github.com/padamson/mdbook-listings --locked mdbook-listings

# panschema (schema docs + graph + RDF); wasm-pack builds its embedded viz
cargo install wasm-pack --locked
cargo install --git https://github.com/padamson/panschema --locked panschema

# the dev-loop file watcher
cargo install watchexec-cli --locked

# optional: in-browser auto-reload (else refresh manually after each rebuild)
npm install -g live-server
```

Confirm all five are on `PATH`: `mdbook`, `mdbook-admonish`, `mdbook-listings`,
`panschema`, `watchexec`.

> The exact pinned revisions CI installs are in
> [`.github/workflows/docs.yml`](.github/workflows/docs.yml); the commands above
> track the latest of each, which is what you want for local authoring.

## Versioning

The schema's `version:` field is the source of truth. Release tags
match the version (e.g. `v0.1.0` ↔ `version: 0.1.0`). Between
releases, the version field carries a `-dev` suffix (e.g.,
`0.1.0-dev` while the first version is being built).

## Authoring

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

### Other formats

panschema can also emit `ttl`, `jsonld`, `rdfxml`, `ntriples` via
`--format <fmt>`. See `panschema generate --help`.

## Dogfooding the tooling

This template exercises [panschema](https://github.com/padamson/panschema),
`mdbook-listings`, and the `mdbook-admonish` fork. When you iterate on a
producer's source, `scripts/dev.sh` can rebuild it and regenerate the
site from the fresh binary, so producer changes show up live.

### The alias pattern

`scripts/rebuild.sh` invokes producers by name (`panschema`,
`mdbook-listings`, `mdbook-admonish`). To make both the scripts and your
interactive shell use your **local debug builds** instead of the
`cargo install`-ed releases, clone the producers under
`~/src/github-padamson/` and alias each to its `target/debug` binary:

```zsh
# ~/.zshrc
alias panschema="$HOME/src/github-padamson/panschema/target/debug/panschema"
alias mdbook-listings="$HOME/src/github-padamson/mdbook-listings/target/debug/mdbook-listings"
alias mdbook-admonish="$HOME/src/github-padamson/mdbook-admonish/target/debug/mdbook-admonish"
```

Aliases load only in interactive shells; `rebuild.sh` re-derives the same
paths via `$PATH` prepends so non-interactive runs match.

### Three modes

- **Authoring only** — not touching the producers, just writing the schema
  and book against the released binaries. `./scripts/dev.sh`; producers you
  haven't cloned are skipped.
- **Light producer dogfooding** — an occasional producer tweak where you
  want edit-producer → site auto-rebuilds. `./scripts/dev.sh` (the default:
  it watches and `cargo build`s the producers). Fine when their builds are
  fast or infrequent.
- **Heavy producer development** — you're building out a producer (e.g.
  panschema features) and its per-change `cargo build` (linking panschema's
  ~35 MB debug binary) is too slow on every edit:

  ```bash
  SKIP_PRODUCER_BUILD=1 ./scripts/dev.sh
  ```

  dev.sh stops watching and building producers; you drive the producer's
  build in its own repo, then `touch schema/myschema.yaml` to regenerate
  the site with the new binary.

> **panschema wasm note:** editing `panschema-viz/src` (the graph viz) does
> not rebuild the embedded wasm via `cargo build` — `build.rs` only runs
> `wasm-pack` when `panschema-viz/pkg/` is missing. Rebuild it with
> `wasm-pack build` in `panschema-viz`, or `rm -rf panschema-viz/pkg`.

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) — see [LICENSE](LICENSE).
