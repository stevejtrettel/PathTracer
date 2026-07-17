
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


let buildTraceShader= function(sceneData, settings){

    let sceneShaderChunk = '';
    for(let key in sceneData){
        sceneShaderChunk = sceneShaderChunk.concat(sceneData[key]);
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

    //inject the uniform declarations at the TOP: camera knobs are used inside
    //the setup chunk (camera.glsl), so they must be declared before it.
    let knobDecls = `//--- generated uniforms (knobs) ---\n` + knobUniformDecls(allKnobs) + `\n`;
    let tracerShader = knobDecls.concat(setupShaderChunk).concat(sceneShaderChunk).concat(traceShaderChunk);


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

