//----------------------------------------------------------------------------
// CABLES — a vendored model from NVIDIA's sdf-explorer corpus.
//
// VENDORED, NOT OURS. The original copyright and licence block follows this
// header verbatim and governs the maths below it; most of this corpus is
// CC BY-NC-SA 3.0, a few files MIT. That is why vendor/ is its own folder: the
// condition travels with the file and must never be mixed into models/.
//
// PORTED, minimally: the corpus's bare `sdf(vec3)` became `cables_sdf`, and the
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
Copyright 2020 @yuntaRobo
License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
Link: https://www.shadertoy.com/view/wlKXWc
*/

/******************************************************************************
 This work is a derivative of work by yuntaRobo used under CC BY-NC-SA 3.0.
 This work is licensed also under CC BY-NC-SA 3.0 by NVIDIA CORPORATION.
 ******************************************************************************/

// uses host globals: PI (tracer/1Setup/uniforms.glsl)

#ifndef cable_glsl
#define cable_glsl

const float g3d_SceneTime =1.;
const float TAU = 3.1415 * 2.0;
const float E = 0.01;

#define iTime g3d_SceneTime

mat2 rotate2D(float rad)
{
    float c = cos(rad);
    float s = sin(rad);
    return mat2(c, s, -s, c);
}

vec2 de(vec3 p)
{
    float d = 100.0;
    float a = 0.0;

    p.yz *= rotate2D(PI / 5.0);
    p.y -= 0.5;

    // reaction
    vec3 reaction = vec3(cos(iTime), 0.0, sin(iTime)) * 3.0;
    p += exp(-length(reaction - p) * 1.0) * normalize(reaction - p);

    // cables
    float r = atan(p.z, p.x) * 3.0;
    const int ite = 50;
    for (int i = 0; i < ite; i++)
    {
        r += 0.5 / float(ite) * TAU;
        float s = 0.5 + sin(float(i) * 1.618 * TAU) * 0.25;
        s += sin(iTime + float(i)) * 0.1;
        vec2 q = vec2(length(p.xz) + cos(r) * s - 3.0, p.y + sin(r) * s);
        float dd = length(q) - 0.035;
        a = dd < d ? float(i) : a;
        d = min(d, dd);
    }

    // sphere
    float dd = length(p - reaction) - 0.1;
    a = dd < d ? 0.0 : a;
    d = min(d, dd);

    return vec2(d, a);
}

float cables_sdf(vec3 p)
{
    //p += vec3(-0.11,0.,0.);
    const float scale = 0.23;
    p *= 1. / scale;
    return de(p).x * scale * 0.7;
}

#endif

// p is in the model's own coordinates; `size` scales it about the origin
float cablesDistance(vec3 p, float size){
    return cables_sdf(p/size)*size;
}

// bounding sphere — see the header: loose on purpose, tighten by eye
float cablesBound(vec3 p, float size){
    return length(p) - 2.2*size;
}
