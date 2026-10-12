# Introduction

This book is a worked example: building an ontology from nothing to a
validated artifact, one step at a time, following Noy & McGuinness's
[*Ontology Development 101*](https://protege.stanford.edu/publications/ontology_development/ontology101-noy-mcguinness.html)
(2001 — "N&M") adapted to [LinkML](https://linkml.io). There is one chapter
per N&M step. The schema grows incrementally, and each chapter embeds a
*frozen listing* of the schema as it stood at that point, so editing the
schema later can't silently change what an earlier chapter shows.

The ontology is grounded in BFO 2020 (ISO/IEC 21838-2:2020) and the Common
Core Ontologies (CCO). Grounding is by URI: each class is referenced through
`subclass_of` and the prefixes, not pulled in with LinkML `imports:` (which
is reserved for other LinkML schemas).

<a id="jargon-bfo-and-cco"></a>

```admonish note title="Jargon: BFO and CCO"
**BFO** (the Basic Formal Ontology, ISO/IEC 21838-2:2020) is a small
top-level ontology of the most general categories: objects, qualities,
processes, and the like. **CCO** (the Common Core Ontologies) is a
mid-level layer built on top of BFO. We *ground* the ontology in them by
pointing its terms at BFO/CCO IRIs instead of inventing categories from
scratch.
```

## The domain

The domain is food and wine, N&M's own running example: wines, foods, and
the pairings between them, expressed in LinkML and grounded in BFO/CCO
rather than the OWL/RDFS of the 2001 paper. Where N&M's choices don't sit
cleanly on a BFO foundation, the chapter that makes the change says so.

The generated schema documentation (class diagrams, the interactive class
graph, and RDF) is published next to this book under
[`schema/`](schema/main/).

## Using this as a template

This repository is also the template the book describes. The README's
["Start your own"](https://github.com/padamson/ontology-authoring-template#start-your-own)
section walks the whole sequence: create a repo from the template, erect
the blank scaffold in place of this showcase, name the schema, and write
one chapter per N&M step with the `ontology-authoring-advance-step` skill.
The README also covers the toolchain the build needs.
