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

    //--- the refusals — these MUST fail, for these reasons ------------
    {name: 'inhomogeneous', src: 'x^3 + y*w', expect: 'homogeneity'},
    {name: 'unknownFn',     src: 'sinh(x) + y + z', expect: /unknown function 'sinh'/},
    {name: 'badExponent',   src: 'x^-2 + y + z', expect: /nonnegative integer literal/},
    {name: 'statementLike', src: 'x = y + z', expect: /expected/},
    {name: 'paramGap',      src: 'x + y + z - r', expect: /missing: r/},
    {name: 'paramExtra',    src: 'x + y + z', params: {r: 1}, expect: /unused: r/},
];
