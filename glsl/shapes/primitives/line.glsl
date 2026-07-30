//----------------------------------------------------------------------------
// LINE — an infinite straight line thickened to `radius`: a cylinder of
// unbounded length about an arbitrary axis.
//
// `point` is any point on the axis and `dir` its direction, which MUST be unit
// length (the caller's job — normalizing here would cost a sqrt on every line of
// every march step, and the data that drives this is normalized once upstream).
//
// UNBOUNDED, so it has no <stem>Bound and never will: clip it, or use it inside
// something that is already clipped. The cubic-surface scene min's 27 of these
// and intersects the result with its bounding sphere.
//
// glsl/shapes/primitives/ holds the exact closed forms; this one is CONTENT
// rather than vocabulary (it is not in _vocabulary.glsl), so it is inlined only
// into scenes that name it — via lib.line, or via uses: [lib.line] from an
// authored body that calls it with its own per-line data.
//----------------------------------------------------------------------------


// p is in the line's own coordinates. dir must be unit length.
float lineDistance(vec3 p, vec3 point, vec3 dir, float radius){
    vec3 d = p - point;
    return length(d - dot(d, dir)*dir) - radius;
}
