//----------------------------------------------------------------------------
// KNOB — a vendored model from NVIDIA's sdf-explorer corpus.
//
// VENDORED, NOT OURS. The original copyright and licence block follows this
// header verbatim and governs the maths below it; most of this corpus is
// CC BY-NC-SA 3.0, a few files MIT. That is why vendor/ is its own folder: the
// condition travels with the file and must never be mixed into models/.
//
// PORTED, minimally: the corpus's bare `sdf(vec3)` became `knob_sdf`, and the
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
Copyright 2020 Towaki Takikawa @yongyuanxi
The MIT License
Link: N/A
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

// uses host globals: pi (tracer/1Setup/uniforms.glsl)

#ifndef knob_glsl
#define knob_glsl

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// helper maths
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

mat3 RotMat(vec3 axis, float angle)
{
    // http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc*axis.x*axis.x+c,         oc*axis.x*axis.y-axis.z*s,  oc*axis.z*axis.x+axis.y*s, 
                oc*axis.x*axis.y+axis.z*s,  oc*axis.y*axis.y+c,         oc*axis.y*axis.z-axis.x*s, 
                oc*axis.z*axis.x-axis.y*s,  oc*axis.y*axis.z+axis.x*s,  oc*axis.z*axis.z+c);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// distance functions
// taken from https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

float sdSphere(vec3 v, float r) {
    return length(v) - r;
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdCone( vec3 p, vec2 c )
{
  // c is the sin/cos of the angle
  float q = length(p.xy);
  return dot(c,vec2(q,p.z));
}

float sdCappedCylinder( vec3 p, float h, float r )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(h,r);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdTriPrism( vec3 p, vec2 h )
{
  vec3 q = abs(p);
  return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); 
}
float ssub( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h); 
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// actual distance functions
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

float sdBase(vec3 p) { 
    // Intersect two cones
    float base = opSmoothUnion(sdCone((p + vec3(0.,.9,0.)) * RotMat(vec3(1.,0.,0.), -pi/2.), 
                                       vec2(pi/3., pi/3.)),
                               sdCone((p - vec3(0.,.9,0.)) * RotMat(vec3(1.,0.,0.), pi/2.), 
                                       vec2(pi/3., pi/3.)), 
                               0.02);
    // Bound the base radius
    base = max(base, sdCappedCylinder(p, 1.1, 0.25)) * 0.7;
    // Dig out the center
    base = max(-sdCappedCylinder(p, 0.6, 0.3), base);
    // Cut a slice of the pie
    base = max(-sdTriPrism((p + vec3(0.,0.,-1.)) * RotMat(vec3(1.,0.,0.), pi/2.), vec2(1.2, 0.3)), base);
    return base;
}

float sdKnob(vec3 p) {
    float sphere = sdSphere(p, 1.0);
    float cutout = sdSphere(p - vec3(0.0, 0.5, 0.5), 0.7);
    float cutout_etch = sdTorus((p - vec3(0.0, 0.2, 0.2)) * RotMat(vec3(1.,0.,0.), -pi/4.), vec2(1.0, 0.05));
    float innersphere = sdSphere(p - vec3(0.0, 0.0, 0.0), 0.75);

    // Cutout sphere
    float d = ssub(cutout, sphere, 0.1);

    // Add eye, etch the sphere
    d = min(d, innersphere);
    d = max(-cutout_etch, d);

    // Add base
    d = min(ssub(sphere, 
                 sdBase(p - vec3(0.,-.775,0.)), 0.1), d);
    return d;
}

float knob_sdf(vec3 p) {
    const float scale = 0.8;
    p *= 1./scale;
    return sdKnob(p) * scale;
}

#endif

// p is in the model's own coordinates; `size` scales it about the origin
float knobDistance(vec3 p, float size){
    return knob_sdf(p/size)*size;
}

// bounding sphere — see the header: loose on purpose, tighten by eye
float knobBound(vec3 p, float size){
    return length(p) - 2.2*size;
}
