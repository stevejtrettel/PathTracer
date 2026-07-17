//-------------------------------------------------
// KNOBS
//-------------------------------------------------
// One "knob" = one tunable control declared as data:
//
//     { name, label, type, min, max, step, value, group }
//
// A knob is written ONCE and generates the three things that used to be
// hand-synced across five files:
//     1. the GLSL uniform declaration          knobUniformDecls()
//     2. the uniform object                    knobUniforms()
//     3. the settings.js serialization         serializeKnobs()
//
// type ∈ float | int | bool | color | vec2 | vec3  (color is a vec3 with a picker)

import {Vector2, Vector3} from "../math/index.js";


// GLSL uniform type per knob type
const GLSL_TYPE = {
    float: 'float',
    int:   'int',
    bool:  'bool',
    color: 'vec3',
    vec2:  'vec2',
    vec3:  'vec3',
};


// fill in defaults so a knob can be as short as {name, value}
function normalize(knob){
    let type = knob.type ?? 'float';
    return {
        type:  type,
        name:  knob.name,
        label: knob.label ?? knob.name,
        min:   knob.min ?? 0,
        max:   knob.max ?? 1,
        step:  knob.step ?? 0.001,
        value: knob.value,
        group: knob.group ?? 'scene',
    };
}


// a knob's stored value -> the value the renderer wants in the uniform
function toUniformValue(k, value){
    switch(k.type){
        case 'color':
        case 'vec3': return new Vector3(value[0], value[1], value[2]);
        case 'vec2': return new Vector2(value[0], value[1]);
        default:     return value;   // float, bool
    }
}


// 1. GLSL:  `uniform float name;` lines, ready to inject into the shader
function knobUniformDecls(knobs){
    return knobs
        .map(normalize)
        .map(k => `uniform ${GLSL_TYPE[k.type]} ${k.name};`)
        .join('\n');
}


// 2. uniforms:  { name: {value}, ... }
function knobUniforms(knobs){
    let uniforms = {};
    for(let knob of knobs){
        let k = normalize(knob);
        uniforms[k.name] = { value: toUniformValue(k, k.value) };
    }
    return uniforms;
}


// override each knob's initial value from a {name: value} map (a scene's
// settings.uiParams). Used for the engine knobs, whose list is fixed but whose
// values are per-scene. Missing keys keep the knob's own default.
function withValues(knobs, valueMap){
    return knobs.map(k => ({...k, value: valueMap?.[k.name] ?? k.value}));
}


// a knob's current value (from `values`, falling back to its default),
// formatted as a JS literal for the serializers below
function serializedValue(k, values){
    let v = values[k.name] ?? k.value;
    return Array.isArray(v) ? `[${v.join(', ')}]` : v;
}


// serialize engine knobs back to the flat `uiParams` object (the legacy
// settings.js format) with current values. Companion to serializeKnobs, which
// emits the `params` array for named scene knobs.
function serializeUiParams(knobs, values){
    let rows = knobs.map(normalize).map(k => {
        return `    ${k.name}: ${serializedValue(k, values)},`;
    });
    return `let uiParams = {\n${rows.join('\n')}\n}\n\nexport {uiParams};`;
}


// 3. settings.js:  the `export const params = [...]` block, with current values
function serializeKnobs(knobs, values){
    let rows = knobs.map(normalize).map(k => {
        let parts = [`name: '${k.name}'`];
        if(k.type !== 'float') parts.push(`type: '${k.type}'`);
        if(k.label !== k.name) parts.push(`label: '${k.label}'`);
        if(k.type === 'float' || k.type === 'int' || k.type === 'vec2' || k.type === 'vec3'){
            parts.push(`min: ${k.min}`, `max: ${k.max}`, `step: ${k.step}`);
        }
        parts.push(`value: ${serializedValue(k, values)}`);
        return `    { ${parts.join(', ')} },`;
    });
    return `export const params = [\n${rows.join('\n')}\n];`;
}


export {knobUniformDecls, knobUniforms, serializeKnobs, withValues, serializeUiParams, toUniformValue};
