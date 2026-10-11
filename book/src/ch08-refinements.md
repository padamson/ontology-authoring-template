# Refinements

The seven N&M steps are done, and the schema carries a `v0.1.0` tag. But an
ontology is not finished when its first version ships — N&M's second fundamental rule in ontology design is
that development is iterative. Using the schema, with real instances and a
release behind it, turned up a handful of refinements. A few tighten the model with a constraint
it lacked; others exercise a value it declared but never used.

```admonish quote title="Noy & McGuinness 2001 — some fundamental rules in ontology design"
Ontology development is necessarily an iterative process.
```

## Justifying verdicts at the extremes

Chapter 6 reified the vintage assessment: rather than hang a quality value off
a wine, a `VintageAssessment` records a *judgment* about it, carrying the
`source` and `confidence` a bare attribute could not. Through v0.1.0 the
reification was only half-used. Nothing stopped a record from claiming
`verdict: exceptional` with no reason given — the strongest judgment the schema
allows, backed by a source name and a number, but no account of *why*.

An extreme verdict is exactly the one that should show its work. This chapter
adds a `rationale` slot to the assessment (the pairing recommendation already
had one, so the assessment reuses it), and a rule: when the verdict is
`exceptional` or `poor`, the rationale is required.

{{#diff wine-yaml-v5 wine-yaml-v6 context=6}}

The rule {{#callout rule}} is a conditional constraint: a *precondition* on the
verdict, a *postcondition* on the rationale. An average or good vintage needs no
defense, and the rule stays quiet. An exceptional or poor one fires it, and a
missing rationale becomes an error rather than an oversight. Here is an
assessment that trips it:

{{#include listings/unjustified-verdict-v1.yaml}}

`validate` rejects it and names the rule that caught it:

```console
$ panschema validate --schema schema/wine.yaml --data data/invalid/unjustified-verdict.yaml
instance `va-2018`: rule `#1` (class `VintageAssessment`) applies, but slot `rationale` is required but absent
Error: 1 validation error(s) in data/invalid/unjustified-verdict.yaml
```

Supply the reason and the record conforms. The rule cannot ask for a *good*
rationale — a validator has no way to judge that — only that a claim deviating
from the average carry one. That is a low bar, and the point: the reified
judgment now enforces its own minimum standard of evidence.

## Every value the catalog can hold

The Step-7 catalog was deliberately small, sized to the seven competency
questions and no larger. One side effect was that several enumerated values sat
declared but unused: the schema admits a `rosé` wine, an `off-dry` or `sweet`
one, and an `exceptional` or `poor` verdict, but no record reached for them.
They were present in the model and absent from every picture of it.

This chapter grows the worked example to exercise them: a dry Provence Rosé, an
off-dry Mosel Riesling, a sweet Late Harvest Riesling, and — the records the new
rule governs — an exceptional assessment of the late-harvest wine and a poor one
of the rosé, each with its rationale. Appendix A holds the grown catalog, and
the published instance graph now shows the full range of colors, sweetness
levels, and verdicts the schema always allowed.

This departs from the demand-driven rule that has governed the build since
Step 1: none of these records answers a competency question. It is worth being
honest about the trade. They exist to exercise the schema's own vocabulary and
the tooling that renders it, not to serve the pairing application. A production
ontology would add them only when a question needed them; a *showcase* adds them
so the reader can see every construct in use.

## Identifier hygiene

Every `id` in the catalog has followed one shape by convention — lowercase,
words joined by hyphens (`napa-zinfandel-2018`, `va-2017`). The convention was
followed but never stated. A pattern states it {{#callout pattern}}, and an `id`
is minted into an IRI, so a stray space or a capital is not a style nit but a
broken identifier. A record with a malformed `id`:

{{#include listings/bad-id-v1.yaml}}

is caught before it can become one:

```console
$ panschema validate --schema schema/wine.yaml --data data/invalid/bad-id.yaml
instance `Zinfandel_Grape`: slot `id` (class `Grape`) value `Zinfandel_Grape` does not match pattern `^[a-z0-9]+(-[a-z0-9]+)*$`
```

It projects wherever the schema goes — a SHACL `sh:pattern`, a JSON Schema
`pattern`, and the check above — for the cost of one line.

## What was left out

Refinement is as much about what not to add. Three constructs were weighed and
left out on the same test that kept the rule and the pattern — does it improve
the model, or only exercise a feature — each waiting on a demand the curated
catalog does not yet make:

- **`meaning:` on the enum values** would ground a permissible value to an
  external IRI, the way a class grounds with `subclass_of`, carrying the
  grounding thesis to the leaves — but the leaves have no honest anchor, since no
  maintained vocabulary names "the color red as a wine characteristic" or a
  subjective "exceptional." It would fit a value that does, once two graphs need
  the same IRI to line up.
- **`unique_keys`** on (winery, name, vintage) restates a uniqueness the `id`
  already guarantees — until records arrive from data the author does not
  control, where a duplicate wine becomes a risk the `id` cannot catch.
- **`ifabsent`** needs a slot with a sensible default, and none here has one.

## The litmus, revisited

The seven competency questions still hold against the grown catalog, and the new
records extend a few of the answers. CQ 2 ("is Bordeaux red or white?") is
unchanged — a lookup is a lookup. But a question over the color or sweetness
range now sees more than reds, whites, and dry wines: it sees a rosé and a sweet
one too. CQ 7 ("what were the good vintages?") gains the exceptional late-harvest
Riesling — and, because of the new rule, gains it with a reason attached, which
is the shape a retrieval-augmented answer wants. The questions did not change;
the catalog answers them more fully.

## Saying the range once

Even though the schema declared `default_range: string`, four slots
(`id`, `name`, `rationale`, `source`) repeated the `range: string` declaration.
We've removed the four redundant entries, so a `range:` line now means that
the slot differs from the default.

{{#diff wine-yaml-v6 wine-yaml-v7 context=4}}

(The version line is the `v0.2.0` release bump catching up. The v6 listing was
frozen just before the tag.)

This waited on the toolchain. Until
[panschema#89](https://github.com/padamson/panschema/issues/89), only the JSON
Schema writer honored `default_range`. The RDF, the SHACL shapes, and
`validate` ignored it, so the terse style would have shipped datatype properties
with no range at all. The fix resolves the default into the slot definitions
when the schema loads, and the regenerated artifacts are byte-identical to
before the deletion.

## Records or references

Every class in the catalog carries an `id` slot declared `identifier: true`. In
LinkML, a slot whose range is such a class holds *references* by default: id
strings that point at records defined somewhere else. That is the right reading for `maker` on a wine, which names a winery by
its `id` rather than describing it again. It is the wrong reading for the
catalog's own collections, because the catalog is where every record is
defined. The data file writes each one out in full under `wines`, `grapes`, and
the rest, and the schema said those slots held ids.

The two disagreed from Step 7 on, and nothing said so. panschema read each value
by its shape, a mapping as a record and a string as a reference, so the catalog
validated clean. LinkML's own validator does not read it that way: run against
the v7 schema, `linkml-validate` rejects all 37 records in the worked example,
each with `is not of type 'string'`.

The leniency was panschema's. It tests its own reading of LinkML against the
reference validator, and when that testing was extended to cross every inlining
declaration with every way of writing the data, the shape-based reading turned
out to accept what LinkML rejects. [panschema
`1145325`](https://github.com/padamson/panschema/commit/1145325) brought the two
into line, and `verify` now reports the mismatch, once per collection:

```console
$ panschema verify --strict
warning: data/wine-instances.yaml: instance `(root)`: slot `wines` declares references to `Wine` (neither `inlined` nor `inlined_as_list`), but 10 records are authored inline there; declare `inlined_as_list: true` for a list of records or `inlined: true` for a dict keyed by id, or author the ids and define the records in their own collection
…
Error: 8 schema or conformance finding(s); failing because --strict is set
```

and under `--strict` the build stops there. The fix is necessary on both
counts: the schema was wrong about its own data under the reading LinkML
defines, and the gate that keeps the published catalog conforming can no longer
pass until the schema says what the data does. Each collection on `WineCatalog`
declares `inlined_as_list: true` {{#callout inline}}, which tells LinkML to
expect a list of whole records. The
other class-ranged slots (`maker`, `region`, `made_from_grape`, `vintage`, and
the `wine` and `food` a judgment is about) still hold references, and declare
nothing.

{{#diff wine-yaml-v7 wine-yaml-v8 context=4}}

(The version line is the `v0.2.1` patch release this refinement prompted; the
next section says why.)

The data did not change, and neither did anything panschema generates: the
Turtle, the SHACL shapes, the JSON Schema, and the instance graph are
byte-identical before and after, because panschema's writers already read the
collections as records. What changed is LinkML's reading: the 37 errors are
gone, and the schema says in its own terms which slots define a record and which
point at one.

## Where it stands

The schema is tagged `v0.2.1`. "Saying the range once" changed nothing a
consumer of the schema could see, so it rode the bleeding edge without a
release. "Records or references" is different. The Turtle, the shapes, and the
JSON Schema panschema generates are the same before and after, but a reader who
takes the schema to LinkML's own validator or generators gets a different result
with the declaration than without it, and `schema/current/` should point at the
version that loads the catalog. A patch release does that.

(The benchmark Chapter 9 builds pins the version its claims were verified
against, so its two pins move to `0.2.1`, and every claim re-verifies against
the new version. `v0.2.1` is also the first release whose package contains the
benchmark, so its page gains a `current/` alias too.)

None of these refinements is a new N&M step; each came from using the ontology,
not from the method. That is the second rule —
development is iterative — exercised through use.
