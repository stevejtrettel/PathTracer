//-------------------------------------------------
// NAMED MATERIALS — the whole material library, as presets over the primitives
//
// A material is a point in the model's parameter space (docs/generator.md §5),
// and everything named is a preset: a function returning a bundle. It is ONE
// flat space — the ARCHETYPES (matte..glow: the physically-canonical
// parameterizations, the discoverable menu) and their SPECIALIZATIONS
// (terracotta, honey, green glass, ...) differ only in how many fields they
// bind. The single primitive is material() (the escape hatch — raw struct
// fields); it and the merges live in js/scenegen/materials.js.
//
// NO RENAMES: an archetype's arguments are the model's REAL field names, so a
// scene and its emitted chunk speak one vocabulary. (A look may still take a
// perceptual `tint` that absorbFor() turns into the physical `absorb` field —
// a transformation, not an alias. Look-level param names are still being
// settled; the archetypes are the fixed point.)
//
// Ported from the legacy glsl/tracer/3Materials/presets.glsl (kept for
// hand-written GLSL callers until the variety scene and demo branch migrate).
// Tuning reference: demos/presets.
//-------------------------------------------------

import {material, withSurface, named, absorbFor, checkArgs} from '../scenegen/index.js';


//======== ARCHETYPES — the canonical parameterizations ====================

//pure diffuse: what walls actually are
export function matte(spec){
    checkArgs('matte', spec, ['diffuse']);
    return named('matte', material({surf: {diffuse: spec.diffuse}}));
}

//ARTISTIC gloss floor (no physical index): gloss = head-on reflectance,
//ramping to 1 at grazing
export function gloss(spec){
    checkArgs('gloss', spec, ['diffuse', 'gloss', 'roughness']);
    return named('gloss', material({surf: {diffuse: spec.diffuse, gloss: spec.gloss, roughness: spec.roughness}}));
}

//CONDUCTOR F0: `specular` is the metal's measured reflectance at normal
//incidence — also the (inert) diffuse. `gloss` is the Fresnel floor: 1 = full
//conductor, < 1 leaves a coloured "dirty metal" diffuse remainder.
export function metal(spec){
    checkArgs('metal', spec, ['specular', 'roughness'], ['gloss']);
    return named('metal', material({surf: {diffuse: spec.specular, specular: spec.specular,
                                           gloss: spec.gloss ?? 1, roughness: spec.roughness}}));
}

//PHYSICAL shiny-opaque: the interior index alone supplies the coat via the
//Fresnel gate; the interior is never entered (no transmit), so this stays a
//surface. ior is required — a typical dielectric index is a look, not a default.
export function plastic(spec){
    checkArgs('plastic', spec, ['diffuse', 'roughness', 'ior']);
    return named('plastic', material({surf: {diffuse: spec.diffuse, roughness: spec.roughness},
                                      interior: {ior: spec.ior}}));
}

//PURE-FRESNEL glass: `transmit` is the frost knob (1 = clear, the default);
//`absorb` is the interior extinction — absorbFor(tint, depth) sets it
export function glass(spec){
    checkArgs('glass', spec, ['absorb', 'ior'], ['transmit']);
    return named('glass', material({surf: {transmit: spec.transmit ?? 1},
                                    interior: {ior: spec.ior, absorb: spec.absorb}}));
}

//glass whose interior scatters: setting mfp is what compiles the walk in.
//transmit = 1 structurally — light enters the surface.
export function subsurface(spec){
    checkArgs('subsurface', spec, ['absorb', 'ior', 'mfp', 'blur']);
    return named('subsurface', material({surf: {transmit: 1},
                                         interior: {ior: spec.ior, absorb: spec.absorb,
                                                    mfp: spec.mfp, blur: spec.blur}}));
}

//surface emission. `emit` is the real field (radiance); compose power*colour
//at the call site if you want that decomposition (see sphereLight).
export function light(spec){
    checkArgs('light', spec, ['emit']);
    return named('light', material({surf: {emit: spec.emit}}));
}

//a glowing gas filling the shape: no interface (transmit = 1), volume emission
export function glow(spec){
    checkArgs('glow', spec, ['emit']);
    return named('glow', material({surf: {transmit: 1}, interior: {emit: spec.emit}}));
}

//a white Fresnel lacquer over any base: car paint, wet stone, varnish
export function withCoat(base, {coat = 1, coatRoughness = 0} = {}){
    return withSurface(base, {coat, coatRoughness});
}


//======== LOOKS — specializations with tuned values =======================
// a direct-to-field look uses the real field name; an absorbFor look takes a
// perceptual `tint`

//------ opaque ------------------------------------------------------------

