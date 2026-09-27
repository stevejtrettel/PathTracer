//-------------------------------------------------
// THE WHITE-SKY ENERGY TEST (the "white furnace")
// (run: node scripts/render-diff.mjs --energy)
//
// Every case is an object that absorbs nothing, under a sky of radiance exactly
// 1 in every direction. Light can bounce around inside and between surfaces as
// much as it likes, but none is lost and none is made — so every pixel must
// average to exactly 1, whatever the geometry or the material. A pixel darker
// than 1 is light the tracer lost; brighter is light it invented.
//
// The expected answer is known exactly, so unlike the render-diff references
// this means the same thing on any machine, and runs in CI.
//
// Most cases are EXACT: every path returns exactly 1 (all weights are 1), so
// the average is 1 to rounding and even a one-pixel dark ring fails. Cases
// marked `noisy` carry per-sample weights that only average to 1 — spectral
// tints, light-aiming weights, the medium walk's roulette — and are checked on
// the image mean alone.
//
// maxBounces is 100, not the engine's 50: light trapped in rough or frosted
// glass takes long paths, and past the cap the roulette tail stops them with
// a small, deliberate loss (rough glass averaged 0.998 at 50, 0.9999 at 100).
// That trade-off is the engine's by design; this test is after everything else.
//
// Each case is a function (built only when its page loads). It was a failing
// case that first found each of: the black rim on marched glass (grazing
// self-hits) and the light lost inside frosted glass (Sep 2026).
//-------------------------------------------------

import {scene, object, sheet, lib, glsl, material} from '../../js/scenegen/index.js';
import {matte, glass, metal, gloss, plastic, subsurface, withCoat, fog} from '../../js/presets/index.js';

const WHITE = [1.0, 1.0, 1.0];
const CLEAR = [0.0, 0.0, 0.0];

//a unit ball the tracer MARCHES: lib.sphere has a closed-form hit and would
//never exercise the marcher's landings
const ball  = () => lib.ellipsoid({radii: [1.0, 1.0, 1.0]});

//a scene of `objects` (a function: nodes are built when the case loads) under
//the white sky, the camera framing the unit ball to fill most of the image
function furnace(objects, {ui = {}, ambient, noisy = false} = {}){
    return () => ({
        description: scene({objects: objects(), ...(ambient ? {ambient} : {})}),
        settings: {
            uiParams: {aperture: 0, focalLength: 6, exposure: 1, fov: 20, maxBounces: 100, ...ui},
            //with the engine's CAMERA_OFFSET this sits at (0, 0, 6), looking down -z
            location: {position: [2, 0, 0], facing: [1, 0, 0, 0, 1, 0, 0, 0, 1]},
            params: [],
            sky: {type: 'solid', color: WHITE},
            energy: {noisy},
        },
    });
}

//one object at the origin
const one = (shape, mat, opts) => furnace(() => [object('thing', {at: [0, 0, 0], shape: shape(), material: mat()})], opts);


export default {

    //---- opaque surfaces ------------------------------------------------
    matte:         one(ball, () => matte({diffuse: WHITE})),
    matteAnalytic: one(() => lib.sphere({radius: 1.0}), () => matte({diffuse: WHITE})),
    gloss:         one(ball, () => gloss({diffuse: WHITE, gloss: 0.3, roughness: 0.4})),
    plastic:       one(ball, () => plastic({diffuse: WHITE, roughness: 0.3, ior: 1.5})),
    clearcoat:     one(ball, () => withCoat(matte({diffuse: WHITE}), {coat: 1.0, coatRoughness: 0.3})),
    roughMirror:   one(ball, () => metal({specular: WHITE, roughness: 0.5})),
    thinFilm:      one(ball, () => material({surf: {transmit: 1.0, film: 400.0}})),

    //---- glass: refraction, total internal reflection, frost ------------
    glass:         one(ball, () => glass({absorb: CLEAR, ior: 1.5})),
    glassAnalytic: one(() => lib.sphere({radius: 1.0}), () => glass({absorb: CLEAR, ior: 1.5})),
    diamond:       one(ball, () => glass({absorb: CLEAR, ior: 2.4})),
    roughGlass:    one(ball, () => material({surf: {transmit: 1.0, roughness: 0.4}, interior: {ior: 1.5}})),
    frosted:       one(ball, () => glass({absorb: CLEAR, ior: 1.5, transmit: 0.5})),
    frostedCube:   one(() => lib.box({halfSize: [0.7, 0.7, 0.7]}), () => glass({absorb: CLEAR, ior: 1.5, transmit: 0.5})),
    spectralGlass: one(ball, () => glass({absorb: CLEAR, ior: 1.5}),
                       {ui: {spectral: true, dispersion: 0.1}, noisy: true}),

    //---- regions: nesting, sheets, curved light, scattering --------------
    nestedGlass:   furnace(() => [
        object('core',  {at: [0, 0, 0], shape: lib.ellipsoid({radii: [0.5, 0.5, 0.5]}),
                         material: glass({absorb: CLEAR, ior: 2.0}), nestedIn: 'shell'}),
        object('shell', {at: [0, 0, 0], shape: ball(), material: glass({absorb: CLEAR, ior: 1.4})}),
    ]),
    soapSheet:     furnace(() => [sheet('bubble', {at: [0, 0, 0], shape: ball(),
        front: material({surf: {transmit: 1.0, film: 400.0}}),
        back:  material({surf: {transmit: 1.0, film: 400.0}})})]),
    luneburgLens:  one(() => lib.sphere({radius: 1.0}),
                       () => glass({ior: glsl`sqrt(max(2.0 - dot(q, q), 0.0))`, absorb: glsl`vec3(0.0)`})),
    //(noisy: past 8 internal reflections the walk continues by roulette, whose
    //survivors are boosted — unbiased, but not every sample is exactly 1)
    subsurface:    one(ball, () => subsurface({absorb: CLEAR, ior: 1.5, mfp: 0.1, blur: 1.0}), {noisy: true}),
    roughSubsurface: one(ball, () => material({surf: {transmit: 1.0, roughness: 0.5},
                                               interior: {ior: 1.5, mfp: 0.05, blur: 0.8}}), {noisy: true}),
    fog:           one(ball, () => matte({diffuse: WHITE}), {ambient: fog({mfp: 4.0, blur: 0.7})}),

    //---- the camera models ------------------------------------------------
    //camera-independent by construction (every direction sees 1), so these
    //check each lens model makes only valid rays: no NaN, none lost
    pinholeCamera:  one(ball, () => matte({diffuse: WHITE}), {ui: {lens: 'pinhole'}}),
    thinLensCamera: one(ball, () => matte({diffuse: WHITE}), {ui: {lens: 'thinLens', aperture: 0.2, focalLength: 5}}),
    orthoCamera:    one(ball, () => matte({diffuse: WHITE}), {ui: {lens: 'orthographic', aperture: 0.2, focalLength: 5}}),

    //---- light aiming ------------------------------------------------------
    //a lamp of radiance exactly 1 (it emits 1 and reflects nothing) beside the
    //ball: every direction still sees 1, so however diffuse bounces aim at the
    //lamp, their weights must average back to exactly 1
    aimedLight:    furnace(() => [
        object('thing', {at: [0, 0, 0], shape: ball(), material: matte({diffuse: WHITE})}),
        object('lamp',  {at: [1.6, 1.1, 0.8], shape: lib.sphere({radius: 0.5}),
                         material: material({surf: {emit: WHITE, diffuse: CLEAR}})}),
    ], {noisy: true}),
};
