//----------------------------------------------------------------------------
// KLEINIAN — a Jos Leys / Knighty Kleinian-group limit set (the box-fold
// distance estimator). ONE shape for the whole family: (kleinR, kleinI) are the
// group generators, and `box`, `inversionCenter/Radius`, `size` and `fold`
// choose WHICH Kleinian box those generators act in. The two classic presets —
// the "standard box" of the kleinian-escape shadertoy (Muhammad Ahmad) and Jos
// Leys' seahorse box (shadertoy XlVXzh) — are the SAME estimator at different
// values of exactly those five. So the scenes really are this estimator's
// parameter space; the named boxes live in js/presets/fractals.js.
//
// `offset` selects which slice of the fractal sits at the origin.
//
// What this actually draws — the Maskit-slice group, the orbit of a circle, and
// which hyperbolic space it all lives in: docs/kleinian-limit-sets.md
//
// glsl/shapes/ is the math-only library. Exposes a vec3 orbit-trap DATA output
// (docs/shape-data.md): the min of z over the orbit, for coloring.
//----------------------------------------------------------------------------


vec2 klein_wrap(vec2 x, vec2 a, vec2 s){
    x -= s;
    return (x - a*floor(x/a)) + s;
}

//the core estimator; a=R, b=I are the group generators. also fills the orbit trap
float klein_de(vec3 z, float R, float I, int iter, vec3 offset,
               vec2 box, vec3 invCenter, float invRadius, float size, float fold,
               out vec3 trap){
    z /= size;
    z += offset;

    vec3 lz = z + vec3(1.0), llz = z + vec3(-1.0);

    //sphere inversion
    z -= invCenter;
    float d  = length(z);
    float d2 = d*d;
    z = (invRadius*invRadius/d2)*z;
    z += invCenter;

    float DF = 1.0;
    float a = R, b = I;
    float f = fold*sign(b);
    trap = vec3(1e4);

    for(int i = 0; i < iter; i++){
        z.x += b/a*z.y;
        z.xz = klein_wrap(z.xz, 2.0*box, -box);
        z.x -= b/a*z.y;

        //fold across the exponential separation line
        if(z.y >= a*0.5 + f*(2.0*a-1.95)/4.0 * sign(z.x + b*0.5)
                        * (1.0 - exp(-(7.2-(1.95-a)*15.0)*abs(z.x + b*0.5)))){
            z = vec3(-b, a, 0.0) - z;
        }

        float ir = 1.0/dot(z, z);          //Möbius generator
        z *= -ir;
        z.x = -b - z.x;
        z.y =  a + z.y;
        DF *= ir;

        trap = min(trap, z);

        if(dot(z-llz, z-llz) < 1e-5) break;   //bail on a 2-cycle
        llz = lz; lz = z;
    }

    float y  = min(z.y, a - z.y);
    float DE = min(y, 0.24)/max(DF, 1.0);
    DE = DE * d2 / (invRadius + d*DE);   //sphere-inversion correction
    return size * DE;
}


// p in the fractal's own coordinates. `fudge` is the marcher's understep: the
// estimator overestimates near the thin surface, and each box wants its own
// factor — tune it by eye, not by theory (the presets carry a starting value).
float kleinianDistance(vec3 p, float kleinR, float kleinI, int iterations, vec3 offset,
                       vec2 box, vec3 inversionCenter, float inversionRadius,
                       float size, float fold, float fudge){
    vec3 trap;
    return fudge * klein_de(p, kleinR, kleinI, iterations, offset,
                            box, inversionCenter, inversionRadius, size, fold, trap);
}

// the orbit trap (shape data): min of z over the orbit
vec3 kleinianOrbitTrapData(vec3 q, float kleinR, float kleinI, int iterations, vec3 offset,
                           vec2 box, vec3 inversionCenter, float inversionRadius,
                           float size, float fold){
    vec3 trap;
    klein_de(q, kleinR, kleinI, iterations, offset,
             box, inversionCenter, inversionRadius, size, fold, trap);
    return trap;
}
