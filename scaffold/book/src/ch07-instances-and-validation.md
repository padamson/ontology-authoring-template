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
CHARTER: Instantiate the worked example as a LinkML data file under
data/ (NOT hand-authored OWL/TTL — panschema's instance reader ingests
LinkML data: a tree_root container class whose multivalued collections
hold records conforming to the schema). Verify conformance natively with
`panschema verify --schema schema/myschema.yaml --data data/<file>.yaml`.
Publish the instance graph(s) via [[instances]] in panschema-publish.toml
so they render on the schema page behind the in-page selector. Run each
Step-1 competency question as the litmus test. Refine the schema where
instantiation surfaces a gap — verification and refinement are one
interleaved activity (a class or slot that only earns its keep here is a
smell; see the LESSON). Turn on the cross-graph gates: uncomment
`[check.cqa]` in panschema.toml, so the anchors the Step-1 benchmark
promised must now resolve against the records the worked example mints.
`panschema verify --strict` discharges them (resolution, the absence
claims, namespace coverage, and the version pins against this package's
declared version). That verifies the answer KEY; answering the questions
is still a reading of the catalog, and the book keeps "verify" and
"validate" apart.

What a data file needs that the schema so far did not (add as the data
demands): a tree_root CONTAINER class holding a multivalued collection
per record kind; an IDENTIFIER slot (`id`, `identifier: true`) distinct
from a human `name`, because records reference each other by a short,
stable key. Narrate these as honest adaptations of the method to a
file-based workflow — not modeling insights about the domain.

SECTION OUTLINE:
  - A small instance-graph PREVIEW first: a separate, tiny LinkML data
    file (2-4 records with a couple of edges) that introduces
    individual / node / edge, DISTINCT from the full worked example.
    State the distinction in prose — the preview teaches the vocabulary;
    the worked example is the larger data file the chapter builds.
  - What a data file needs that the schema did not (container + id),
    shown as a {{#diff}} against the prior tag with callouts.
  - The worked example: the full catalog, large enough to answer every
    competency question, reproduced in Appendix A. Both graphs publish
    behind the selector (mark one exemplar = the default panel).
  - Verification: `panschema verify` against the schema — the constraints
    Step 6 declared are what it now enforces.
  - The competency-question litmus, each answered by tracing the catalog
    (and, where the graphRAG story is told, as a retrieved subgraph);
    the benchmark's anchors now resolve, shown as the `[check.cqa]` diff
    of panschema.toml and the passing `panschema verify --strict` run.
  - Close on the knowledge graph the schema was always for: RDF T-box +
    A-box are one graph; any reified judgment class carries the rationale
    a bare edge cannot.

CARRIED-IN DEFERRALS -> this step:
  [ ] from ch01 (the benchmark): uncomment `[check.cqa]`
      (resolve_against = ["myschema"], require_namespace_coverage = true)
      once the A-box is listed under [generate.myschema] and published
      as [[instances]] under the name the benchmark's target_dataset
      gives (the dataset pin binds by that name); re-read every
      record against the finished graph, re-pin
      target_schema_version / target_dataset_version if the package
      version moved, and re-freeze myschema-benchmark-vN if any record
      changed

AUTHORING CHECKLIST:
  [ ] worked example is a LinkML data file under data/, verified by
      `panschema verify` (conforms) — NOT hand-authored TTL
  [ ] a small preview data file, distinct from the worked example,
      introduced in the intro with the distinction stated in prose
  [ ] both graphs wired into panschema-publish.toml [[instances]] (name
      labels the selector tab; mark one exemplar = the default panel)
  [ ] Appendix A embeds the frozen worked-example data listing
  [ ] freeze a new myschema-yaml-vN tag for the schema additions
      (container + id + any refinement); {{#diff}} from the prior tag,
      context=N sized so each hunk shows its enclosing header
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 7): the worked example should have driven the build
      FROM Step 1 — if a class or slot only earns its keep here, that is the
      smell of reasoning backward from the data.
  [ ] `[check.cqa]` enabled; `panschema verify --strict` reports every
      anchor resolving, every absence holding, every version pin
      agreeing, with zero warnings
  [ ] demand check: does every Step-1 competency question get an answer?
      The benchmark says which records each must reach; an anchor the
      worked example never minted is the smell. If not, iterate (N&M's
      second rule) — refine, don't reverse.
-->
