# Refinements

The seven N&M steps are complete, and the schema carries a `v0.1.0` tag.
But N&M's method is iterative, not terminal — a first ontology is a
starting point, refined as it is put to use. This chapter collects the
refinements the wine model earned once it had instances and a release:
constraints the reified judgments now enforce, enum values the A-box
finally exercises, and identifier hygiene the catalog makes worth stating.

```admonish quote title="Noy & McGuinness 2001 — §Introduction"
<!-- TODO: insert the verified N&M quote on iterative development
("developing an ontology is necessarily an iterative process" / the
ontology "will most likely need to be revised" as it is used). Confirm
exact wording against the paper before authoring — do NOT paraphrase as
if quoted. -->
```

<!--
CHARTER: A post-v0.1.0 "refinements beyond the seven steps" chapter —
honest framing, NOT a fake N&M Step 8. It advances the schema to v0.2.0
and freezes wine-yaml-v6 with a diff (wine-yaml-v5 -> wine-yaml-v6) +
callouts, following the same chapter-scoped discipline as the step
chapters. Every addition must pass the demand test (improve the MODEL
first, feature coverage second, per this repo's demand-driven rule); the
charter below records which candidates pass and which are cut.

DEMAND ANALYSIS of the candidate refinements (verified against
schema/wine.yaml at v0.1.0):

  CORE — strong demand, clear teaching:
  - `rules` (FLAGSHIP): VintageAssessment has NO rationale slot today
    (only PairingRecommendation does), so an "exceptional" verdict can be
    asserted with nothing but a source + confidence. Add a `rationale`
    slot to VintageAssessment AND a rule: verdict `exceptional` or `poor`
    REQUIRES a rationale. This makes the reified judgment enforce its own
    epistemic standard (extreme claims must be justified) and makes
    VintageAssessment symmetric with PairingRecommendation. Projects to
    the class card, SHACL conditional shapes, amber graph rings, and
    `validate --data`. The model improvement (justify extreme verdicts)
    is the point; the rules coverage is the bonus.
  - Enum coverage in the A-box: rosé (WineColorEnum), off-dry + sweet
    (SugarEnum), exceptional + poor (VerdictEnum) are declared and used
    by NO record, so they are invisible in the instance graph. Add A-box
    records that use them — and the exceptional + poor VintageAssessments
    DEMONSTRATE the rule above (they must carry a rationale). rules and
    enum-coverage land together. NOTE: this edits data/wine-instances.yaml
    (the worked example), so Appendix A's frozen wine-instances-v1 listing
    and the [[instances]] graphs must be re-frozen/re-checked in the same
    change.

  SOLID — moderate demand:
  - `pattern:` on `id`: the ids are kebab-case by convention
    (napa-zinfandel-2018, va-2018). A pattern (e.g. ^[a-z0-9]+(-[a-z0-9]+)*$)
    states the convention as a checked constraint. Wide projection (SHACL
    sh:pattern, JSON-Schema pattern, Postgres CHECK, native validator) for
    one line — one of the best value-per-line constructs panschema projects.
    Confirm every existing id matches before adding it.
  - `unique_keys`: id already guarantees record uniqueness, but nothing
    stops two different ids describing the same wine. A key on
    (maker, name, vintage) prevents duplicate wine kinds. Moderate,
    secondary — include if it reads as a real constraint, not ceremony.

  RESEARCH-GATED — the grounding-thesis payoff, but only if real IRIs exist:
  - `meaning:` on permissible values: grounds an enum value to an external
    IRI (supplies the value's RDF IRI instead of the derived {enum}/{key}),
    extending the book's grounding thesis from classes to enum values.
    WORTH IT ONLY IF genuine external groundings exist for at least some
    values (a wine vocabulary / Wikidata item for a wine color, a quality
    IRI, etc.). BFO/CCO do not carry these. Research before committing;
    if no honest IRI exists, CUT it rather than invent one (that would be
    exactly the feature-bait the demand test forbids). This is unblocked
    research, not a wait.

  CUT — fail the demand test (record WHY, so the cut is legible):
  - `ifabsent`: no slot in the model has a natural default (confidence and
    the enum characteristics all want explicit values). Forcing one would
    be feature-bait. Cut unless a real default candidate emerges.
  - one inlined object: every catalog link is an id-reference, which is
    correct for a catalog; inlining one purely to exercise panschema's
    inlined-mapping reader has no domain motivation. Cut (or mention only).

  DEFERRED — do NOT build or block on it here:
  - The tree_root vessel->scope teaching beat: panschema now emits a
    tree_root that declares an identifier (and anchors a per-dataset scope);
    a root without one stays a vessel and emits nothing. WineCatalog has no
    identifier, so it is UNCHANGED: still a vessel, still omitted. The
    teachable story is the vessel->scope PROGRESSION (a lone catalog is a
    vessel; many catalogs each gain an id and become scopes). The fuller
    beat needs panschema external-IRI-reference support, so it stays deferred
    to a later increment. See CARRIED-IN DEFERRALS.

SECTION OUTLINE:
  - Open on iteration: the seven steps produced a releasable v0.1.0; use
    exposed refinements. Frame honestly (not "Step 8").
  - The judgment that must justify itself: add rationale to
    VintageAssessment + the exceptional/poor rule. Diff + callouts.
    Show `validate` REJECTING an unjustified exceptional verdict (a second
    negative fixture) alongside the conforming justified one.
  - Every value exercised: the A-box gains rosé / off-dry / sweet /
    exceptional / poor records; the instance graph now shows them.
  - Identifier hygiene: the pattern on id (and unique_keys if it earns
    its place), shown as checked constraints.
  - (If research bears out) grounding the values: meaning: on the enum
    values that have honest external IRIs — the grounding thesis reaching
    the leaves. If it does not bear out, say so and move on.
  - Close: v0.2.0 tagged; what iteration is still open (the vessel->scope
    beat pending panschema external-IRI-reference support; any value still
    ungrounded).

CARRIED-IN DEFERRALS -> this chapter:
  [ ] tree_root vessel->scope teaching beat: panschema now emits a
      tree_root that declares an identifier (and anchors a per-dataset
      scope); a root without one stays a vessel and emits nothing.
      WineCatalog has no identifier, so it is unchanged — still a vessel,
      still omitted, NO schema change. The teachable story is the
      vessel->scope progression: a lone catalog is a vessel; many catalogs
      (a different sommelier's, a test set) each gain an id and become
      scopes. Gated on panschema external-IRI-reference support; deferred to
      a later increment, does not block v0.2.0.
  [ ] ground Food to FoodOn: wine's Food records could carry external-IRI
      references to FoodOn (the Food Ontology, an OBO external vocabulary),
      grounding the A-box's foods to a maintained standard — the grounding
      thesis reaching the instance level. Gated on panschema
      external-IRI-reference support; deferred to a later increment
      alongside the vessel->scope beat.

AUTHORING CHECKLIST:
  [ ] every schema addition passes the demand test (model first); cuts
      recorded with their reason
  [ ] rationale slot + exceptional/poor rule added; a negative fixture in
      data/invalid/ proves `validate` rejects an unjustified extreme
      verdict, with the real diagnostic pasted into the prose
  [ ] A-box exercises rosé / off-dry / sweet / exceptional / poor; the
      exceptional + poor records carry rationale
  [ ] data/wine-instances.yaml change re-freezes Appendix A's
      wine-instances-v1 listing and re-checks the [[instances]] graphs
  [ ] verified N&M iterative-development quote inserted (not paraphrased)
  [ ] freeze wine-yaml-v6; a diff (wine-yaml-v5 -> wine-yaml-v6) context=N
      sized so each hunk shows its enclosing header; every # CALLOUT gets
      a callout
  [ ] schema version -> 0.2.0; release v0.2.0 (panschema-publish.toml
      versions/current, tag) AFTER the schema increment is COMPLETE — do
      not freeze/bump mid-increment (avoids a double-state v6)
  [ ] meaning: only if honest external IRIs were found; otherwise the
      prose explains the cut
-->
