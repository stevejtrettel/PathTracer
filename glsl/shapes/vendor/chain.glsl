//----------------------------------------------------------------------------
// CHAIN — a vendored model from NVIDIA's sdf-explorer corpus.
//
// VENDORED, NOT OURS. The original copyright and licence block follows this
// header verbatim and governs the maths below it; most of this corpus is
// CC BY-NC-SA 3.0, a few files MIT. That is why vendor/ is its own folder: the
// condition travels with the file and must never be mixed into models/.
//
// PORTED, minimally: the corpus's bare `sdf(vec3)` became `chain_sdf`, and the
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
Copyright 2019 @eiffie
License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
*/

/******************************************************************************
 * The MIT License (MIT)
 * Copyright (c) 2021, NVIDIA CORPORATION.
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

#ifndef chain_glsl
#define chain_glsl

#define TWISTS 4.5
#define TAO 6.2831853

const float pdt=10.0/TAO,tdp=TAO/10.0;

vec2 chain_Rot2D(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}

float Link(vec3 p, float a){
 p.xy=chain_Rot2D(p.xy,a);
 p.y+=1.0+sin(a+60.)*0.2;
 p.yz=chain_Rot2D(p.yz,a*TWISTS+60.);
 return length(vec2(length(max(abs(p.xy)-vec2(0.125,0.025),0.0))-0.1,p.z))-0.02;
}

float DE(in vec3 p){
 float a=atan(p.x,-p.y)*pdt;
 return min(Link(p,floor(0.5+a)*tdp),Link(p,(floor(a)+0.5)*tdp));
}

float chain_sdf(vec3 p)
{
    p += vec3(-0.11,0.,0.);
    const float scale = 0.7;
    p *= 1. / scale;
    return DE(p) * scale * 0.6;
}

#endif

// p is in the model's own coordinates; `size` scales it about the origin
float chainDistance(vec3 p, float size){
    return chain_sdf(p/size)*size;
}

// bounding sphere — see the header: loose on purpose, tighten by eye
float chainBound(vec3 p, float size){
    return length(p) - 2.2*size;
}
