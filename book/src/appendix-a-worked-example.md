# Appendix A: The Worked Example

This is the full wine catalog Chapter 7 builds: the instance graph that
answers all seven competency questions. It is a single LinkML data file,
`data/wine-instances.yaml`, and it conforms to the schema — `panschema
validate` confirms it, and the publish step revalidates it before the
site goes out.

[Chapter 7](ch07-instances-and-validation.md#a-small-example-instance-graph)
opens with a four-record *preview* to introduce what an individual and an
edge are; this is the larger graph that preview stood in for. Both are
published on the schema page behind an in-page selector, so the two can be
read together: the preview to learn the shape, this catalog to watch it
carry the questions. The schema is one model; these are two instance
graphs conforming to it, and a deployment's own catalog would be a third.

```yaml
{{#include listings/wine-instances-v1.yaml caption="The complete wine catalog"}}
```
