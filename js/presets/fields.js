//-------------------------------------------------
// FIELD PRESETS — canonical height fields with their metadata filled in
//
// This is where the noise gradient bounds LIVE: |grad fbm(f*q)| <= 3.26*f,
// |grad fbm2(f*q)| <= 2.01*f (derivation in glsl/tracer/3Materials/
// fields.glsl). The core field() mechanism knows none of this — a preset is
// just a field with the declarations already written.
//-------------------------------------------------

import {field, glsl, valueText} from '../scenegen/index.js';


//centered noise height in [-0.5, 0.5]: the standard displacement driver.
//fbm2 (2 octaves) — displacement pays at every march step, and extra octaves
//cost hashes AND gradient (a longer Lipschitz divisor). freq: knob or number.
export function fbm2Height(name, freq){
    return field(`float ${name}(vec3 q){\n    return fbm2(${valueText(freq)}*q) - 0.5;\n}`,
                 {gradBound: glsl`2.01*${freq}`, range: [-0.5, 0.5]});
}

//4-octave version: finer detail, ~1.6x more gradient — fine for colour, pay
//attention to the march cost when displacing with it
export function fbmHeight(name, freq){
    return field(`float ${name}(vec3 q){\n    return fbm(${valueText(freq)}*q) - 0.5;\n}`,
                 {gradBound: glsl`3.26*${freq}`, range: [-0.5, 0.5]});
}
