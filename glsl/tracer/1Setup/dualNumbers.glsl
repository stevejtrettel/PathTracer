//-------------------------------------------------
// ALGEBRAIC VARIETY ENGINE — dual numbers, the distance estimator, and the
// stereographic lift.
//
// A dual number is a vec4: (value, ∂x, ∂y, ∂z) — one-pass forward-mode
// differentiation, three tangents wide. ONE evaluation of a variety's
// equation returns its value and full gradient. This arithmetic appears
// only in GENERATED code: the transpiler (js/scenegen/equations.js — the
// reference semantics, kept in lockstep lane for lane) emits it from the
// standard float GLSL formulas in glsl/shapes/varieties/.
//
// Native vec4 +, -, unary -, scalar* and /scalar are already correct dual
// arithmetic and need no functions; everything else lives below.
//
// (The original vec2 one-tangent library — `#define T vec2`, tmul/tsqr and
// the three-seed evaluation — was retired with the float-source migration,
// docs/variety-builder.md §6.5. Its `T` name is free again.)
//-------------------------------------------------

vec4 tmul(vec4 a, vec4 b){
    return vec4(a.x*b.x, a.x*b.yzw + b.x*a.yzw);
}
vec4 tmul(vec4 a, vec4 b, vec4 c){ return tmul(a, tmul(b, c)); }
vec4 tmul(vec4 a, vec4 b, vec4 c, vec4 d){ return tmul(tmul(a, b), tmul(c, d)); }

vec4 tsqr(vec4 a){ return vec4(a.x*a.x, 2.0*a.x*a.yzw); }

vec4 tinv(vec4 a){ return vec4(1.0/a.x, -a.yzw/(a.x*a.x)); }

vec4 tdiv(vec4 a, vec4 b){
    return vec4(a.x/b.x, (b.x*a.yzw - a.x*b.yzw)/(b.x*b.x));
}

vec4 tsqrt(vec4 a){
    float r = sqrt(a.x);
    return vec4(r, 0.5*a.yzw/r);
}

vec4 texp(vec4 a){ return exp(a.x)*vec4(1.0, a.yzw); }
vec4 tsin(vec4 a){ return vec4(sin(a.x), cos(a.x)*a.yzw); }
vec4 tcos(vec4 a){ return vec4(cos(a.x), -sin(a.x)*a.yzw); }
vec4 ttan(vec4 a){ return vec4(tan(a.x), a.yzw/(cos(a.x)*cos(a.x))); }

vec4 tpow(vec4 a, float p){ return pow(a.x, p - 1.0)*vec4(a.x, p*a.yzw); }


//--- The Distance Estimator -----
// Takes in a value and gradient length, approximated distance to zero level set:

float DE(float val, float gradLength){
    float k = 1.-1./(abs(val)+1.);
    float param = 5.0; // a free parameter we can set to change accuracy/speed (trial and error)
    float adjustedSpeed = gradLength+param*k+.001;

    //what would happen if it were linear, and we were headed right towards the max decrease?
    float dist = val/adjustedSpeed;
    return 0.4*dist;
}


//the inverse stereographic lift in vec4 duals — the stereo wrapper
//(equation-transpiler §3) lifts the seeded x, y, z to S³ through this
void invStereo(in vec4 x, in vec4 y, in vec4 z, out vec4 X, out vec4 Y, out vec4 Z, out vec4 W){
    vec4 denom = vec4(1.0, 0.0, 0.0, 0.0) + tsqr(x) + tsqr(y) + tsqr(z);
    vec4 wNum  = denom - vec4(2.0, 0.0, 0.0, 0.0);

    X = 2.*tdiv(x, denom);
    Y = 2.*tdiv(y, denom);
    Z = 2.*tdiv(z, denom);
    W = tdiv(wNum, denom);
}
