# Domain and Scope

This chapter applies **Step 1** of *Ontology Development 101* (Noy &
McGuinness, 2001) to myschema.

```admonish quote title="Noy & McGuinness 2001 — §Step 1"
We suggest starting the development of an ontology by defining its
domain and scope. That is, answer several basic questions:

- What is the domain that the ontology will cover?
- For what we are going to use the ontology?
- For what types of questions the information in the ontology should
  provide answers?
- Who will use and maintain the ontology?

The answers to these questions may change during the ontology-design
process, but at any given time they help limit the scope of the model.
```

```admonish quote title="Noy & McGuinness 2001 — §Step 1, Competency questions"
One of the ways to determine the scope of the ontology is to sketch a
list of questions that a knowledge base based on the ontology should
be able to answer, **competency questions** ([Gruninger and Fox 1995](http://www.eil.utoronto.ca/wp-content/uploads/enterprise-modelling/papers/gruninger-ijcai95.pdf)).
These questions will serve as the litmus test later: Does the
ontology contain enough information to answer these types of
questions? Do the answers require a particular level of detail or
representation of a particular area? These competency questions are
just a sketch and do not need to be exhaustive.
```

```admonish quote title="Noy & McGuinness 2001 — §3, three fundamental rules"
1. There is no one correct way to model a domain— there are always
   viable alternatives. The best solution almost always depends on
   the application that you have in mind and the extensions that you
   anticipate.
2. Ontology development is necessarily an iterative process.
3. Concepts in the ontology should be close to objects (physical or
   logical) and relationships in your domain of interest. These are
   most likely to be nouns (objects) or verbs (relationships) in
   sentences that describe your domain.
```

<!--
CHARTER: Define the ontology's domain and scope — what it covers, what
it's used for, the competency questions it must answer, who maintains
it, and (crucially) what it deliberately does NOT model.

SECTION OUTLINE:
  - What domain does myschema cover?
  - What are we going to use the ontology for? (consumers)
  - What questions should the ontology answer? (competency questions)
  - Who will use and maintain the ontology?
  - What myschema does *not* model.
  - On iteration (N&M's three fundamental rules).

CARRIED-IN DEFERRALS -> this step:
  (none — first step)

AUTHORING CHECKLIST:
  [ ] freeze a new myschema-yaml-vN listing tag in the same change
      (the minimal stub committed alongside this chapter)
  [ ] jargon blocks at first use; every # CALLOUT gets a {{#callout}}
  [ ] LESSON (Step 1): competency questions are a sketch, not a
      contract; state what's NOT modeled.
  [ ] demand check: pick the worked example (Appendix A) NOW — it
      drives the build from Step 1, not just Step 7.
-->
