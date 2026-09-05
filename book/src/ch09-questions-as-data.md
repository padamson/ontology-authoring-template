# Questions as Data

Chapter 1 sketched seven competency questions (CQs) and called them the litmus
test. Chapter 7 ran that test: each question answered in prose against the
catalog. Chapter 8 grew the catalog and walked the answers again. Both
walks were a person reading prose against a file, and that is the weakness:
a prose answer has no tooling behind it. Edit the catalog and nothing tells
you an answer went stale.

```admonish quote title="Noy & McGuinness 2001 — §Step 1, Competency questions"
These questions will serve as the litmus test later: Does the
ontology contain enough information to answer these types of
questions?
```

This chapter turns the CQs into benchmark data. The vocabulary for the
benchmark is [`cqa`](https://github.com/padamson/cqa-schema), a schema
for competency question-and-answer (CQ&A) records: one record pairs a
question with the full specification of its correct answer (the
`ground_truth` in prose, the `answer_kind` the question demands, and
the records in the target graph a correct answer must reach and cite).
cqa is itself a LinkML ontology, built through the same seven steps
as this book, and the two builds are entangled: cqa has no domain
graph of its own (a benchmark is meaningless without a graph to
benchmark, and a contract's instances are always a consumer's), so
*wine's* benchmark is the worked example that pulled cqa's initial set of classes
and slots into existence.
The demand-driven rule that has governed this build since Step 1 ran
across the [`cqa`](https://github.com/padamson/cqa-schema)/[`wine`](https://github.com/padamson/ontology-authoring-template) repository boundary.

## Six questions, encoded

The benchmark is one file, `data/wine-benchmark.yaml`. It conforms to cqa,
not to wine: the records below are instances of cqa's
`CompetencyQuestionAnswer`, and every wine record they mention is reached
by reference rather than copied in: each `expected_anchors` value {{#callout anchor}} is a
bare id, expanded against the target namespace (`target_schema`) {{#callout target}} the file declares exactly
once.

{{#include listings/wine-benchmark-v1.yaml}}

Six records, not seven. CQ 1 ("which characteristics should I consider?")
has no row because Chapter 7 answered it with the schema itself: the
`Wine` class carries `color`, `body`, `flavor`, and `sugar` before any
instance exists. There is no record to anchor and no honest way to invent
one, so a retrieval benchmark cannot express the question. The file says
so in a comment; the omission is a finding about what this kind of
benchmark covers, not a slip.

The claims are about one graph at one version, and the `target_schema`
and `target_dataset` fields {{#callout target}} pin both.
`answer_kind` {{#callout kind}} names the check a correct answer must
survive (a `lookup` is one hop to a value, a `synthesis` is a pattern no
single record states), and CQ 7 carries two kinds at once
{{#callout two-kinds}}, because "2018 was
good" is worse than "the regional vintage chart rates 2018 good," and
dropping either the comparison or the attribution makes the answer
weaker.

CQ 3's answer is an absence, and `unconnected_anchors` states *which*
absence {{#callout absence}}: it is not enough to anchor the wine and
the dish, because a consumer of the answer cannot tell "correctly found no pairing"
from "retrieved nothing" unless the claimed gap is named.
`connecting_class` narrows the claim {{#callout via}} to exactly what
Chapter 7's prose said: no `PairingRecommendation` joins them. And
`expected_citations` {{#callout citation}} only ever names judgment-side
records, because the recommendation carries the rationale,
source, and confidence an attributed answer rests on; the reference-side
entities (wines, foods, vintages) anchor but never cite.

## Two schemas, two graphs, one manifest

The benchmark enters `panschema.toml` as a second schema with its own
dataset, beside wine's. The manifest now composes a *system* rather than
listing outputs: wine's schema with its catalog, cqa's with the
benchmark, and references crossing from one graph into the other.
Verification covers the composition (each graph against its own schema,
plus what must hold at the crossing):

{{#include listings/panschema-toml-v1.toml}}

The contract is a released dependency {{#callout dep}}: `source` says
where it is published and `version` pins the release. `panschema fetch`
resolves the pin once, downloads the tagged release into a local cache,
and writes `panschema.lock`, which records the checksum the pin resolved
to and is committed beside the manifest. From then on every run of
`verify` and `generate` reads the contract the lockfile names, and CI
runs `fetch --check` first: a fetch that drifts from the lockfile fails
before the checks start. Moving to a later release is one edit to
`version` and one re-run of `fetch`, and verification against the new
contract says whether the benchmark still conforms to it. The entry
also publishes the benchmark as a self-contained knowledge graph
{{#callout artifact}} next to `wine.ttl`.

The `[check.cqa]` block declares what must hold at the crossing, and
wine cannot delegate it. An anchor is an external
reference, and panschema deliberately exempts external references from
its dangling check: a benchmark's whole shape is pointing into a graph
it does not contain. Whether those references actually *resolve* is a
question about the graph *pair*, answerable only where both graphs
exist, which is this repository and nowhere else. `resolve_against`
{{#callout resolve}} checks every anchor against the IRIs wine's
datasets mint, and `require_namespace_coverage` {{#callout coverage}}
closes the remaining hole: mistype the target base by one character and
all twenty-eight references expand into a namespace no entry covers,
which is rejected rather than passed as "external, unchecked."

Nothing in the block configures the absence check. That is on purpose:
a consumer does not get to decide what a benchmark record means.
cqa's schema declares, on the slot itself, that
`unconnected_anchors` carries an absence claim and that
`connecting_class` narrows it, the way `identifier: true` is declared
where the slot is defined rather than in every file that uses it. The
verifier reads the meaning from the contract, so every consumer runs
the same check; there is no per-repo binding to get wrong. The absence
claim is then discharged the same way the dangling check tests a
positive reference: "this record exists over there" and "no record over
there joins these" are both statements about the referenced graph.

The manifest keys themselves know nothing about benchmarks: they would
hold any pair of schemas whose graphs reference each other (two
catalogs sharing a vocabulary, an inventory pointing into a registry).
Cross-graph verification is the general capability; the benchmark is its
first customer, the same way this book's earlier chapters were the
first customer of `default_range` resolution and the rule syntax. One
command runs all of it from the manifest, writing nothing:

```console
$ panschema verify --strict
Using manifest: panschema.toml
note: 28 cross-graph reference(s) leave this dataset and are not checked here:
  `cq-02` references `https://w3id.org/wine-linkml/bordeaux-wine` via `expected_anchors`
  `cq-03` references `https://w3id.org/wine-linkml/cabernet-sauvignon` via `expected_anchors`
  ... (26 more lines, one per outbound reference)
note: schema `cqa`: 28 of 28 cross-graph reference(s) into `wine` namespace(s) resolve
note: schema `cqa`: 1 of 1 stated absence claim(s) hold against `wine`
note: schema `cqa`: 2 of 2 version pin(s) agree with `wine`
```

The output looks like it contradicts itself ("not checked here," then
"28 of 28 resolve"). It comes from two passes with different scopes. The first verifies the benchmark as one dataset
against its schema, and a dataset is a single instance file: within it,
records reference each other by bare id, and those references are
checked for dangling targets. An anchor is the other kind of reference:
before anything reads it, the bare id expands against the declared
target namespace into an IRI pointing at a record in a *different*
dataset (`napa-zinfandel-2017` is a record in `data/wine-instances.yaml`,
minted into that same IRI under wine's schema). The expansion is also
why the console output above shows full IRIs for values the file writes
in one word. A file-scoped pass cannot resolve those references, and in
the general case never could: a benchmark normally points at a graph
that lives in another repository altogether. So it enumerates them
instead (the benchmark's entire claim on the catalog, one line per
reference; the same record IRI can appear on several) and hands off. The three notes after it are the `[check.cqa]` pass, which
exists because this repository is the special case where the target
graph is on hand: it loads wine's datasets, mints their IRIs, and
discharges the list. Every reference resolves, the stated absence
holds, and the two versions the benchmark pins are the ones wine's
package declares.

Each of the four gates (resolution, the absence, namespace coverage,
the version pins) was made to fail once during authoring and caught
each time. The
failure modes themselves are the `panschema` and `cqa` toolchain's to test, 
and its suite pins them; this chapter shows the passing run, which is the state every
push must reproduce.

## What keeps it true

"Checking the benchmark" can mean two different things, and only one
of them happens in this repository. `verify --strict` checks the
answer key itself: every record the key points at exists, and the one
claim it makes about the graph's shape holds. Nobody here answers the
questions; that is what the benchmark's other fields are shaped for,
and it is out of scope for this book. The closed-world negative is the
boundary case: its correct answer *is* the key's claim about the graph,
so verifying the claim is as close to answering the question as
verification gets. For the other kinds, the ground truth's content
stays a prose claim (nothing checks that `bordeaux-wine` is in fact
`red`).

```admonish note title="Verification and validation"
Systems engineering keeps these words apart: verification asks whether
the thing was built right (the artifact matches its specification),
validation asks whether the right thing was built (it serves the
need) — solving the equations right versus solving the right equations
([Roache 1997](https://doi.org/10.1146/annurev.fluid.29.1.123)). This
book uses the terms strictly, and the tool's verb agrees: everything
`panschema verify` does is verification. Chapter 7 said "validation,"
following the data-engineering convention (SHACL produces "validation
reports," JSON Schema tools are "validators," LinkML ships
`linkml-validate`) — a parallel, older sense of the word that is fine
in tools whose scope holds no validation in the strict sense. This
stack holds both activities, so it needs both words: the verb was
renamed once the distinction started doing real work, and the
neighboring formats keep their own names. Validation in the strict
sense is the litmus test itself: the competency questions are the
ontology's requirements, and answering them from the graph is the
evidence the right ontology was built. Chapters 7 and 8 ran that test
by hand; nothing in this chapter runs it by machine.
```

CI runs the manifest-wide verify on every push, so the litmus test that
was a section of prose is now a gate: an anchor that stops resolving, or
an absence that stops holding, fails the build before anything publishes.

The failure that gate cannot see is the quiet one. *Removing* a record
breaks an anchor loudly; *changing* one breaks nothing visible. Correct
the 2018 vintage assessment's verdict from `good` to `average` and CQ 7's
anchors still resolve, its citations are still anchors, verification still
passes — and the benchmark's ground truth is simply wrong. The pinned
target versions exist for exactly this failure, and they are checked,
not just declared: cqa says on each version slot which sibling it
records, and the verifier compares the pin with the version wine's
package actually declares. A pin that falls behind fails the strict
run. That sets a standing rule for this repository: any catalog edit
that could change an answer bumps the package version, corrections
included, and the bump keeps the build red until the benchmark has
been re-read against the new graph and re-pinned. A consumer pinning
the old version and a consumer reading `main` may then disagree about
what the benchmark asserts, but each knows which claim it holds.

## The version, decided

Implementing the benchmark changed nothing in `schema/wine.yaml`. The
demand ran the other way: wine's questions pulled cqa's model into
existence, and wine's own model already held every record the answers
anchor. So `v0.2.0` stands.

A bump was considered anyway, for the *package* (it now ships a third
dataset), and rejected. The schema's `version:` field is ontology
metadata: it becomes `owl:versionInfo` in the published artifact, so
stamping a new version on an unchanged model would announce a change
that did not happen. And the falsification rule above governs edits
that change answers; adding the benchmark changes none (the benchmark
targets `0.2.0`, and every claim in it was verified against that
graph). The benchmark rides the bleeding edge until the next release
whose model actually changes, which will carry it into a version.

## Two pages

The published site now carries two schema-docs pages. Wine's own page is
unchanged. The new page renders the *contract's* schema with wine's
benchmark as its instance graph (the records lead, cqa's reference
section follows) under `schema/cqa/`. Today it exists only at the
bleeding edge (`schema/cqa/main/`), because no released version of the
package contains the benchmark; the first release that does will give it
the same version dropdown and `current/` alias as the main page. The
book's toolbar button becomes a menu with an entry for each.

The pages are meant to be read side by side. Every anchor on the
benchmark page is a record on the catalog page, and checking that
correspondence by eye is how the benchmark was authored; the
`[check.cqa]` gates re-check it on every push. The pair also shows the division of labor at a glance: one page
holds what the catalog says, the other holds what a correct answer about
it must reach.

## Where it stands

The schema stands at `v0.2.0`, untouched. Six of the seven competency
questions are now records whose answer key a machine keeps sound on
every push; the seventh is answered by the schema and stays prose, which
is the right home for it. The contract freezes this same file as the
worked example in its own book: one benchmark serving two ontologies,
each the demand for the other.
