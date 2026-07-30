//----------------------------------------------------------------------------
// VASE — a vendored model from NVIDIA's sdf-explorer corpus.
//
// VENDORED, NOT OURS. The original copyright and licence block follows this
// header verbatim and governs the maths below it; most of this corpus is
// CC BY-NC-SA 3.0, a few files MIT. That is why vendor/ is its own folder: the
// condition travels with the file and must never be mixed into models/.
//
// PORTED, minimally: the corpus's bare `sdf(vec3)` became `vase_sdf`, and the
// two functions at the foot of the file are ours — a `size` parameter (the
// corpus had none) and a bounding sphere.
//
// THE BOUND IS A GUESS, deliberately loose. The corpus documented "most models
// <= 1.5, PixarMike and Serpinski ~3" and nothing per-model, so this uses
// 2.2 and errs large: too tight punches a visible hole, too loose only costs
// march steps. Tighten it by eye once the model has a scene.
//
// CAVEAT INHERITED FROM THE CORPUS: these files were written to be compiled ONE
// AT A TIME and their internal helper names collide with each other. Naming two
// vendor models in a single scene may not compile — see docs/shape-library.md §7.
//----------------------------------------------------------------------------

/*
Copyright 2018 Wes Bakane @WB
License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
Link: https://www.shadertoy.com/view/4tKfWW
*/

/******************************************************************************
 This work is a derivative of work by Wes Bakane used under CC BY-NC-SA 3.0.
 This work is licensed also under CC BY-NC-SA 3.0 by NVIDIA CORPORATION.
 ******************************************************************************/

float sdSphere(vec3 pos, vec3 center, float radius) {
  return length(center - pos) - radius;
}

float sdPlane(vec3 p, vec4 n) { return dot(p, n.xyz) + n.w; }

float sdCappedCylinder(vec3 p, vec2 h) {
  vec2 d = abs(vec2(length(p.xz), p.y)) - h;
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

// Boolean operations for distance fields
float opUnion(float d1, float d2) { return min(d1, d2); }

float opSubtraction(float d1, float d2) { return max(-d1, d2); }

float opIntersection(float d1, float d2) { return max(d1, d2); }

float opSmoothUnion(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h);
}

float opShell(float d, float thickness) { return abs(d) - thickness; }

float map(vec3 pos) {
  float freq = 6.0;

  float d1 = sdCappedCylinder(pos, vec2(0.2, 0.75));
  float d2 = sdSphere(pos, vec3(0.0, -0.25, 0.0), 0.45);
  float d3 = sdSphere(pos, vec3(0.0, 1.0, 0.0), 0.4);
  float d4 = sdCappedCylinder(pos + vec3(0.0, -1.75, 0.0), vec2(1.0, 1.0));

  float df = opSmoothUnion(d1, d2, 0.2);
  df = opSmoothUnion(df, d3, 0.2);
  df = opShell(df, 0.01);
  df = opSubtraction(d4, df);
  df += cos(pos.y * 100.0) / 300.0;

  return df;
}

float vase_sdf(vec3 p) {
  const float scale = 1.0;
  p *= 1. / scale;
  return map(p) * scale;
}

// p is in the model's own coordinates; `size` scales it about the origin
float vaseDistance(vec3 p, float size){
    return vase_sdf(p/size)*size;
}

// bounding sphere — see the header: loose on purpose, tighten by eye
float vaseBound(vec3 p, float size){
    return length(p) - 2.2*size;
}
