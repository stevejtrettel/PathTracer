//-------------------------------------------------
// EQUATION FIXTURES — stage-1 suite for the transpiler's verify gate
// (docs/equation-transpiler.md §5/§7; run: node scripts/gen.mjs --equations)
//
// Catalogue formulas re-authored as float-expression strings, chosen to
// cover the arithmetic: polynomials plain and nested, trig, division,
// parameters, and 4-ary/projective sources. When the catalogue itself is
// float source these become redundant and the gate runs over it instead.
//
// `expect` entries pin the ERROR paths: the gate asserts these fail, and
// fail for the stated reason — a green gate proves the refusals too.
//-------------------------------------------------

export default [

    //--- polynomials, affine ------------------------------------------
    {name: 'cubicTrivial', src: 'x^2*y + y^2*z + z^2*x - 0.1'},
    {name: 'cubicGenus',   src: 'x^3 + y^3 + z^3 - (x + y + z)'},
    {name: 'kleinBottle',
     src: '(x^2 + y^2 + z^2 + 2*y - 1)*((x^2 + y^2 + z^2 - 2*y - 1)^2 - 8*z^2) + 16*x*z*(x^2 + y^2 + z^2 - 2*y - 1)'},

    //chmutov n=2: Chebyshev T4 via two explicit doublings — the closed form
    //of the loop the statement stage (stage 5) will accept as written
    {name: 'chmutov2',
     src: '(2*(2*x^2 - 1)^2 - 1) + (2*(2*y^2 - 1)^2 - 1) + (2*(2*z^2 - 1)^2 - 1) + 1'},

    //--- trig, division, parameters -----------------------------------
    {name: 'gyroid',   src: 'sin(x)*cos(y) + sin(y)*cos(z) + sin(z)*cos(x)'},
    {name: 'riemannTwoBranch', src: 'z^2*x^2 + (z^2 + 1)*y^2 - 5*(z^4 + z^2)'},
    {name: 'witchHat', src: 'exp(-(x^2 + z^2)) - y/(1 + x^2 + z^2)'},
    {name: 'sphereR',  src: 'x^2 + y^2 + z^2 - r^2', params: {r: 1.9}},

    //--- 4-ary / projective (numeric homogeneity, fitted degree) ------
    {name: 'quadricCone',  src: 'x^2 + y^2 - z^2 - w^2',  degree: 2},
    {name: 'quarticFermat', src: 'x^4 + y^4 + z^4 - w^4', degree: 4},

    //--- statement bodies (stage 5) — the Chebyshev acceptance --------
    //the loop the closed form above spells out by hand: a helper with a
    //counted for + int params, called three ways by the formula
    {name: 'chmutovFns', fns: `
        float cheb(float x, int n){
            for(int i = 0; i < n; i++){ x = 2.0*x*x - 1.0; }
            return x;
        }
        float chmutov(float x, float y, float z){
            int n = 2;
            return cheb(x, n) + cheb(y, n) + cheb(z, n) + 1.0;
        }`},

    //if/else + kind promotion: h starts as a copy of a coordinate (dual),
    //is folded by a branch whose comparison reads the value lane
    {name: 'foldCone', fns: `
        float foldCone(float x, float y, float z){
            float h = y;
            if(h < 0.0){ h = -h; }
            return x*x + z*z - h;
        }`},

    //a TRAILING parameter on a function source: scalar in the twin's
    //signature, a knob hook at the wrapper (the tangle cube's constant)
    {name: 'tangleFns', params: {c: 11.8}, fns: `
        float tangle(float x, float y, float z, float c){
            float x2 = x*x;
            float y2 = y*y;
            float z2 = z*z;
            return x2*x2 - 5.0*x2 + y2*y2 - 5.0*y2 + z2*z2 - 5.0*z2 + c;
        }`},

    //--- the refusals — these MUST fail, for these reasons ------------
    {name: 'whileLoop', fns: 'float bad(float x, float y, float z){ while(x < 1.0){ x = x + 1.0; } return x; }',
     expect: /'while' is outside the statement whitelist/},
    {name: 'inhomogeneous', src: 'x^3 + y*w', expect: 'homogeneity'},
    {name: 'unknownFn',     src: 'sinh(x) + y + z', expect: /unknown function 'sinh'/},
    {name: 'badExponent',   src: 'x^-2 + y + z', expect: /nonnegative integer literal/},
    {name: 'statementLike', src: 'x = y + z', expect: /expected/},
    {name: 'paramGap',      src: 'x + y + z - r', expect: /missing: r/},
    {name: 'paramExtra',    src: 'x + y + z', params: {r: 1}, expect: /unused: r/},
];
