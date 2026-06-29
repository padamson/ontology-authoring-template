# Domain and Scope

This chapter works **Step 1** of [*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(Noy & McGuinness, 2001 — "N&M") for the wine ontology. Step 1 is scoping,
not modeling: no classes go in yet. The output is a set of decisions (what
the ontology is about, what it is for, the questions it must answer, and who
maintains it), together with the empty schema those decisions will fill.

```admonish quote title="Noy & McGuinness 2001 — §Step 1"
We suggest starting the development of an ontology by defining its
domain and scope. That is, answer several basic questions:

- What is the domain that the ontology will cover?
- For what we are going to use the ontology?
- For what types of questions the information in the ontology should
  provide answers?
- Who will use and maintain the ontology?

The answers to these questions may change during the ontology-design
process, but at any given time they help limit the scope of the model.
```

## The domain

In N&M's words, "representation of food and wines is the
domain of the ontology." Concretely, that means **wines** (their grape,
region, winery, color, body, and sugar), **foods** and dishes, and the
**pairing** between them: which wine suits which dish. A Cabernet Sauvignon
and a Riesling differ in ways that make one suit grilled meat and the other
suit seafood.  This ontology captures enough to make that distinction.

## What it is for

N&M build the wine ontology for a stated use: "applications that suggest
good combinations of wines and food." That use sets the competency
questions below, and every later modeling decision answers to it.

The deployment in mind here is a **knowledge graph** for **graphRAG**:
retrieval-augmented generation that an AI workflow runs over a graph rather
than over loose text. A workflow that recommends a wine for a dish, or
explains why one suits another, gets there by traversing wines, their
characteristics, and their pairings as graph structure. The ontology is the
schema that graph is built on, so it has to carry exactly the entities and
relationships those traversals need.

```admonish quote title="Noy & McGuinness 2001 — §Step 1, Competency questions"
One of the ways to determine the scope of the ontology is to sketch a
list of questions that a knowledge base based on the ontology should
be able to answer, **competency questions** ([Gruninger and Fox 1995](http://www.eil.utoronto.ca/wp-content/uploads/enterprise-modelling/papers/gruninger-ijcai95.pdf)).
These questions will serve as the litmus test later: Does the
ontology contain enough information to answer these types of
questions? Do the answers require a particular level of detail or
representation of a particular area? These competency questions are
just a sketch and do not need to be exhaustive.
```

## Competency questions

N&M sketch these competency questions for the wine and food ontology, the
litmus test for whether the finished ontology carries enough information:

1. Which wine characteristics should I consider when choosing a wine?
2. Is Bordeaux a red or white wine?
3. Does Cabernet Sauvignon go well with seafood?
4. What is the best choice of wine for grilled meat?
5. Which characteristics of a wine affect its appropriateness for a dish?
6. Does a bouquet or body of a specific wine change with vintage year?
7. What were good vintages for Napa Zinfandel?

They are a sketch, not a contract. N&M are explicit that the list "does not
need to be exhaustive." What they give us is a demand signal: wine
characteristics (color, body, sugar, flavor), the wine-and-food **pairing**
relation, **vintages** and how they affect a wine, and named entities like
Bordeaux, Cabernet Sauvignon, and Napa Zinfandel all have to be
representable; nothing else earns a place until a question reaches for it.
Grounding those entities in [BFO and CCO](introduction.md#jargon-bfo-and-cco)
is Chapter 2's job; promoting them into classes and a hierarchy is Chapter
4's.

## Who uses and maintains it

The maintainer is the developer who adopts this ontology as the foundation
for that knowledge graph: the person building the graphRAG workflow, who
extends the schema as their application's questions grow. They maintain it
the way any versioned schema is maintained: the `version:` field is the
source of truth and each release is a matching git tag (see the README's
*Versioning*), so a workflow can pin to a known version and upgrade
deliberately.

## What it does not model

The competency questions bound the scope as much by what they leave out as
by what they ask. So, deliberately out:

- **Restaurant and cellar inventory.** The ontology models kinds of wine
  and food, not the bottles in stock or on a wine list.
- **Price, ratings, and reviews.** Catalog data, not the ontology's
  concern.
- **The chemistry and process of winemaking.** We represent that a wine
  *has* a body or a sugar level, not the fermentation that produced it.

Naming an exclusion is a decision, not a gap; it is what keeps Chapter 4
from sprawling past the questions.

```admonish quote title="Noy & McGuinness 2001 — §3, three fundamental rules"
1. There is no one correct way to model a domain --- there are always
   viable alternatives. The best solution almost always depends on
   the application that you have in mind and the extensions that you
   anticipate.
2. Ontology development is necessarily an iterative process.
3. Concepts in the ontology should be close to objects (physical or
   logical) and relationships in your domain of interest. These are
   most likely to be nouns (objects) or verbs (relationships) in
   sentences that describe your domain.
```

## On iteration

These rules apply from here on. There is no single correct model of wine
and food: whether color is a quality a wine bears or a class of wines,
whether a vintage is an attribute of a wine or an entity in its own right,
are open questions with viable answers, and the choice turns on the
competency questions above. Development is iterative: later chapters revise
earlier decisions, and this book records those reversals as they happen
rather than tidying them away.

## The starting point

Step 1 touches the schema only enough to record the decisions above:

```yaml
{{#include listings/wine-yaml-v1.yaml}}
```

The domain and scope live in the schema's own `description` {{#callout domain}};
the `classes`, `slots`, and `enums` sections {{#callout empty}} are present
but empty. The build genuinely starts from nothing, and everything after
this chapter adds to this one file, one N&M step at a time.
