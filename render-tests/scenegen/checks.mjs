//-------------------------------------------------
// SCENEGEN CHECKS — the generator's edge cases, pinned
// (run: node scripts/gen.mjs --checks)
//
// The goldens pin what every committed scene emits; they cannot say anything
// about inputs no scene uses. These cases do: each builds a small description
// and either expects emit to REFUSE it (`throws`: the error message must match)
// or inspects the emitted chunk (`check`: returns null when right, else what is
// wrong). Every emitted chunk must also declare each const name once.
//
// Each case was a real bug — the comment says what used to happen.
//-------------------------------------------------

import {scene, object, group, lib, knob, glsl, material, variety, varieties,
        round, shell, displace, carve} from '../../js/scenegen/index.js';
import {matte, fbm2Height} from '../../js/presets/index.js';

const clay = () => matte({diffuse: [0.7, 0.7, 0.7]});
const one  = (name, spec) => scene({objects: [object(name, {at: [0, 0, 0], material: clay(), ...spec})]});
const has  = (chunk, text) => chunk.includes(text) ? null : `missing: ${text}`;
const count = (chunk, text) => chunk.split(text).length - 1;

//a medium region: its interior index is a glsl`` field of the local point q
const graded = () => material({surf: {transmit: 1.0},
                               interior: {ior: glsl`1.0 + 0.4*exp(-dot(q, q))`}});

//two formulas from one catalogue file, both reaching the helper chebH
const bounded = (v) => ({shape: v});

