# Slots

This chapter applies **Step 5** of *Ontology Development 101* (Noy &
McGuinness, 2001) to myschema.

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

<!--
CHARTER: Give the classes their properties — overwhelmingly N&M's
fourth kind, relationships to other individuals. Settle the
per-relation policies (typing, inverses, store-vs-derive, naming) once,
then walk the relations cluster by cluster.

SECTION OUTLINE:
  - The policies (name vs. genericize; inverse; store vs. derive).
  - Relations (the provenance wiring), walked cluster by cluster.
  - Ranges for each slot.
  - Cardinality derived from the competency questions.

CARRIED-IN DEFERRALS -> this step:
  (land deferrals from earlier chapters here)

AUTHORING CHECKLIST:
  [ ] freeze a new myschema-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, context sized to show what changed
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 5): derive cardinality/required from the CQs;
      lenient by default (PROV-O stance).
  [ ] demand check: what does the worked example need at this step?
-->
