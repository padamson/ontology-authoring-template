# Instances and Validation

This chapter demonstrates **Step 7** of [*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(Noy & McGuinness, 2001 — "N&M"). It is where the schema gains its
first instance graph. The last step creates **individuals** (instances
of the classes, the nodes of a graph that conforms to the schema),
validates the graph against the schema, and tests whether it can answer
the [Chapter 1 competency questions](ch01-domain-and-scope.md#competency-questions).

```admonish quote title="Noy & McGuinness 2001 — §Step 7"
The last step is creating individual instances of classes in the
hierarchy. Defining an individual instance of a class requires (1)
choosing a class, (2) creating an individual instance of that class, and
(3) filling in the slot values.
```

## A small example instance graph

A small instance graph can illustrate the shape of the schema. An
**individual** node in the instance graph is an instance of a class,
while an **edge** is a slot whose value is another individual. The
following instance graph contains just four individuals and the edges
between them, but it is enough to illustrate the concept:

{{#include listings/wine-preview-v1.yaml}}

The Chateau Morgon Beaujolais wine is one node. Gamay, the Chateau Morgon
winery, and the Beaujolais region are three more. The `made_from_grape`,
`maker`, and `region` edges connect them. `color: red` is a value the
wine carries, not an edge, because it points at an enumerated hue rather
than at another record. That is the whole idea: the individuals are nodes,
the object-valued slots are the edges between them, and the scalar slots
are labels on a node.

The graph above is a small preview, not a fully worked example. It holds
the fewest records that can illustrate an *individual*, a *node*, and an
*edge*, and it lives in its own data file, `data/wine-preview.yaml`. The
full catalog (large enough to answer all seven competency questions) is a
separate, larger data file, built up over the rest of this chapter and
reproduced in [Appendix A](appendix-a-worked-example.md).

## What a data file needs that a schema did not

Three additions had to land before the first instance could be written,
and one of them was a mistake the litmus test caught before it was even
run.

The first is a **container**. A data file needs a single root record to
hang everything else on, and the schema had none: the classes were all
domain things, no vessel to hold a catalog of them. N&M never needed one
because their tool (Protégé) *was* the container, its project file the
implicit root. A plain data file has no such ambient vessel, so the
schema grows a `WineCatalog` class marked `tree_root`, holding a
collection for each kind of record. It is an honest adaptation of the
method to a file-based workflow, not a modeling insight about wine.

The second is **identifiers**. Chapter 5 said instances would be keyed
by their name, and building the data file refined that. A name is a
human label ("Chateau Morgon Beaujolais"), but records have to reference
each other (a wine names its maker, a recommendation names its wine),
and a reference wants a short, stable, punctuation-free key, not a
display string. So every class gains an `id` slot marked `identifier`,
and `name` stays the label. It is the same move N&M's own tooling makes
under the hood; the data file just makes it explicit.

The third addition was forced by the test itself, before it ran. Laying
the seven competency questions against the roster, CQ 7 ("What were good
vintages for Napa Zinfandel?") had no answer the schema could give.
Worse, [Chapter 1](ch01-domain-and-scope.md#what-it-does-not-model) had
put "price, ratings, and reviews" explicitly *out* of scope. The two are
in flat contradiction, and the contradiction was ours: the exclusion
list was written against an earlier draft of the scope and never
re-checked against N&M's seven questions when Chapter 1 was rebuilt
around them. This is exactly the failure the competency questions exist
to catch, and it is worth leaving on the record rather than quietly
patching Chapter 1, because catching it *here* is the method working as
designed.

N&M's second rule is the remedy: ontology development is iterative. The
fix refines the exclusion instead of reversing it. A consumer's catalog
reviews and prices stay out; a *sourced judgment of a vintage's quality*
is a different thing, and the schema already has the shape for a recorded
judgment. So a `VintageAssessment` joins `PairingRecommendation` as a
second information content entity: a verdict about a vintage-specific
wine, carrying its source and confidence exactly as the pairing does.

The growth against the Chapter 6 snapshot:

{{#diff wine-yaml-v4 wine-yaml-v5 context=6}}

`VintageAssessment` {{#callout assessment}} mirrors the pairing
recommendation, `WineCatalog` {{#callout catalog}} is the file's root,
and the `id` slot {{#callout ids}} records the name-to-identifier
refinement. The diff also shows the schema's own `description` growing
shorter; that is a different kind of finishing work, and the last section
returns to it.

## The worked example

N&M close their guide with a single instance: a Chateau Morgon
Beaujolais, red, light-bodied, delicate, dry, made from the Gamay grape
by the Chateau Morgon winery in the Beaujolais region. This book
reproduces it faithfully, with one difference the demand-driven build
made inevitable. N&M's instance also carries a tannin level; this schema
has no tannin slot, because no competency question ever asked about
tannin. The instance drops the value rather than the schema growing a
slot to hold it: the demand-driven rule (a slot exists because a
question needs it) applied to the very last step.

Around that anchor, the catalog grows to the size the seven questions
need: five grape varieties, three regions, three wineries (including
N&M's own Sterling Vineyards, whose Merlot was their example of a wine
kind as an instance), the 2017 and 2018 Napa Zinfandel as two
vintage-specific kinds differing in body, three foods, three pairing
recommendations with their rationales, and two vintage assessments. The
complete catalog is [Appendix A](appendix-a-worked-example.md). Those counts
describe the catalog as this step built it; a later chapter (past the first
tagged release) grows the worked example to exercise schema constructs and
checks the seven questions never demanded, so the Appendix A you can browse
is richer than the tally here.

This catalog is *an* instance graph conforming to the schema, not the
only one. The schema is the reusable model; an instance graph is one
dataset built on it, and the same schema would hold a different
sommelier's catalog, a small test set, or a production graph of thousands
of wines, each an independent instance graph validated against the schema
the same way. This one is deliberately small: large enough to answer the
seven questions, and small enough to read whole. The published schema page
carries both this catalog and the chapter's opening preview behind a
selector, so the four-record teaching graph and the full worked example
sit a click apart, each rendered as its own graph of individuals and
edges. This catalog is the one the page opens on (the exemplar).

## Validation

The data file is a claim: that every record conforms to the schema built
over the last four chapters. The claim is checkable, natively, with no
tooling outside the one that generates the docs:

```console
$ panschema validate --schema schema/wine.yaml --data data/wine-instances.yaml
data/wine-instances.yaml conforms to schema/wine.yaml
```

Here Chapter 6's constraints start to bite. `validate` checks
every facet the schema declares: that each wine has the required grape
and each judgment its required wine, that `confidence` sits in `[0, 1]`,
that `color` is one of the three enumerated hues and `verdict` one of the
four, that every `maker` and `region` reference resolves to a record that
exists, and that no two records share an `id`. A mistyped `verdict: goob`
fails with a named diagnostic, not a silently broken graph:

```console
$ panschema validate --schema schema/wine.yaml --data data/invalid/bad-verdict.yaml
instance `va-2018`: slot `verdict` (class `VintageAssessment`) value `goob` is not a permissible value of enum `VerdictEnum`
Error: 1 validation error(s) in data/invalid/bad-verdict.yaml
```

A `made_from_grape` pointing at a grape that was never defined is caught the
same way. These broken fixtures live in `data/invalid/` and are asserted to
*fail* in CI, so the rejection is a tested claim rather than a promise. The
constraints were worth declaring precisely because this step enforces them.

## The litmus test

Chapter 1 set out the competency questions as the litmus test for the
finished ontology. Here they are, each answered against the catalog.

**CQ 1: Which wine characteristics should I consider when choosing a
wine?** Answered by the schema itself, before any instance: the `Wine`
class carries `color`, `body`, `flavor`, and `sugar`, plus its grape,
region, maker, and vintage. The question is about the *model*, and the
model answers it.

**CQ 2: Is Bordeaux a red or white wine?** The `bordeaux-wine` record
has `color: red`. A lookup by name, one hop to a value.

**CQ 3: Does Cabernet Sauvignon go well with seafood?** No pairing
recommendation links the Cabernet Sauvignon to a seafood dish, and none
is inferable. The honest answer is "none on record": the closed-world
reading, where absence of a recommendation is not evidence against the
pairing, only absence of a claim for it. The graph says what it knows and
no more.

**CQ 4: What is the best choice of wine for grilled meat?** The
`pr-cabsauv-grilledmeat` recommendation names the Cabernet Sauvignon,
with confidence 0.9 and the rationale that its tannins bind the fats and
proteins of grilled red meat. The Chapter 2 decision pays off here: a
bare `goes_well_with` edge could have answered *which* wine; the reified
recommendation answers *which, why, on whose word, and how sure*.

**CQ 5: Which characteristics of a wine affect its appropriateness for
a dish?** No single record answers this; the answer is a pattern across
the three recommendations' rationales: tannin against protein, acidity
against delicate seafood, a light body's versatility with white meat.
A query gathers the three rationales, but it can't generalize across
them; the next section takes that up.

**CQ 6: Does a wine's bouquet or body change with vintage year?** The
2017 and 2018 Napa Zinfandel are two `Wine` records sharing grape,
region, and maker but differing in vintage, and in body: medium against
full. Chapter 5's answer to the same worry, made concrete: vintage
variation lives in vintage-specific kinds, not in a single kind whose
values somehow change.

**CQ 7: What were good vintages for Napa Zinfandel?** The question that
forced `VintageAssessment` into the schema. Two assessments name the two
vintages: 2018 is `good`, 2017 `average`, each with its source and
confidence. The vintage the question asks after is answerable now, and
answerable *with attribution*: not "2018 was good" but "the regional
vintage chart rates 2018 good."

Seven questions, seven answers the graph supports. The one that comes up
short of a clean query answer, CQ 5, is short in an instructive way, and
it is where the graph's real purpose comes into focus.

## The graph this was always about

The schema rendered as RDF is the model; the catalog is an instance graph
built on it; together they are a knowledge graph. The individuals (the
wine kinds, foods, grapes, regions, wineries, and vintages) are its
nodes; the provenance slots are its edges, and the two judgment classes
are individuals that sit *between* other nodes, carrying the rationale a
plain edge could not. Every decision in this book was made to make an
instance graph on this schema answer questions well. [Chapter 1](ch01-domain-and-scope.md) named the use;
[Chapter 2](ch02-reusing-existing-ontologies.md) grounded the pairing as
a recommendation so it could hold a rationale;
[Chapter 3](ch03-important-terms.md) held the term list to what the
questions reached for; [Chapter 4](ch04-classes-and-hierarchy.md) made
wine kinds the nodes so a recommendation could point at them;
[Chapter 5](ch05-slots.md) reified the pairing and skipped inverses
because a graph traverses both ways on its own; and
[Chapter 6](ch06-slot-usage-and-facets.md) constrained the values so a
query could count on them. The
"validated artifact" of this chapter and the deployable knowledge graph
are the same bytes.

CQ 4 shows what that buys a workflow that answers questions over the
graph. Asked for a wine to serve with grilled meat, such a workflow does
not guess: it retrieves the subgraph around grilled meat (the
recommendation node, the wine it names, the rationale, the source, the
confidence) and hands that to a language model as grounding. The answer
it produces is not a plausible-sounding invention but a reading of what
the graph records, and it can cite the node it came from. CQ 5 is the
same move one step further: retrieval gathers the recommendation
rationales, and the model reads the pattern across them that no single
node states. A bare wine-to-food edge holds none of that. Reifying the
pairing put something there to retrieve.

Chapter 1 said this ontology would be maintained by the developer
building such a workflow on top of it. This chapter hands them the
foundation: a schema pinned to a version, one instance graph whose
competency questions are on the record as answered, and the query
patterns the litmus test just walked through. Their own instance graph
(their catalog, their production data) is a different, larger graph over
the same schema, validated the same way and queried by the same patterns.
The exemplar proves the shape; their data fills it.

## What the build got right, and what it deferred

The lesson N&M leave for last is that the worked example should have
driven the build from the start, not arrived at the end to validate it.
It did. Every class traces to a competency question or the domain N&M
set; every slot to a question that needed it; the tannin level that N&M's
own instance carried never entered the schema because nothing asked for
it, and CQ 7 forced a class into being the moment the roster met the
questions. Nothing in the schema is here only because this chapter needed
it: the mark, N&M warn, of a build that reasoned backward from its data.

Two questions the earlier chapters deferred to this one can now be
answered from the worked example. The first: whether a grape variety is
better modeled as a recorded designation than as an instance. In
practice, instances of `Grape` carried the weight the competency
questions put on them (a wine names its varieties, a variety is looked
up by name), and nothing asked the variety to behave like a document that
is authored, versioned, or copied. The simpler reading held; the
designation view stays a note for an application that needs it, not a
complication this one paid for.

The second: whether the pairing recommendation, and now the vintage
assessment, belong in this ontology at all, or in a companion ontology of
judgments layered over it. The worked example makes the case for keeping
them: both are small, both reuse the same information-content-entity
grounding, and both are exactly what the graph is queried *for*. The
signal to split would be a recommendation layer that grew its own
vocabulary (provenance chains, confidence models, competing sources
reconciled), heavy enough to fight the wine modeling around it. That is
the companion-ontology smell this book has watched for since Chapter 2,
and the wine ontology has not reached it, so the judgments stay.

One last edit is not about wine at all. Through the build, the schema's
`description` announced how it was made: grounded in BFO and CCO,
following a method, adapted to LinkML, documented by this book. A finished
artifact answers to whoever loads it, not to how it was built, and that
description ships into every generated doc and downstream graph. So it now
states only what the ontology is about and what it is for. The grounding
is still legible to anyone who reads the structure (the prefixes, the
`subclass_of` links), and the method is still here, in this book; neither
needs to ride along in the metadata.

The schema is complete, the graph is built, and the questions Chapter 1
asked are answered. The ontology is ready for the workflow it was always
being built for.