export default [

    //---- the scale factor multiplies the whole distance ------------------
    //used to emit `d - A_ROUND * min(...)`: a local-unit distance rounded by a
    //world-unit radius, overestimating by up to 1/scale
    {name: 'scale + round', build: () => one('a', {
        scale: [0.5, 0.5, 0.5], shape: round(lib.box({halfSize: [1, 1, 1]}), {r: 0.2})}),
     check: (c) => has(c, 'return (d - A_ROUND) * min(A_SCALE.x, min(A_SCALE.y, A_SCALE.z));')},
    {name: 'scale + shell', build: () => one('a', {
        scale: [2, 1, 1], shape: shell(lib.sphere({radius: 1}), {thickness: 0.1})}),
     check: (c) => has(c, 'return (abs(d) - A_SHELL) * min(A_SCALE.x, min(A_SCALE.y, A_SCALE.z));')},

    //---- scale must be positive ------------------------------------------
    //a negative component turned the sdf inside out; zero divided by zero
    {name: 'negative scale', build: () => one('a', {scale: [-1, 1, 1], shape: lib.sphere({radius: 1})}),
     throws: /scale must be \[sx, sy, sz\] with every component > 0/},
    {name: 'zero scale', build: () => one('a', {scale: [1, 0, 1], shape: lib.sphere({radius: 1})}),
     throws: /scale must be \[sx, sy, sz\] with every component > 0/},

    //---- a negative displacement amp -------------------------------------
    //used to emit d/(1.0 + -0.3*...) — a divisor below 1 overestimates — and a
    //bound pushed INWARD while the bumps reach 0.15 outward
    {name: 'displace, negative amp', build: () => one('a', {
        shape: displace(lib.sphere({radius: 1}), {by: fbm2Height('bumpsN', 4), amp: -0.3})}),
     check: (c) => has(c, 'return d/(1.0 + 0.3*(2.01*4.0));') ?? has(c, '0.5*0.3')},
    {name: 'displace, knob amp that can go negative', build: () => one('a', {
        shape: displace(lib.sphere({radius: 1}),
                        {by: fbm2Height('bumpsK', 4), amp: knob('ampK', {min: -0.5, max: 0.5, value: 0.1})})}),
     check: (c) => has(c, 'abs(ampK)*(2.01*4.0)') ?? has(c, '0.5*abs(ampK)')},

    //---- a knob must fit the slot it fills -------------------------------
    //each of these compiled to a GLSL type error instead of a JS error
    {name: 'int knob as a float parameter (cast)', build: () => one('a', {
        shape: lib.sphere({radius: knob('ik', {type: 'int', min: 1, max: 3, value: 1})})}),
     check: (c) => has(c, 'sphereTrace(tv, A_P, float(ik))')},
    {name: 'float knob as a vec3 parameter', build: () => one('a', {
        shape: lib.box({halfSize: knob('fk', {value: 1})})}),
     throws: /the float knob 'fk' cannot fill a vec3 slot/},
    {name: 'float knob as a colour', build: () => scene({objects: [object('a', {
        at: [0, 0, 0], shape: lib.sphere({radius: 1}),
        material: matte({diffuse: knob('grey', {value: 0.5})})})]}),
     throws: /the float knob 'grey' cannot fill a vec3 slot/},
    {name: 'bool knob as a rotation angle', build: () => one('a', {
        rotate: {axis: [0, 1, 0], angle: knob('flip', {type: 'bool', value: false})},
        shape: lib.box({halfSize: [1, 1, 1]})}),
     throws: /the bool knob 'flip' cannot fill a float slot/},

    //---- curved-light media outside the plain object case ----------------
    //a group's region used to read REGION_P, which only exists as GROUP_P
    {name: 'medium in a group region', build: () => scene({objects: [group('g', {
        at: [0, 1, 0],
        sdf: glsl`core = length(q) - 0.5; rind = max(length(q) - 1.0, -core);`,
        regions: {core: {material: graded()}, rind: {material: clay()}}})]}),
     check: (c) => has(c, 'indexField_core(p - G_P)') ?? (c.includes('CORE_P') ? 'references CORE_P' : null)},
    //a rotated/scaled medium used to evaluate its field in the unrotated frame
    {name: 'rotated medium', build: () => scene({objects: [object('lens', {
        at: [0, 1, 0], rotate: {axis: [0, 0, 1], angle: 30}, shape: lib.box({halfSize: [1, 0.5, 0.5]}),
        material: graded()})]}),
     check: (c) => has(c, 'vec3 toLocal_lens(vec3 p);') ?? has(c, 'return indexField_lens(toLocal_lens(p));')},

    //---- transpiled variety functions are emitted once -------------------
    //chmutov and chmutovN both call chebH: it used to be defined twice
    {name: 'two catalogue formulas sharing a helper', build: () => scene({objects: [
        object('v1', {at: [-3, 0, 0], material: clay(), bound: glsl`length(q) - 2.0`,
                      ...bounded(variety(varieties.chmutov))}),
        object('v2', {at: [3, 0, 0], material: clay(), bound: glsl`length(q) - 2.0`,
                      ...bounded(variety(varieties.chmutovN, {view: 'affine'}))})]}),
     check: (c) => count(c, 'vec4 chebH(') === 1 ? null : `chebH twin defined ${count(c, 'vec4 chebH(')} times`},
    //one fns: source, two objects: its functions used to be emitted per object
    {name: 'one fns source, two objects', build: () => {
        const src = 'float blobF(float x, float y, float z){ return x*x + y*y + z*z - 1.0; }';
        return scene({objects: [
            object('b1', {at: [-3, 0, 0], material: clay(), bound: glsl`length(q) - 2.0`, shape: variety({fns: src})}),
            object('b2', {at: [3, 0, 0], material: clay(), bound: glsl`length(q) - 2.0`, shape: variety({fns: src})})]});
     },
     check: (c) => count(c, 'vec4 blobF(') === 1 ? null : `blobF twin defined ${count(c, 'vec4 blobF(')} times`},
    {name: 'two fns sources, one name, different bodies', build: () => scene({objects: [
        object('b1', {at: [-3, 0, 0], material: clay(), bound: glsl`length(q) - 2.0`,
                      shape: variety({fns: 'float blobG(float x, float y, float z){ return x*x + y*y + z*z - 1.0; }'})}),
        object('b2', {at: [3, 0, 0], material: clay(), bound: glsl`length(q) - 2.0`,
                      shape: variety({fns: 'float blobG(float x, float y, float z){ return x*x + y*y - z - 1.0; }'})})]}),
     throws: /variety function 'blobG' is defined by both .* with different bodies/},

    //---- no pow() of a negative base -------------------------------------
    //(r - 1)^5 is negative for r < 1; GLSL pow() of a negative base is NaN
    {name: 'odd power of a negative scalar', build: () => one('e', {bound: glsl`length(q) - 2.0`,
        shape: variety({eqn: 'x^2 + y^2 + z^2 - 1 + (r - 1)^5', params: {r: 0.5}})}),
     check: (c) => has(c, '(E_R - 1.0)*pow(abs(E_R - 1.0), 4.0)')},

    //---- a scattering interior written in raw GLSL -----------------------
    //an authored body setting mfp used to compile the medium walk OUT: the
    //interior silently rendered as clear glass
    {name: 'authored subsurface body', build: () => scene({objects: [object('w', {
        at: [0, 0, 0], shape: lib.sphere({radius: 1}),
        material: glsl`return makeWax(vec3(0.9, 0.8, 0.6));`})]}),
     check: (c, s) => has(c, 'bool insideOf(int id, vec3 p)')
                   ?? ((s.defines ?? []).includes('SCENE_SUBSURFACE') ? null : 'no SCENE_SUBSURFACE define')},

    //---- a modifier's const beside a shape parameter's -------------------
    //carve's SEED and cubeGrid's seed both claimed CG_SEED: declared twice
    {name: 'carve over cubeGrid (const names)', build: () => one('cg', {
        shape: carve(lib.cubeGrid({spacing: 1, barHalf: 0.3, bevel: 0.05, height: 3, clumpFreq: 0.1,
                                   jitter: 0.5, contrast: 2, seed: 7, tiles: [3, 3]}), {seed: 2})}),
     check: (c) => has(c, 'CG_SEED2')},
];
