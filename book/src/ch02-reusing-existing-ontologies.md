# Reusing Existing Ontologies

This chapter works **Step 2** of [*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(Noy & McGuinness, 2001 — "N&M"). Step 2 asks what to reuse before building
anything new. It is where this book's grounding in BFO and CCO stops being a
claim and becomes a decision for each concept the competency questions named.

```admonish quote title="Noy & McGuinness 2001 — §Step 2"
It is almost always worth considering what someone else has done and
checking if we can refine and extend existing sources for our
particular domain and task. Reusing existing ontologies may be a
requirement if our system needs to interact with other applications
that have already committed to particular ontologies or controlled
vocabularies. [...] There are libraries of reusable ontologies on the
Web and in the literature. [...]

For this guide however we will assume that no relevant ontologies
already exist and start developing the ontology from scratch.
```

## Taking the advice N&M skipped

N&M are emphatic that reuse is worth considering, and they point at the
ontology libraries of their day (Ontolingua, DAML) and commercial
vocabularies (UNSPSC, RosettaNet). Then, for the guide, they set all of it
aside and start from scratch.

This book does the opposite, and the reason is the twenty-five years since.
[BFO](introduction.md#jargon-bfo-and-cco) is now an ISO standard (ISO/IEC
21838-2:2020), and CCO is a maintained mid-level layer on top of it.
Grounding in them is the whole point of this build, so where N&M started
from scratch, we take the advice they gave and reuse.

## What we reuse, and what we invent

Reuse runs at two layers, and they get opposite decisions:

- **The foundation: reuse.** Every concept grounds into BFO (the top-level
  categories) and CCO (mid-level classes like Organization and Geospatial
  Region), referenced by URI.
- **The domain: invent, but grounded.** A well-known wine ontology exists
  (the W3C OWL Guide's, itself a descendant of N&M's example), and we could
  import it. We don't. Importing a domain ontology inherits its modeling
  choices wholesale; building the wine classes ourselves, each one placed
  under the right BFO or CCO parent, is the skill this book is about.

A note on what is *not* available: we checked the OBO Relations Ontology and
all 263 of CCO's object properties for an off-the-shelf "pairs with" or "is
appropriate for" relation. There isn't one. The pairing at the heart of
N&M's example has to be modeled, not borrowed (more on that below).

```admonish note title="Jargon: the BFO categories we ground to"
A handful of BFO 2020 categories carry most of the groundings below. A
**material entity** is a thing made of matter (a wine, a grape). An **object
aggregate** is a material entity made of member objects (an organization is
a group of people). A **quality** is a way a thing is that you can observe
directly (a color, a weight). A **disposition** is a tendency to behave a
certain way under the right conditions (fragility; or color, when CCO treats
it as an optical property). A **site** is an immaterial place (a region). A
**temporal region** is a stretch of time (a year). An **information content
entity** is something that is *about* other things and can be recorded and
copied (a recommendation, a label).
```

## The reuse table

Every entity, quality, and relation the
[competency questions](ch01-domain-and-scope.md#competency-questions) demand,
and where it grounds:

| Concept | Grounds to | Reuse / invent |
|---|---|---|
| Food, dish | CCO Portion of Food (`cco:ont00000307`) | reuse |
| Wine | CCO Portion of Processed Material (`cco:ont00001084`) | reuse |
| Wine region | CCO Geospatial Region (`cco:ont00000472`) | reuse |
| Winery | CCO Organization (`cco:ont00001180`) | reuse |
| Grape | BFO object (`obo:BFO_0000030`) | invent |
| Color, body, sugar, flavor | BFO quality (`obo:BFO_0000019`) | invent |
| Vintage (the year) | BFO one-dimensional temporal region (`obo:BFO_0000038`) | invent |
| Wine-food pairing | a CCO information content entity (a recommendation) | invent |

Three of these took a real decision, and they are where verifying the
*category*, not just that the IRI resolves, earns its keep.

**Wine grounds to a processed material, which makes it an artifact.** CCO
offers no generic "portion of liquid," and its food and material classes all
sit under Material Artifact: "a Material Entity designed by some Agent to
realize a certain Function." Grounding wine under Portion of Processed
Material therefore commits us to wine being a *designed artifact*. That is a
real commitment, but a defensible one: a wine is a deliberately produced
material, fermented and blended to be drunk, not a found portion of liquid.

**Color is a quality here, not the disposition CCO makes it.** CCO models
`Color` as an *optical property* (a disposition to interact with
electromagnetic radiation). That is a principled treatment of color in
general, and we diverge from it deliberately. Wine color is not used as an
optical fact; "red," "white," and "rosé" are categorical descriptors of the
wine, and a wine's color is not purely optical anyway: it reflects the
grape, the skin contact, and the age. So we model wine color as a BFO
**quality** the wine bears, and accept that this departs from CCO. Body,
sugar, and flavor have no CCO class at all and ground straight to BFO
quality.

**The pairing is a recommendation, not a relation on the wine.** It is
tempting to make "pairs with" a disposition the wine carries, but a wine
does not bear a real tendency to suit seafood the way it bears a color. A
pairing is a *claim*: a sommelier's recommendation about a wine and a dish.
We ground it as an information content entity that is *about* the pair. For
the knowledge graph this ontology is built to feed, that earns its keep: a
recommendation node can carry the rationale, the source, and a confidence
that a bare edge between wine and dish cannot. It is also the clearest
**companion-ontology candidate** in the build: pairing and recommendation
knowledge may end up as its own layer rather than living in the wine
ontology proper. We revisit that when the classes are built.

Two smaller calls, both deferred deliberately. A **grape variety** like
Cabernet Sauvignon is modeled as a subclass of `Grape` with a
`made_from_grape` relation, leaving for later the question of whether a
cultivar is better treated as a recorded designation. And **vintage** is
the harvest *year* (a temporal region the wine is tied to), leaving the
"2018 vintage as a batch of wine" sense out until a question needs it.

## Grounding by URI, not by import

The mechanism is the same throughout, and it is the pattern the rest of the
book leans on: a concept is grounded by giving its class a `class_uri` (or a
slot a `slot_uri`) that points at the BFO or CCO term, with the namespace
declared once in the schema's prefix manifest. External OWL ontologies are
never pulled in with LinkML `imports:`, which is reserved for other LinkML
schemas (only `linkml:types` is imported). The manifest the groundings rely
on is already in place from Chapter 1:

```yaml
{{#include listings/wine-yaml-v1.yaml:15:31}}
```

Reuse only works if the targets are real, so each IRI in the table was
checked against the current BFO 2020 and CCO ontology files: that it exists,
and that its category is the one we want. That second check is the one that
caught CCO's `Color`: the IRI resolves, but it resolves to a disposition,
which is why wine color grounds elsewhere.

Step 2 adds no new bytes to the schema. The prefixes are already declared,
and each decision in the table becomes a `class_uri` when the class itself
is built in Chapter 4. The reuse table is this chapter's deliverable; Step 4
cashes it in.
