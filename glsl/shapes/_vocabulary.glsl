//----------------------------------------------------------------------------
// THE VOCABULARY — the always-compiled half of the shape library.
//
// glsl/shapes/ splits in two (docs/shape-library.md §1):
//
//   VOCABULARY   primitives/ + ops/ — small, exact, universally useful.
//                Compiled into EVERY shader, right here. An author calls any of
//                it from any shape file, or from authored scene GLSL, with no
//                declaration of any kind.
//   CONTENT      models/ fractals/ tilings/ environments/ varieties/ vendor/ —
//                a named thing you put in a scene. Inlined by the emitter only
//                when a scene names it.
//
// The rule that makes this work, and it is a measured fact about the library,
// not an aspiration: CONTENT USES VOCABULARY; CONTENT NEVER USES CONTENT. So
// there is no dependency graph to resolve, and no include mechanism at all —
// no `uses` annotation, no import, no reference scanner. If a content file ever
// genuinely needs another, PROMOTE the shared math into the vocabulary.
//
// This file replaced objects/computations.glsl, which had accreted into a
// 373-line bag with five naming schemes and six functions serving an engine
// that no longer exists. Order below is the only constraint: ops/carve.glsl
// calls ops/smooth.glsl, and both call the engine (1Setup/math.glsl,
// 3Materials/fields.glsl), which setupShader has already included.
//
// Naming, enforced by convention and reviewed on sight:
//   <stem>Distance / Bound / Trace / <Name>Data   catalogue surface
//   op<Verb>                                      an operator (ops/ only)
//   <stem>_helper                                 file-private
//----------------------------------------------------------------------------

#include ./primitives/box.glsl
#include ./primitives/cone.glsl
#include ./primitives/cylinder.glsl
#include ./primitives/plane.glsl
#include ./primitives/sphere.glsl
#include ./primitives/torus.glsl
#include ./primitives/triangle.glsl

#include ./ops/smooth.glsl
#include ./ops/fold.glsl
#include ./ops/carve.glsl
