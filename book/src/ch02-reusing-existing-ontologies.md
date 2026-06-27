# Reusing Existing Ontologies

This chapter applies **Step 2** of *Ontology Development 101* (Noy &
McGuinness, 2001) to wine.

```admonish quote title="Noy & McGuinness 2001 — §Step 2"
It is almost always worth considering what someone else has done and
checking if we can refine and extend existing sources for our
particular domain and task. Reusing existing ontologies may be a
requirement if our system needs to interact with other applications
that have already committed to particular ontologies or controlled
vocabularies. [...] There are libraries of reusable ontologies on the
Web and in the literature. [...]

For this guide however we will assume that no relevant ontologies
already exist and start developing the ontology from scratch.
```

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
  [ ] freeze a new wine-yaml-vN listing tag in the same change
  [ ] {{#diff}} from the prior tag, context sized to show what changed
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 2): ground by URI, not imports; verify every
      external IRI resolves.
  [ ] demand check: what does the worked example need at this step?
-->
