# Introduction

This book is a worked example: building an ontology from nothing to a
validated artifact, one step at a time, following Noy & McGuinness's
*Ontology Development 101* (2001 — "N&M") adapted to
[LinkML](https://linkml.io). There is one chapter per N&M step. The schema
grows incrementally, and each chapter embeds a *frozen listing* of the
schema as it stood at that point, so editing the schema later can't
silently change what an earlier chapter shows.

The ontology is grounded in BFO 2020 (ISO/IEC 21838-2:2020) and the Common
Core Ontologies (CCO). Grounding is by URI: BFO and CCO terms are
referenced through `class_uri`/`slot_uri` and prefixes, not pulled in with
LinkML `imports:` (which is reserved for other LinkML schemas).

## The worked example

N&M use a wine and food ontology as their running example, so this book
builds the same domain — wines, wineries, regions, grapes, and the
qualities that tell them apart — expressed in LinkML and grounded in
BFO/CCO rather than the OWL/RDFS of the 2001 paper. Where N&M's choices
don't sit cleanly on a BFO foundation, the chapter says so and shows the
adaptation.

The generated schema documentation — class diagrams, the interactive class
graph, and RDF — is published next to this book under
[`schema/`](schema/main/).

## Using this as a template

This repository is also the template the book describes. To build your own
ontology with the same workflow, clone it (or use GitHub's "Use this
template"), then run the `setup-ontology` skill: it resets the showcase
back to a blank scaffold, renames the placeholder to your schema's name,
and hands off to `advance-step`, which walks one N&M step per chapter. The
README covers the toolchain and the setup sequence.
