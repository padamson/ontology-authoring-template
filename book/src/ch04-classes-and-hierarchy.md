# Classes and Hierarchy

This chapter applies **Step 4** of *Ontology Development 101* (Noy &
McGuinness, 2001) to wine.

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

<!--
CHARTER: Promote the Step 3 terms into classes and an is_a hierarchy,
each domain class grounded in its BFO/CCO category via subclass_of
(rdfs:subClassOf to the external term — the Biolink-established
pattern), not a wrapper class.

SECTION OUTLINE:
  - Foundational anchors (abstract classes grounded in BFO/CCO).
  - The is_a hierarchy (domain classes specialize the anchors).
  - The grounding pattern (subclass_of to the external URI).

CARRIED-IN DEFERRALS -> this step:
  (land deferrals from earlier chapters here)

AUTHORING CHECKLIST:
  [ ] freeze a new wine-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, context sized to show what changed
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 4): verify upper-ontology CATEGORY fit, not just IRI
      existence (the Quality-in-ICE error); build the graph viz and
      treat island nodes as bugs.
  [ ] demand check: what does the worked example need at this step?
-->
