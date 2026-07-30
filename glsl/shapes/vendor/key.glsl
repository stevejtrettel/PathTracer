//----------------------------------------------------------------------------
// KEY — a vendored model from NVIDIA's sdf-explorer corpus.
//
// VENDORED, NOT OURS. The original copyright and licence block follows this
// header verbatim and governs the maths below it; most of this corpus is
// CC BY-NC-SA 3.0, a few files MIT. That is why vendor/ is its own folder: the
// condition travels with the file and must never be mixed into models/.
//
// PORTED, minimally: the corpus's bare `sdf(vec3)` became `key_sdf`, and the
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
Copyright 2020 Flopine @Flopine
License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
Link: https://www.shadertoy.com/view/wssBDf
*/

/******************************************************************************
 This work is a derivative of work by Flopine used under CC BY-NC-SA 3.0.
 This work is licensed also under CC BY-NC-SA 3.0 by NVIDIA CORPORATION.
 ******************************************************************************/

mat2 rot(float a) { return mat2(cos(a), sin(a), -sin(a), cos(a)); }

float cyl(vec3 p, float r, float h) {
  return max(length(p.xy) - r, abs(p.z) - h);
}

float tore(vec3 p, vec2 t) {
  return length(vec2(length(p.xz) - t.x, p.y)) - t.y;
}

float key(vec3 p, float t) {
  float thick = t;
  float body = cyl(p.xzy, thick, 1.5);
  float encoche = tore(p.xzy + vec3(-(2. * thick), 0.05, 1.), vec2(thick, 0.1));
  float head = max(-cyl(p - vec3(0., 2.2, 0.), 0.65, thick * 1.5),
                   cyl(p - vec3(0., 2.2, 0.), 0.8, thick));
  p.y = abs(abs(p.y - 0.45) - 0.8) - 0.15;
  float ts = tore(p, vec2(thick, 0.08));

  return min(encoche, min(min(body, head), ts));
}

float SDF(vec3 p) {
  vec3 pp = p - vec3(0., 2., 0.);
  float small = 3.5;
  float thick = 0.25;
  float d = key(p, thick);
  for (int i = 0; i < 2; i++) {
    d = min(d, key(pp * small, thick) / small);
    pp.y -= 0.55;
    small *= 4.;
  }
  return d;
}

float key_sdf(vec3 p) {
  p += vec3(0.,.2,0.);
  const float scale = 0.3;
  p *= 1. / scale;
  return SDF(p) * scale;
}

// p is in the model's own coordinates; `size` scales it about the origin
float keyDistance(vec3 p, float size){
    return key_sdf(p/size)*size;
}

// bounding sphere — see the header: loose on purpose, tighten by eye
float keyBound(vec3 p, float size){
    return length(p) - 2.2*size;
}
