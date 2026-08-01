# Slots

This chapter works **Step 5** of [*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(Noy & McGuinness, 2001 — "N&M") for the wine ontology. The classes exist;
now they get their properties, and the class graph gets its edges. N&M's
rule for what belongs here: "most of the remaining terms are likely to be
properties of these classes."

```admonish quote title="Noy & McGuinness 2001 — §Step 5"
The classes alone will not provide enough information to answer the
competency questions from Step 1. Once we have defined some of the
classes, we must describe the internal structure of concepts. [...] In
general, there are several types of object properties that can become
slots in an ontology: "intrinsic" properties such as the flavor of a
wine; "extrinsic" properties such as a wine's name, and area it comes
from; parts, if the object is structured [...]; relationships to other
individuals; these are the relationships between individual members of
the class and other items (e.g., the maker of a wine, representing a
relationship between a wine and a winery, and the grape it is made from).
```

## The policies

Four decisions apply across every slot, settled once:

1. **Names come from N&M** where the paper supplies them: `color`,
   `body`, `flavor`, `sugar`, `maker`. That quietly settles two naming
   contests Chapter 3 left open: the paper says *sugar* (not sugar
   content or sweetness) and *flavor* (CQ 6's *bouquet* is the same
   characteristic). `made_from_grape` keeps the name Chapter 2 already
   used in prose.
2. **The pairing stays reified.** There is no direct `goes_well_with`
   edge from `Wine` to `Food`; the relation lives as the
   `PairingRecommendation`'s `wine` and `food` slots, per Chapters 2 and
   4. A graph derives wine-to-food adjacency by traversing through the
   recommendation node, which is the point: the node is where the
   rationale rides.
3. **No inverses.** A knowledge graph traverses edges in both
   directions; storing `made_by` alongside `maker` would be a second
   copy of the same fact.
4. **Cardinality stays lenient.** Nothing is `required` yet, and only
   `made_from_grape` is `multivalued` (a blend has several varieties).
   Tightening is Chapter 6's job, where the competency questions say
   what must be present.

N&M's attachment rule (a slot belongs at the most general class that can
carry it) applies trivially here: the hierarchy is flat, so each slot
attaches to the one class it describes, and only `name` is shared by all
seven.

## The characteristics

`Wine` gets the four intrinsic slots straight from N&M's list: `color`,
`body`, `flavor`, and `sugar`. Chapter 4's decision lands in the schema
here: `color` ranges over an enumeration whose values are red, white, and
rosé, so "Is Bordeaux a red or white wine?" reads a value off the wine
kind. The other three stay strings for now, and that is N&M's own
sequencing rather than laziness: the paper enumerates their allowed
values (light, medium, and full body; delicate to strong flavor; sweet,
dry, and off-dry) in *its* Step 6, so this book does too: Chapter 6
turns those strings into enumerations.

One competency question looks like it should strain this design and does
not. CQ 6 asks whether a wine's bouquet or body changes with vintage
year, and a characteristic stored on a single wine kind cannot vary. But
instances are kinds, and kinds can be as specific as the application
needs: the 2017 Napa Zinfandel and the 2018 Napa Zinfandel are two
`Wine` instances with their own `body` values, N&M's Sterling Vineyards
Merlot logic taken one step further. Chapter 7 demonstrates it.

## The provenance wiring

The relationship slots are N&M's fourth kind of property, and they carry
the competency questions about where a wine comes from: `made_from_grape`
(to `Grape`, multivalued for blends), `maker` (to `Winery`), `region` (to
`WineRegion`), and `vintage` (to `VintageYear`).

`region` is stored rather than derived, and the distinction matters: a
wine's appellation is a fact about the wine kind, not about its
producer's address. A winery in one region can make wine from grapes
grown in another, so traversing `maker` and then asking where the winery
sits would answer a different question than the one CQ 7 asks about Napa
Zinfandel.

The omission is deliberate too: N&M give `Winery` a `location` slot, and
this schema does not. No competency question asks where a winery is, and
every slot here traces to a demand, the same discipline Chapter 3 applied
to terms. The slot is a one-line addition the day a question reaches for
it.

## The recommendation's shape

`PairingRecommendation` gets the slots Chapter 2 promised when it argued
the pairing should be an information content entity: `wine` and `food`
(what the recommendation is about), and `rationale`, `source`, and
`confidence` (why, who says so, and how strongly). A bare wine-to-food
edge could not carry that payload; a graphRAG workflow retrieves it to
explain a pairing, not just assert one.

## The graph closes

The schema growth, against the Chapter 4 snapshot:

{{#diff wine-yaml-v2 wine-yaml-v3 context=8}}

The slot section header {{#callout slots}} marks N&M's remaining-terms
rule; the color enumeration {{#callout colorvalues}} lands the Chapter 4
decision; `made_from_grape` {{#callout blends}} carries the one
multivalued call; and the recommendation's `wine` slot {{#callout reified}}
records the reification policy where it binds.

And the check Chapter 4 could only promise now passes: with the slots in
place, the class graph has edges, and every one of the seven classes is
connected: `Wine` reaches `Grape`, `Winery`, `WineRegion`, and
`VintageYear` directly, and `Food` joins through `PairingRecommendation`.
No islands: nothing in the schema exists that the worked example does not
wire to everything else. Chapter 6 tightens what these slots allow;
Chapter 7 fills them with the instances the competency questions name.
