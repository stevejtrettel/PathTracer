//----------------------------------------------------------------------------
// BOXFRAME — the twelve edges of a box, as square struts: `halfSize` =
// half-widths of the box, `edge` = strut thickness.
//
// IQ's formula: the union of three axis-aligned strut bundles, each the box
// shrunk to a line in one axis. Exact.
//
// glsl/shapes/primitives/ is vocabulary: always compiled, callable from any
// shape file and from authored scene GLSL with no declaration.
//----------------------------------------------------------------------------


// p is in the frame's own coordinates (origin at the box centre)
float boxFrameDistance(vec3 p, vec3 halfSize, float edge){
    vec3 d = abs(p) - halfSize;
    vec3 q = abs(d + edge) - edge;
    return min(min(
        length(max(vec3(d.x, q.y, q.z), 0.0)) + min(max(d.x, max(q.y, q.z)), 0.0),
        length(max(vec3(q.x, d.y, q.z), 0.0)) + min(max(q.x, max(d.y, q.z)), 0.0)),
        length(max(vec3(q.x, q.y, d.z), 0.0)) + min(max(q.x, max(q.y, d.z)), 0.0));
}
