//-------------------------------------------------
// ALGEBRAIC VARIETY ENGINE
// the machinery for raymarching an algebraic surface: forward-mode automatic
// differentiation (dual numbers) to get the value AND gradient of a defining
// polynomial, the distance estimator DE() that turns those into a march step,
// and invStereo() for drawing surfaces via inverse stereographic projection.
//
// This is engine only — the surface CATALOGUE (barthSextic, kummer, gyroid, ...)
// lives in glsl/objects/varieties/formulas/, opt-in per scene like any object.
// A scene supplies its own `T eqn(T x,T y,T z)` and feeds it to VARIETY_DATA
// (see objects/objectAPI.glsl). Included globally via 1Setup/_setup.glsl.
//-------------------------------------------------

//---------------------------------------
// Dual Number Arithmetic
// For algebraic distance estimations
//-------------------------------------

// Dual numbers, basically complex with very small imaginary
// component, so multiplication can ignore the im*im part.

#define T vec2

T tfloat(float x) {
    return T(x,0);
}

T tmul(T z, T w) {
    return T(z.x*w.x,z.x*w.y+z.y*w.x); // Dual numbers
}

T tmul(T z, T w, T v) {
    return tmul(z,tmul(w,v));
}

T tmul(T z, T w, T u, T v) {
    return tmul(tmul(z,w),tmul(u,v));
}

T tsqr(T z) {
    return T(z.x*z.x,2.0*z.x*z.y);
}

T tcube(T z){
    return tmul(z,z,z);
}

T tfourth(T z){
    return tmul(tsqr(z),tsqr(z));
}

T tinv(T z){
    return T(1./z.x, -z.y/(z.x*z.x));
}

T tdiv(T x, T y){
    return tmul(x,tinv(y));
}

// (T)Chebyshev polynomials
// Use T(2n,x) = T(n,x)*T(n,x)-1
T tcheb(T x, int n) {
    for (int i = 0; i < n; i++) {
        x = 2.0*tsqr(x) - tfloat(1.0);
    }
    return x;
}


T tabs( T v){
    if( v.x < 0. ) {
        v.x = -v.x;
        v.y= -v.y;
    }
    return v;
}


T tpow(in T v, in float p){//v must be positive ! //p is a constant .
    return pow( v.x , p - 1. ) *T( v.x , p * v.y );
}


T tmin(in T z, in T w){
    if( z.x < w.x ) return z;
    else return w;
}

T tmax(in T z, in T w){
    if( z.x > w.x ) return z;
    else return w;
}

T texp( T z){
    return exp(z.x)*T(1,z.y);
}

T tlog( T v){
    return T( log(v.x) , v.y / v.x );
}

T tsqrt( T v){
    float r = sqrt(v.x);
    return T( r , 0.5 * v.y / r );
}


//alternate tpow with a dual-number exponent (unused):
//T tpow(in T v, in T p){ return texp( tmul( p , tlog( v ) ) ); }

T tcos(in T v){
    return T( cos( v.x ) , - v.y * sin( v.x ) );
}

T tsin(in T v){
    return T( sin( v.x ) ,  v.y * cos( v.x ) );
}

T ttan(in T v){
    return T( tan( v.x ) ,  v.y /( cos( v.x )*cos( v.x )) );
}


T tasin(in T v){
    return T( asin(v.x) , v.y / sqrt( 1. - v.x * v.x ) );
}

T tacos(in T v){
    return T( acos(v.x) , - v.y / sqrt( 1. - v.x * v.x ) );
}

T tatan(in T v){
    return T( atan(v.x) , v.y / ( 1. + v.x * v.x ) );
}













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




//----------------------------------------------------------------------------------------------
// Inverse stereographic projection (dual-number): lift R^n to the unit sphere in
// R^(n+1), used by the *Stereo variants in the formula catalogue to draw the
// double cover of a projective surface.
//----------------------------------------------------------------------------------------------

void invStereo( in T x, in T y, in T z, out T X, out T Y, out T Z, out T W){
    //takes in x y z in R3
    // returns XYZW in R4

    T denom = T(1,0) + tsqr(x) + tsqr(y) + tsqr(z); // 1+x^2+y^2+z^2
    T wNum = denom - T(2,0); // x^2+y^2+z^2-1

    X = 2.* tdiv(x,denom);
    Y = 2.* tdiv(y,denom);
    Z = 2.* tdiv(z,denom);
    W = tdiv(wNum, denom);

}


void invStereo( in T x, in T y, out T X, out T Y, out T Z){
    //takes in x y in R2
    // returns XYZ in R3

    T denom = tsqr(x) + tsqr(y)+ T(1,0); // 1+x^2+y^2
    T zNum = tsqr(x) + tsqr(y) - T(1,0); // x^2+y^2-1

    X = tdiv(2.*x,denom);
    Y = tdiv(2.*y,denom);
    Z = tdiv(zNum, denom);

}


//----------------------------------------------------------------------------
// vec4 duals — one-pass forward mode, for GENERATED equation code only
// (docs/equation-transpiler.md §2; js/scenegen/equations.js holds the
// reference semantics — keep the two in lockstep, lane for lane).
//
// A vec4 dual is (value, ∂x, ∂y, ∂z): one evaluation of a transpiled
// equation returns the value AND the whole gradient, replacing the vec2
// path's three seeded runs. Native vec4 +, -, unary -, scalar* and /scalar
// are already correct dual arithmetic and need no functions; everything
// else is an overload of the T names below, resolved by parameter type.
// Authored formulas keep the vec2 path until the float-source migration
// retires it (docs/variety-builder.md §6).
//----------------------------------------------------------------------------

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

