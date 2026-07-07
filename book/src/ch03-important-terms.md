# Important Terms

This chapter works **Step 3** of [*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(Noy & McGuinness, 2001 — "N&M") for the wine ontology. Step 3 is a
brainstorm with a discipline: write down every term the ontology should
talk about, and put off every question about what kind of thing each term
is.

```admonish quote title="Noy & McGuinness 2001 — §Step 3"
It is useful to write down a list of all terms we would like either to
make statements about or to explain to a user. What are the terms we
would like to talk about? What properties do those terms have? What
would we like to say about those terms? For example, important
wine-related terms will include wine, grape, winery, location, a wine's
color, body, flavor and sugar content; different types of food, such as
fish and red meat; subtypes of wine such as white wine, and so on.
Initially, it is important to get a comprehensive list of terms without
worrying about overlap between concepts they represent, relations among
the terms, or any properties that the concepts may have, or whether the
concepts are classes or slots.
```

## Where the terms come from

N&M ask for a comprehensive list, and comprehensiveness invites invention:
terms that sound like wine vocabulary but that nothing actually asks for.
The discipline that keeps the list honest is sourcing. Every term below
traces to one of three places: N&M's own Step 3 example list (quoted
above), a [competency question](ch01-domain-and-scope.md#competency-questions)
from Chapter 1, or the domain work already done in Chapters 1 and 2.
Nothing is on the list merely because it sounds like it belongs in a wine
ontology.

## The term list

| Source | Terms |
|---|---|
| N&M's Step 3 list | wine, grape, winery, location, color, body, flavor, sugar content, food, fish, red meat, white wine |
| CQ 1 (characteristics) | wine characteristic |
| CQs 2–3 (color, named wines) | red wine, rosé, Bordeaux, Cabernet Sauvignon |
| CQs 3–5 (pairing) | seafood, grilled meat, dish, pairing ("goes well with"), appropriateness, recommendation |
| CQs 6–7 (vintage) | bouquet, vintage, vintage year, good vintage, Napa Zinfandel |
| Chapters 1–2 domain work | wine region, grape variety, sweetness, producer, organization |

## The overlaps stay

The list is deliberately unsorted, and several entries name the same thing
or nearly so: *location* and *wine region*; *flavor* and *bouquet*; *sugar
content* and *sweetness*; *winery*, *producer*, and *organization*;
*pairing* and *recommendation*. One term is slipperier still: *Bordeaux*
names a region, and, by metonymy, the wine made there; CQ 2 ("Is Bordeaux
a red or white wine?") uses it as a wine. And *white wine* sits between a
subtype of wine and a value of the color characteristic.

Resolving any of this now would be doing Step 4's work early. N&M are
explicit that the list should be collected "without worrying about overlap
between concepts they represent," so the overlaps stand, on the record, as
input to the sorting that comes next.

## What happens to the list

Every term on the list has a destination in the steps ahead. The
entity-like terms (wine, grape, winery, region, food, dish, vintage) are
promoted into classes and a hierarchy in Chapter 4, which also resolves
the overlaps above. The characteristic-like terms (color, body, sugar
content or sweetness, flavor or bouquet) become slots in Chapter 5, which
settles their names; so do the relational ones (pairing's "goes well
with," a wine's link to its grape, winery, and region), since a LinkML
slot covers a relationship as readily as an attribute. The value-like
terms (red, white, and rosé, if Chapter 4 reads them as values of color
rather than subtypes of wine) become enumeration values when the color
slot gets its range. Chapter 6 then tightens the slots per class with
`slot_usage` facets, and the named individuals (Bordeaux the wine,
Cabernet Sauvignon, Napa Zinfandel) wait until Chapter 7, where they
become instances and the competency questions get their answers. The
groundings each class and slot will use were already decided in Chapter
2's reuse table.

Like Step 2, this step adds no bytes to the schema: a term list is prose,
not model. The schema still stands at the Chapter 1 snapshot, and Chapter
4 starts spending the list.
