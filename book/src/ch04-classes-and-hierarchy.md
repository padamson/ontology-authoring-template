# Classes and Hierarchy

This chapter works **Step 4** of [*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(Noy & McGuinness, 2001 — "N&M") for the wine ontology: the terms from
Chapter 3 with independent existence become classes, each grounded in the
BFO/CCO category Chapter 2 chose for it. This is the chapter where the
schema first grows structure, and where two of Chapter 2's calls get
revised in the light of actually building it.

```admonish quote title="Noy & McGuinness 2001 — §Step 4"
There are several possible approaches in developing a class hierarchy
(Uschold and Gruninger 1996): A *top-down* development process starts
with the definition of the most general concepts in the domain and
subsequent specialization of the concepts. A *bottom-up* development
process starts with the definition of the most specific classes, the
leaves of the hierarchy, with subsequent grouping of these classes into
more general concepts. A *combination* development process [...] defines
the more salient concepts first and then generalizes and specializes
them appropriately.
```

N&M say none of the three approaches is inherently better. Ours is
top-down in effect: the most general concepts (the BFO/CCO categories)
already exist, and the domain classes specialize them directly.

## From terms to classes

N&M's selection rule: "we select the terms that describe objects having
independent existence rather than terms that describe these objects.
These terms will be classes in the ontology." Applying it to the
[Chapter 3 list](ch03-important-terms.md#the-term-list) yields seven
classes: `Wine`, `Food`, `Grape`, `WineRegion`, `Winery`, `VintageYear`,
and `PairingRecommendation`. The characteristic terms (color, body, sugar
content, flavor) describe wines rather than exist independently, so they
wait for Chapter 5, as do the relational terms; red, white, and rosé wait
with them as values of the color characteristic.

That last clause resolves the overlaps Chapter 3 left standing, mostly by
picking one name per concept: *wine region* over *location* (`WineRegion`),
*winery* over *producer* and *organization* (`Winery`, grounded in CCO
Organization), and *recommendation* over *pairing* as the thing that gets a
class (`PairingRecommendation`). *Dish* folds into `Food`. *White wine*
goes the value route rather than the subtype route, for reasons the next
section unpacks. And *Bordeaux* keeps both of its readings: the region
becomes an instance of `WineRegion` and the wine an instance of `Wine`,
two individuals sharing a name.

## What an instance of `Wine` is

The choice that shapes everything downstream: an instance of `Wine` is a
**named kind of wine** (Bordeaux, Napa Zinfandel, Cabernet Sauvignon), not
a bottle. Chapter 1 scoped bottles out, and N&M's own instance-or-class
test settles the rest.

```admonish quote title="Noy & McGuinness 2001 — §4.6, An instance or a class?"
Deciding whether a particular concept is a class in an ontology or an
individual instance depends on what the potential applications of the
ontology are. [...] if we are only going to talk about pairing wine with
food we will not be interested in the specific physical bottles of wine.
Therefore, such terms as Sterling Vineyards Merlot are probably going to
be the most specific terms we use. Therefore, Sterling Vineyards Merlot
would be an instance in the knowledge base.
```

Our application is exactly the one N&M describe, so wine kinds are the
instances. This is also where we part with N&M's own hierarchy, which
makes Red wine, White wine, and Rosé wine classes between `Wine` and the
leaves. Color-as-subclass encodes one characteristic into the tree; once
Chapter 5 gives `Wine` a color slot, the same fact would live in two
places, and every additional characteristic would invite another layer of
subclasses. So color stays a characteristic (a slot with red, white, and
rosé as its values), the tree stays flat, and a knowledge graph built on
the schema answers "Is Bordeaux a red or white wine?" by reading an
attribute off a node instead of testing class membership.

The same reading revises a Chapter 2 aside: grape varieties were sketched
there as subclasses of `Grape`, but they are kinds exactly as wines are,
so an instance of `Grape` is a variety (Cabernet Sauvignon the grape,
Zinfandel). Whether a cultivar is better treated as a recorded designation
remains open, deferred to Chapter 7 where the instances actually appear.

## Grounding, corrected

Chapter 2 said each class would carry a `class_uri` pointing at its
BFO/CCO term. Building the classes shows that is the wrong relation:
`class_uri` asserts *identity*, and identity is too strong. Our `Wine` is
not CCO's Portion of Processed Material; every wine is a portion of
processed material, but not every portion of processed material is a
wine. The relation we mean is subsumption, and LinkML has a slot for
exactly that: `subclass_of`, which asserts `rdfs:subClassOf` to the
external URI (the pattern established by Biolink and used across
BFO-grounded LinkML schemas). The reuse table's *decisions* stand
unchanged; only the mechanism moves from `class_uri` to `subclass_of`.

Each domain class grounds directly, with no abstract wrapper classes in
between: a wrapper that exists only to hold a grounding earns nothing, and
with seven classes each grounding somewhere different there is nothing for
an intermediate layer to share.

## The classes

The schema's first structural growth, as a difference against the Chapter
1 snapshot:

{{#diff wine-yaml-v1 wine-yaml-v2}}

The class section header {{#callout classes}} marks the selection rule at
work. On `Wine`, the kinds-as-instances decision {{#callout kinds}} and
the corrected grounding mechanism {{#callout grounding}} are recorded
where they bind. `PairingRecommendation` carries the aboutness reading
{{#callout ice}} from Chapter 2: a recommendation about a wine and a food,
able to carry rationale, source, and confidence. Whether that class and
its eventual slots belong in a companion ontology rather than here is
still an open question; Chapter 7's validation is the right place to
judge it, once the class has a worked shape.

One check comes up nearly empty at this step, and honestly so: the class
graph. With no slots, nothing connects the seven classes to each other
yet, so the island test the build relies on (disconnected nodes are bugs
to explain or remove) only starts to bite in Chapter 5, when the slots
wire wines to their grapes, regions, wineries, and vintages. The classes
are in place; Chapter 5 connects them.
