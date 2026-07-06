# Reusing Existing Ontologies

This chapter applies **Step 2** of *Ontology Development 101* (Noy &
McGuinness, 2001) to myschema.

```admonish quote title="Noy & McGuinness 2001 — §Step 2"
It is almost always worth considering what someone else has done and
checking if we can refine and extend existing sources for our
particular domain and task. Reusing existing ontologies may be a
requirement if our system needs to interact with other applications
that have already committed to particular ontologies or controlled
vocabularies. [...] There are libraries of reusable ontologies on the
Web and in the literature. [...]
```

<!-- NOTE: the seeded quote stops before N&M's closing "we will assume
     that no relevant ontologies already exist and start from scratch"
     line on purpose. This template ALWAYS reuses (it grounds in BFO/CCO),
     so that line contradicts the method. Don't argue against reuse; if you
     engage N&M's choice at all, frame it positively (as taking the advice
     they gave but declined). -->


<!--
CHARTER: Survey existing ontologies and decide, per concept, what to
reuse vs. invent. Establish the grounding-by-URI pattern (BFO/CCO and
any domain vocabularies referenced via prefixes + class_uri/slot_uri).

SECTION OUTLINE:
  - Candidate vocabularies (BFO, CCO, domain-specific).
  - Reuse-vs-invent decision criteria.
  - The reuse table (concept -> external term or invented).
  - The grounding-by-URI pattern (prefixes manifest; never imports:).

CARRIED-IN DEFERRALS -> this step:
  (land deferrals from Chapter 1 here)

AUTHORING CHECKLIST:
  [ ] IF this step changed the schema, freeze a new myschema-yaml-vN tag
      and {{#diff}} from the prior tag. Step 2 is usually reuse *decisions*
      (a table) that cash out as class_uri/slot_uri later in Step 4 — if no
      bytes changed, don't force a freeze; reuse the prior tag (sliced) to
      show the prefix manifest the groundings rely on.
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 2): ground by URI, not imports; verify every external
      IRI resolves AND that its category fits (not just that it resolves).
  [ ] demand check: what does the worked example need at this step?
-->
