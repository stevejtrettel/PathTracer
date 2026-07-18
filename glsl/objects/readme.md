These are objects meant to be used in "tracer".

`objectAPI.glsl`, `computations.glsl`, the shapes listed in `basic/_basic.glsl`,
and `environments/roomBox.glsl` are included in every scene automatically
(see `tracer/setupShader.glsl`).

Every other object must be included explicitly by a scene. Files state at the
top which other files they depend on — include those first.

## Bounding-volume acceleration

Every finite object whose sdf is meaningfully costlier than a cheap bounding
shape hand-writes a `float bound( vec3 p, Type )` — a conservative bounding sdf
(sphere `length(p)-R`, box `bBox`, cylinder `bCyl`) in the object's local frame —
and uses the `OBJECT_*_B` macros. The generated world sdf traces that bound and
only evaluates the real sdf once a ray is close (see `objectAPI.glsl` for the rule
and `docs/bounding-volumes.md` for the full design). Cheap primitives and
infinite/tiled shapes (plane, honeycombs) correctly opt out. Objects with a custom
`sdf(Vector)` (the multiMaterial composites) open with the same early-out by hand;
composites that call their components' wrappers inherit the components' bounds for
free.
