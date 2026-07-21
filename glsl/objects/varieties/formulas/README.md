# Variety formula catalogue

Dual-number defining equations for algebraic surfaces, grouped by degree where a
degree has an obvious canonical surface (`kummer`, `barthSextic`, …), plus a
`gallery` bucket for the named IMAGINARY/Hauser art surfaces and a `misc` bucket
for the transcendental / parametrized / exotic ones (gyroid, goldman, möbius, the
Nadir elliptic families).

Each file is opt-in: `#include` it in a scene's `objects.glsl` and reference the
formula from that scene's `T eqn(...)`. The shared engine (dual-number `T`
arithmetic, `DE()`, `invStereo()`) lives in `glsl/tracer/1Setup/dualNumbers.glsl`
and is always in scope.

Float-based formulas not yet ported to dual numbers — plus the porting recipe —
are in `algVariety-reference.md` (this folder).
