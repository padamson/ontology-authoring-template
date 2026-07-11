# Slot Usage and Facets

This chapter works **Step 6** of [*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(Noy & McGuinness, 2001 — "N&M") for the wine ontology. The slots exist;
now they get their constraints: which values are allowed, which slots
must be filled, and what bounds a value must respect. Chapter 5 left
everything deliberately loose, so every tightening here has to state its
justification.

```admonish quote title="Noy & McGuinness 2001 — §Step 6"
Slots can have different facets describing the value type, allowed values,
the number of the values (cardinality), and other features of the values
the slot can take.
```

## The value sets

The three characteristic slots Chapter 5 left as strings become
enumerations, and their values deserve honest attribution. `flavor` gets
N&M's set exactly: the paper says "the flavor slot can take on one of the
three possible values: strong, moderate, and delicate." For `body` and
`sugar` the paper enumerates no complete set; its examples use *light*
and *full* bodies (the Figure 5 instance has "a light body"; *full* is
their default-value example) and *dry* and *sweet* sugars (the same
instance is dry; the Port class inherits SWEET from Dessert wine). We
complete each scale with the conventional middle value (*medium* body,
*off-dry* sugar) and say so, rather than passing the full sets off as
the paper's.

Each permissible value also carries its own definition in the schema. An
enum whose values are bare tokens makes the reader guess what *off-dry*
means; the definition is one line, and it belongs to the artifact. The
slot descriptions get the same treatment: "the color of a wine kind" the
slot named `color` on the class `Wine` already says twice, so the
description says what the characteristic *is* (the hue the wine
presents, imparted chiefly by skin contact during maceration) instead
of restating the name or the values.

The color enumeration itself needed no new values here: Chapter 5
already gave it those, because Chapter 4's subtype-versus-value decision
demanded them.

## The cardinality sweep

```admonish quote title="Noy & McGuinness 2001 — §Step 6, cardinality"
Sometimes it may be useful to set the maximum cardinality to 0. This setting
would indicate that the slot cannot have any values for a particular subclass.
```

Chapter 5's lenient stance holds unless something demands otherwise. Four
slots earned `required`:

- **`made_from_grape`**: the paper's own call. It gives the grape slot
  a minimum cardinality of one, because every wine is made from at least
  one variety.
- **`wine` and `food`** on `PairingRecommendation`: a recommendation
  about nothing is not a recommendation, and every pairing question (CQs
  3–5) traverses both.
- **`name`**: every competency question addresses its entities by name,
  and Chapter 7's instances will be keyed by it.

Everything else stays optional: a wine kind with an unknown body is still
a wine kind. The maximum-cardinality-zero facet N&M describe has no work
to do in a flat hierarchy: it exists to switch a slot off for a
particular subclass, and there are no subclasses to switch it off for.
The same is true of default values (the paper's example: *full* as a
default body); a default is an application convenience, and no competency
question asks for one.

`confidence` gets bounds instead of cardinality: `minimum_value: 0`,
`maximum_value: 1`. Chapter 5's prose said "from 0 to 1"; now the schema
checks it.

## What `slot_usage` is for, and why it sits idle here

LinkML's `slot_usage` narrows an inherited slot for one class: a
subclass tightens the range, the cardinality, or the values of a slot it
shares with its siblings. That is the natural home of Step 6 work in a
schema with deep hierarchies. This schema does not have one: each slot
attaches to exactly one class, and the only shared slot (`name`) needs no
narrowing anywhere. So the facets in this chapter land directly on the
slot definitions, and `slot_usage` waits for the schema that needs it
(worth knowing before assuming a Step 6 must produce one).

Property characteristics get the same honest treatment. Nothing in the
wine schema is symmetric, transitive, or reflexive (N&M's inverse-slot
example, `produces` on `Winery`, is exactly what Chapter 5's no-inverses
policy declined), so the OWL-DL rule (a transitive property must stay
"simple," free of cardinality and asymmetry claims) is satisfied without
effort. It starts to matter the
day a relation like *part of* enters the schema.

## The constraints

The diff below also carries a cleanup. The slot and enum descriptions
had accumulated references to the book: chapter numbers, the paper's
name for a term, what a later chapter would do. A schema outlives its
book. The `description` fields ship with the artifact (into the
generated docs, the RDF, and any downstream graph), so they now read as
self-contained domain documentation, and the book-facing context lives
where it belongs: in comments and callout markers, which never enter
the artifact's data.

The schema growth, against the Chapter 5 snapshot:

{{#diff wine-yaml-v3 wine-yaml-v4 context=6}}

The new enumerations carry their attribution {{#callout valuesets}} in
the schema itself; `made_from_grape` records N&M's minimum-cardinality
call {{#callout required}}; and `confidence` turns Chapter 5's prose
promise into a checked constraint {{#callout bounds}}.

The schema is now structurally complete: classes, slots, values, and
constraints. What it does not yet have is anything *in* it. Chapter 7
creates the instances the competency questions name, validates the lot,
and asks the only question that finally matters: can the ontology answer
what Chapter 1 said it would?
