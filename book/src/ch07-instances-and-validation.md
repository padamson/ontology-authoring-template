# Instances and Validation

This chapter applies **Step 7** of *Ontology Development 101* (Noy &
McGuinness, 2001) to myschema.

```admonish quote title="Noy & McGuinness 2001 — §Step 7"
The last step is creating individual instances of classes in the
hierarchy. Defining an individual instance of a class requires (1)
choosing a class, (2) creating an individual instance of that class, and
(3) filling in the slot values.
```

<!--
CHARTER: Instantiate the worked example against the schema, validate
with linkml-validate, and run each Step-1 competency question as the
litmus test. Refine the schema where instantiation surfaces gaps —
validation and refinement are one interleaved activity.

SECTION OUTLINE:
  - Worked-example instantiation (Appendix A, instance by instance).
  - linkml-validate against the schema.
  - Competency-question litmus, each expressed as SPARQL.
  - Refinement: cull classes that no instance needed; reflect on the
    finished hierarchy.

CARRIED-IN DEFERRALS -> this step:
  (land deferrals from earlier chapters here)

AUTHORING CHECKLIST:
  [ ] freeze a new myschema-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, context sized to show what changed
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 7): the worked example should have driven the build
      FROM Step 1 — if it only validates here, that is a smell.
  [ ] demand check: does every competency question from Step 1 get an
      answer? If not, iterate (N&M's second rule).
-->