//unglazed fired clay: matte with the faintest burnish
export const terracotta = ({diffuse = [0.71, 0.38, 0.26]} = {}) =>
    named('terracotta', gloss({diffuse, gloss: 0.03, roughness: 0.5}));

//glazed ceramic: a crisp white Fresnel glaze over flat pigment
export const tile = ({diffuse, glazeRoughness = 0}) =>
    named('tile', withCoat(matte({diffuse}), {coatRoughness: glazeRoughness}));

//soft wide highlight over deep pigment
export const rubber = ({diffuse}) =>
    named('rubber', gloss({diffuse, gloss: 0.04, roughness: 0.6}));

//a polished clear coat over rough metal flake
export const carPaint = ({specular, flakeRoughness = 0.4}) =>
    named('carPaint', withCoat(metal({specular, roughness: flakeRoughness})));

export const mirror = ({specular = [1, 1, 1]} = {}) =>
    named('mirror', metal({specular, roughness: 0}));

//measured F0 colours (linear): gold/copper strongly coloured, the rest neutral
const F0 = {
    gold:     [1.000, 0.766, 0.336],
    copper:   [0.955, 0.637, 0.538],
    brass:    [0.910, 0.778, 0.423],
    bronze:   [0.804, 0.498, 0.306],
    silver:   [0.972, 0.960, 0.915],
    aluminum: [0.913, 0.921, 0.925],
    iron:     [0.560, 0.570, 0.580],
    chrome:   [0.550, 0.556, 0.554],
};
const f0Metal = (name) => ({roughness}) =>
    named(name, metal({specular: F0[name], roughness}));

export const gold     = f0Metal('gold');
export const copper   = f0Metal('copper');
export const brass    = f0Metal('brass');
export const bronze   = f0Metal('bronze');
export const silver   = f0Metal('silver');
export const aluminum = f0Metal('aluminum');
export const iron     = f0Metal('iron');
export const chrome   = f0Metal('chrome');


//------ transmissive -------------------------------------------------------
// tint is perceptual; absorbFor turns it into the physical absorb field

//a clear liquid showing `tint` per unit of travel
export const liquid = ({tint, ior = 1.33}) =>
    named('liquid', glass({absorb: absorbFor(tint, 1.0), ior}));

export const honey = () =>
    named('honey', liquid({tint: [0.75, 0.45, 0.12], ior: 1.42}));

//colourless and highly refractive — colour comes from dispersion (spectral on)
export const diamond = ({tint = [1, 1, 1]} = {}) =>
    named('diamond', glass({absorb: absorbFor(tint, 2.0), ior: 2.42}));

//a glowing gas filling the shape
export const neon = ({emit}) =>
    named('neon', glow({emit}));

//a soap film: a THIN surface (use on a sheet) whose reflectance is thin-film
//interference — `film` thickness in nm, ~150-700 is the visible sweet spot
export const soapFilm = ({film}) =>
    material({surf: {transmit: 1, film}}, 'soapFilm');

//a thin oily coating over an opaque base: iridized highlights (oil ~1.45)
export const oilSlick = ({diffuse, film}) =>
    named('oilSlick', withSurface(matte({diffuse}), {film, filmIOR: 1.45}));


//------ subsurface ---------------------------------------------------------
// interior mfp (dense -> dilute) x surface finish (rough = waxy, smooth = stone)

//polished stone, deep colored glow
export const jade = ({tint, mfp = 0.1}) =>
    named('jade', subsurface({absorb: absorbFor(tint, 0.3), ior: 1.5, mfp, blur: 0.8}));

//dense, barely translucent, Fresnel-glazed by its own index
export const porcelain = ({tint = [0.94, 0.92, 0.87]} = {}) =>
    named('porcelain', subsurface({absorb: absorbFor(tint, 0.5), ior: 1.5, mfp: 0.02, blur: 1}));

//matte finish over a scattering interior (the rough exit is what makes it wax)
export const wax = ({tint, mfp = 0.12}) =>
    named('wax', withSurface(
        subsurface({absorb: absorbFor(tint, 0.5), ior: 1.5, mfp, blur: 0.9}),
        {roughness: 0.45}));

export const milk = ({tint = [0.93, 0.95, 1.0]} = {}) =>
    named('milk', subsurface({absorb: absorbFor(tint, 3.0), ior: 1.35, mfp: 0.03, blur: 1}));

//lightly polished stone: subtle veiny glow at edges
export const marble = ({tint, mfp = 0.06}) =>
    named('marble', withSurface(
        subsurface({absorb: absorbFor(tint, 1.0), ior: 1.5, mfp, blur: 1}),
        {roughness: 0.08}));
