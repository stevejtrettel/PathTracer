//----------------------------------------------------------------------------
// THE VOCABULARY — the always-compiled half of the shape library.
//
// glsl/shapes/ splits in two (docs/shape-library.md §1):
//
//   VOCABULARY   the operators, and the handful of primitives that are used all
//                the time. Compiled into EVERY shader, right here. An author
//                calls any of it from any shape file, or from authored scene
//                GLSL, with no declaration of any kind.
//   CONTENT      everything else — models, fractals, tilings, environments,
//                varieties, vendor, AND the primitives that are occasional
//                rather than universal (the platonic solids, boxFrame, capsule,
//                ellipsoid, doubleCone, triangle). Inlined by the emitter only
//                when a scene names it.
//
// The rule that makes this work, and it is a measured fact about the library,
// not an aspiration: CONTENT USES VOCABULARY; CONTENT NEVER USES CONTENT. So
// there is no dependency graph to resolve, and no include mechanism at all —
// no `uses` annotation, no import, no reference scanner. If a content file ever
// genuinely needs another, PROMOTE the shared math into the vocabulary.
//
// THIS INCLUDE LIST IS THE DEFINITION of what is always compiled: the catalogue
// reads it (js/scenegen/catalogue.js) to decide what not to inline, so the two
// cannot drift. Adding a file here compiles it into every shader; leaving it out
// makes it ordinary content. Out is the right default.
//
// The bar for being here is narrow — the simplest shapes, used constantly:
//   box cylinder cone torus    called by the library's own content files, so
//                              they MUST always be available
//   sphere plane               in nearly every scene (sphere is in 18 of 33)
// A dodecahedron is a primitive by taxonomy but is not vocabulary: nothing
// composes one, and no scene has yet wanted one. Folder says what it IS; this
// list says whether every shader pays for it.
//
// ORDER MATTERS, and it is the one thing to know when adding a file: GLSL has no
// forward declarations, so a definition must precede its callers. Hence ops
// before primitives, and within primitives, anything built on another comes
// after it. The alternative — a block of prototypes at the top — would be
// exactly the kind of restatement this design refuses elsewhere.
//
// This file replaced objects/computations.glsl, which had accreted into a
// 373-line bag with five naming schemes and six functions serving an engine
// that no longer exists.
//
// Naming, enforced by convention and reviewed on sight:
//   <stem>Distance / Bound / Trace / <Name>Data   catalogue surface
//   op<Verb>                                      an operator (ops/ only)
//   <stem>_helper                                 file-private
//----------------------------------------------------------------------------

//ops/ is the operator layer and is vocabulary by nature — an operator is a verb,
//not a noun, so "is it used all the time?" is the wrong question for it (that
//test is what keeps the platonic solids OUT of this list, since those are content
//you place). curve.glsl is the specialized one at ~10 lines; if ops/ ever grows
//something genuinely heavy, that is the moment to revisit.
#include ./ops/smooth.glsl
#include ./ops/fold.glsl
#include ./ops/carve.glsl
#include ./ops/curve.glsl

#include ./primitives/box.glsl
#include ./primitives/cone.glsl
#include ./primitives/cylinder.glsl
#include ./primitives/plane.glsl
#include ./primitives/sphere.glsl
#include ./primitives/torus.glsl
