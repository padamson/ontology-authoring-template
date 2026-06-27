# Slot Usage and Facets

This chapter applies **Step 6** of *Ontology Development 101* (Noy &
McGuinness, 2001) to myschema.

```admonish quote title="Noy & McGuinness 2001 — §Step 6"
Slots can have different facets describing the value type, allowed values,
the number of the values (cardinality), and other features of the values
the slot can take.
```

```admonish quote title="Noy & McGuinness 2001 — §Step 6, cardinality"
Sometimes it may be useful to set the maximum cardinality to 0. This setting
would indicate that the slot cannot have any values for a particular subclass.
```

<!--
CHARTER: Narrow the inherited slots per class via slot_usage — tighten
ranges, bound values, sweep cardinality, and declare property
characteristics — without ever widening what the slot already allows.

SECTION OUTLINE:
  - Per-class narrowing (slot_usage refinements).
  - Value bounds (minimum/maximum_value, patterns, enums).
  - The cardinality sweep (required/optional, max-cardinality-0).
  - Property characteristics (symmetric, transitive, ...).

CARRIED-IN DEFERRALS -> this step:
  (land deferrals from earlier chapters here)

AUTHORING CHECKLIST:
  [ ] freeze a new myschema-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, context sized to show what changed
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 6): a facet only restricts, never widens; OWL-DL
      "simple property" rule (a transitive property cannot also be
      irreflexive/asymmetric or carry cardinality).
  [ ] demand check: what does the worked example need at this step?
-->
