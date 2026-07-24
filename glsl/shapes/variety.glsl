//@noshape — helpers, not a catalogue shape: the variety builder is its own
//           (carefully designed) piece of the generator, still to come
//----------------------------------------------------------------------------
// ALGEBRAIC VARIETIES
//
// A variety is not authored as a distance function. It is authored as an
// EQUATION — `T eqn(T x, T y, T z)` in dual numbers, from the catalogue in
// glsl/objects/varieties/formulas/ — and everything else is derived:
//
//   1. the gradient        three dual-number evaluations, one per partial.
//                          GENERATED per equation: it is four lines of glue
//                          from the equation's name and nothing else.
//   2. the distance        DE(value, |gradient|) — a first-order estimate of the
//                          distance to the zero set (1Setup/dualNumbers.glsl).
//   3. finite extent       the zero set is unbounded, so it is CLIPPED to some
//                          shape with smax.
//   4. thickness           a level set is infinitely thin. Left alone it is a
//                          SHEET; thickened it becomes a REGION with an inside.
//
// So the author supplies: an equation, a clip shape, a thickness (or none), and
// a bound. That is the whole of a variety object.
//
// This file holds 2 and 4. The gradient is generated; the clip and the bound are
// ordinary shapes from elsewhere in glsl/shapes/.
//----------------------------------------------------------------------------


// data.xyz = gradient, data.w = value, both at the SCALED point. `scale` is the
// variety's internal zoom: the chain rule puts it on the gradient, which keeps
// the returned distance in the object's own local units.
float varietyDistance(vec4 data, float scale){
    return DE(data.w, length(data.xyz)*scale);
}


// Thicken a level set into a shell with a real inside. `inner` pushes the
// surface inward, `outer` outward, so the shell's total thickness is
// inner + outer — keep that comfortably above 2*AT_THRESH or the classifier
// cannot tell the two faces apart.
//
// Leave this OFF to keep the variety a sheet: infinitely thin, two-sided, no
// interior and no refraction.
float varietyShell(float dist, float inner, float outer){
    return abs(dist + inner) - inner - outer;
}
