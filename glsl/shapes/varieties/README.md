# Variety formula catalogue

Defining equations for algebraic (and transcendental) surfaces, written as
**standard float GLSL** — one `float <name>(float x, float y, float z[, float w],
…params)` per formula, straight-line bodies plus counted loops/branches
(the statement whitelist, docs/equation-transpiler.md §3).

These files are **transpiler input, never chunk includes**: the generator
emits one-pass dual-number code (value + gradient together) for exactly the
formulas a scene uses, and `node scripts/gen.mjs --equations` verifies every
formula's arithmetic — value, gradient, homogeneity, fitted degree — on
every run.

- **3-ary** `(x, y, z)` = affine, drawable as-is.
- **4-ary** `(x, y, z, w)` homogeneous = projective: drawable as the stereo
  double cover (default) or the generated `w = 1` patch
  (`view: 'affine'`). Capability is the signature — there is no automatic
  lift (docs/variety-builder.md §4).
- **Trailing parameters** are scene knob hooks (float or int). Annotate the
  classic value: `//@default <fn>.<param> <value>` — a scene may omit the
  parameter (the default bakes as a const) or pass a number/knob (live
  moduli). The gate requires a default on every trailing parameter.

Use from a scene: `variety(varieties.<name>, {scale, view, params})` —
`npm run gen -- --catalogue` lists everything here. Adding a formula = one
float function in the right family file (canonical surfaces get their own
file; families share a bucket — organization is free, nothing is included).

`algVariety-reference.md` is the math archive: the published projective
forms these were flattened from, with sources and provenance.
