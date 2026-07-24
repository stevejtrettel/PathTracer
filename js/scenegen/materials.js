//-------------------------------------------------
// MATERIALS — JS mirrors of the GLSL constructors (3Materials/material.glsl)
//
// Each mirror produces the TEXT of the matching GLSL constructor call, plus a
// `kind` the emitter reasons from: whether the interior is real (medium_ emits
// `.interior` vs `defaultMedium()`) and whether it scatters (any subsurface
// material in the scene -> SCENE_SUBSURFACE). Arguments may be numbers,
// [r,g,b] arrays, knobs, or glsl`` fragments (raw expressions).
//-------------------------------------------------

//a constructor argument is anything glsl`` can interpolate: numbers, [r,g,b]
//vectors, knobs, expression mirrors, raw glsl`` fragments — one shared rule
import {valueText as argText} from './glslTag.js';

//the extinction that shows `tint` after `depth` of travel — mirrors the GLSL
//helper, emitted as a call so the arithmetic stays in the library
export function absorbFor(tint, depth){
    return {__expr: true, text: `absorbFor(${argText(tint)}, ${argText(depth)})`};
}


// kind: 'surface' (no real interior), 'volume' (interior refracts/absorbs),
//       'subsurface' (interior scatters: compiles the medium walk in)
function mat(kind, text){
    return {__mat: true, kind, text};
}

export function makeMatte(color){
    return mat('surface', `makeMatte(${argText(color)})`);
}

export function makeGloss(color, gloss, roughness){
    return mat('surface', `makeGloss(${argText(color)}, ${argText(gloss)}, ${argText(roughness)})`);
}

export function makeMetal(color, specularity, roughness){
    return mat('surface', `makeMetal(${argText(color)}, ${argText(specularity)}, ${argText(roughness)})`);
}

export function makePlastic(color, roughness, ior = 1.5){
    return mat('surface', `makePlastic(${argText(color)}, ${argText(roughness)}, ${argText(ior)})`);
}

export function makeGlass(absorb, ior, clarity = 1){
    return mat('volume', `makeGlass(${argText(absorb)}, ${argText(ior)}, ${argText(clarity)})`);
}

export function makeSubsurface(absorb, ior, mfp, blur){
    return mat('subsurface', `makeSubsurface(${argText(absorb)}, ${argText(ior)}, ${argText(mfp)}, ${argText(blur)})`);
}

export function makeLight(color, power){
    return mat('surface', `makeLight(${argText(color)}, ${argText(power)})`);
}

//modifier: wraps any base constructor call
export function withCoat(base, coat = 1, coatRoughness = 0){
    if(!base || !base.__mat) throw new Error('scenegen: withCoat() wraps a material');
    return mat(base.kind, `withCoat(${base.text}, ${argText(coat)}, ${argText(coatRoughness)})`);
}

export function isMat(x){
    return !!(x && x.__mat === true);
}
