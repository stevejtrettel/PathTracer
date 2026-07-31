
//Uniforms for the tracer
//=============================================

import {Matrix3, Vector3} from "../math/index.js";

import setupShaderChunk from "../../glsl/tracer/setupShader.glsl"
import traceShaderChunk from "../../glsl/tracer/traceShader.glsl"

import {knobUniformDecls, knobUniforms, withValues} from "./knobs.js";
import {engineKnobs} from "./engineKnobs.js";


//the sky a ray sees when it escapes, from settings.sky (default: a dark
//neutral solid — scenes opt into an image sky explicitly, see scenes/skyDemo):
//  '/path.jpg'                                     image (shorthand)
//  { type:'image',    src:'/path.jpg' }            image
//  { type:'solid',    color:[r,g,b] }              flat color
//  { type:'gradient', top:[r,g,b], bottom:[r,g,b] } vertical gradient
const SKY_MODE = {image: 0, solid: 1, gradient: 2};

//a plain DESCRIPTOR (no GL object): the uniforms are assembled before the WebGL
//context exists, so PathTracer builds the actual sky texture from this later.
function buildSky(sky){
    if(sky === undefined) sky = {type: 'solid', color: [0.05, 0.05, 0.07]};
    if(typeof sky === 'string') sky = {type: 'image', src: sky};

    let mode = SKY_MODE[sky.type] ?? 0;

    let color1 = sky.color ?? sky.top ?? [1,1,1];       //solid / gradient top
    let color2 = sky.bottom ?? sky.color ?? [1,1,1];    //gradient bottom

    return {
        mode: mode,
        src:  (mode === 0) ? (sky.src ?? '/assets/office.jpg') : null,
        color1: new Vector3(color1[0], color1[1], color1[2]),
        color2: new Vector3(color2[0], color2[1], color2[2]),
    };
}


//---------------------------------------------------------------- marching
// The marcher's tuning constants, generated as ONE block with real numbers.
//
// They used to be scattered consts in 1Setup/uniforms.glsl and 6Trace/raymarch.glsl.
// They live here because a scene may override them (`march: {...}` in its
// description) — and they are written as plain VALUES rather than #define hooks
// because we assemble this shader ourselves: there is no separate compilation
// unit to guard against, so there is nothing to preprocess around.
//
// AT_THRESH IS DERIVED, which is the point of the block. Its contract is that it
// must contain every point the marcher can land on, or setData silently sets
// nothing and the bounce reuses stale LocalData. raymarch accepts a hit at radius
// < EPSILON*(1 + MARCH_CONE*t) and backs off by EPSILON, so a landing can sit at
// |sdf| up to EPSILON*(2 + MARCH_CONE*t), with t up to maxDist. A scene that made
// EPSILON coarser against a frozen AT_THRESH would get a band too NARROW — a
// silent, intermittent wrong-material bug. Deriving it makes that unreachable.
//
// The margin reproduces the value this constant had when it was hand-tuned:
// 1.2*0.001*(2 + 0.005*100) = 0.003, exactly.
const MARCH_DEFAULTS = {epsilon: 0.001, maxDist: 100, maxSteps: 2000};

function marchBlock(march = {}){
    const known = ['epsilon', 'maxDist', 'maxSteps'];
    for(const k of Object.keys(march)){
        if(!known.includes(k)){
            throw new Error(`scene march: unknown key '${k}' (have: ${known.join(', ')})`);
        }
        if(typeof march[k] !== 'number' || !(march[k] > 0)){
            throw new Error(`scene march: '${k}' must be a positive number, got ${march[k]}`);
        }
    }
    const m = {...MARCH_DEFAULTS, ...march};
    //integer-valued floats keep their .0, matching the emitter's number rule
    const f = (x) => Number.isInteger(x) ? `${x}.0` : String(x);

    return `//--- marching constants (generated; a scene overrides them via march:) ---\n`
        + `const float EPSILON       = ${f(m.epsilon)};\n`
        + `const float maxDist       = ${f(m.maxDist)};\n`
        + `const int   maxMarchSteps = ${m.maxSteps};\n\n`
        + `//over-relaxed sphere tracing (Keinert 2014): the step multiplier, and the\n`
        + `//cone that widens the hit radius with distance. Tuned by eye, not knobs.\n`
        + `const float MARCH_RELAX   = 1.2;\n`
        + `const float MARCH_CONE    = 0.005;\n\n`
        + `//the hit-classification band, DERIVED so it can never go stale against\n`
        + `//EPSILON — see the contract in js/shaderData/buildTraceShader.js\n`
        + `const float AT_THRESH_MARGIN = 1.2;\n`
        + `const float AT_THRESH = AT_THRESH_MARGIN*EPSILON*(2. + MARCH_CONE*maxDist);\n\n`;
}


