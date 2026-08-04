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

```yaml
{{#include listings/unjustified-verdict-v1.yaml}}
```

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

```yaml
{{#include listings/bad-id-v1.yaml}}
```

is caught before it can become one:

```console
$ panschema validate --schema schema/wine.yaml --data data/invalid/bad-id.yaml
instance `Zinfandel_Grape`: slot `id` (class `Grape`) value `Zinfandel_Grape` does not match pattern `^[a-z0-9]+(-[a-z0-9]+)*$`
```

It projects everywhere the schema does — a SHACL `sh:pattern`, a JSON Schema
`pattern`, a Postgres `CHECK` — for the cost of one line.

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

## Where it stands

The schema is tagged `v0.2.0`. None of these refinements is a new N&M step; each
came from using the ontology, not from the method. That is the second rule —
development is iterative — exercised through use.
