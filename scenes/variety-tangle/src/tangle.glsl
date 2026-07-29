//---------------------------------------------------------------------
// THE TANGLE CUBE — x⁴ − 5x² + y⁴ − 5y² + z⁴ − 5z² + c = 0
//
// A custom variety authored as STANDARD FLOAT GLSL, in its own file in
// the scene folder: syntax-highlighted, standalone, copy-pasteable into
// any shader. scene.js imports this file raw and hands it to variety() —
// the generator transpiles it into one-pass dual-number code (value +
// gradient together) and verifies the arithmetic against this float
// original (docs/equation-transpiler.md).
//
// The trailing parameter `c` becomes a knob at the scene level: the
// classic constant is 11.8; lower it and the six arms fuse, raise it and
// they pinch apart.
//---------------------------------------------------------------------

float tangle(float x, float y, float z, float c){
    float x2 = x*x;
    float y2 = y*y;
    float z2 = z*z;
    return x2*x2 - 5.0*x2 + y2*y2 - 5.0*y2 + z2*z2 - 5.0*z2 + c;
}