let buildTraceShader= function(sceneData, settings){

    //newline separators are load-bearing: the glsl plugin can drop a chunk's
    //trailing newline, and a preprocessor directive glued to the previous
    //chunk's last line ("}#define SCENE_…") is a compile error.
    let sceneShaderChunk = '\n';
    for(let key in sceneData){
        sceneShaderChunk = sceneShaderChunk.concat(sceneData[key], '\n');
    }

    let location = settings.location;
    let uiParams = settings.uiParams;
    let sky = buildSky(settings.sky);

    //all tunable controls are knobs: the engine-owned camera/render/scratch
    //knobs (values from settings.uiParams) plus this scene's named params.
    //One generator produces their GLSL uniform decls, uniform objects, and
    //serialization (see js/shaderData/knobs.js).
    let sceneParams = settings.params ?? [];
    let allKnobs = [...withValues(engineKnobs, uiParams), ...sceneParams];

    //scene-injected compile-time switches: settings.defines = ['NAME', ...] each
    //become a #define at the very TOP of the shader — above every tracer chunk —
    //so gated engine code compiled BEFORE the scene chunk (e.g. scatterPath.glsl's
    //MICROFACET_ROUGHNESS) can see them. The scene-hook pattern (#ifndef SCENE_…
    //in 6Trace) covers hooks AFTER the scene chunk; this covers the ones before.
    let defineList = settings.defines ?? [];
    let defineBlock = defineList.length
        ? `//--- scene defines ---\n` + defineList.map((d) => `#define ${d}`).join('\n') + `\n\n`
        : '';

    //inject the uniform declarations at the TOP: camera knobs are used inside
    //the setup chunk (camera.glsl), so they must be declared before it.
    let knobDecls = `//--- generated uniforms (knobs) ---\n` + knobUniformDecls(allKnobs) + `\n`;
    //marching constants first: the setup chunk already uses maxDist (analytic
    //trace functions return it), so they must be declared above it
    let march = marchBlock(settings.march);
    let tracerShader = defineBlock.concat(march).concat(knobDecls).concat(setupShaderChunk).concat(sceneShaderChunk).concat(traceShaderChunk);


    let tracerUniforms = {

        //default resolution and framenumber
        iResolution: {
            value: new Vector3(window.innerWidth, window.innerHeight, 0.)
        },
        frameNumber: {
            value: 0
        },

        //environment the ray sees on escape (see buildSky above). The texture is
        //built by PathTracer once the gl context exists; null until then.
        sky: {
            value: null
        },
        skyMode: {
            value: sky.mode
        },
        skyColor1: {
            value: sky.color1
        },
        skyColor2: {
            value: sky.color2
        },


        //imported from settings: location
        facing: {
            value: new Matrix3().set(
                location.facing[0],location.facing[1],location.facing[2],
                location.facing[3],location.facing[4],location.facing[5],
                location.facing[6],location.facing[7],location.facing[8]
            )
        },
        location: {
            value: new Vector3(
                location.position[0], location.position[1], location.position[2]
            )
        },


        //HD Rendering Default = disabled
        renderPanel: {
            value: false,
        },
        numPanels: {
            value: 1,
        },
        panelToRender: {
            value: 0,
        }

    };

    //add a uniform for every knob (camera/render/scratch + scene params)
    Object.assign(tracerUniforms, knobUniforms(allKnobs));


    return {
        shader: tracerShader,
        uniforms: tracerUniforms,
        sky: sky,                //descriptor: PathTracer builds the GL texture
    }
}

export default buildTraceShader;

