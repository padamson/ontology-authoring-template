# Instances and Validation

This chapter applies **Step 7** of *Ontology Development 101* (Noy &
McGuinness, 2001) to wine.

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
  [ ] (from Ch.3) the named individuals from the term list become
      instances that answer their CQs: Bordeaux the wine (CQ 2),
      Cabernet Sauvignon + a seafood dish (CQ 3), a grilled-meat dish
      (CQ 4), Napa Zinfandel + vintages (CQs 6-7). Note Ch.4: instances
      of Wine/Grape are named KINDS (Bordeaux the wine, Zinfandel the
      grape), and "Bordeaux" is two individuals (a WineRegion and a
      Wine) sharing a name.
  [ ] (from Ch.2/Ch.4) settle whether a cultivar (grape variety) is
      better treated as a recorded designation (GDC) than as an
      instance of Grape, when the variety instances actually appear.
  [ ] (from Ch.2/Ch.4) revisit whether PairingRecommendation and its
      slots belong in a companion ontology rather than this schema,
      once validation shows the class's worked shape.

AUTHORING CHECKLIST:
  [ ] freeze a new wine-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, context sized to show what changed
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 7): the worked example should have driven the build
      FROM Step 1 — if it only validates here, that is a smell.
  [ ] demand check: does every competency question from Step 1 get an
      answer? If not, iterate (N&M's second rule).
-->
