
//Uniforms for the tracer
//=============================================

//background sky texture
import {Matrix3, TextureLoader, Vector3} from "three";

const skyTex = new TextureLoader().load('/assets/office.jpg');

import setupShaderChunk from "../../glsl/tracer/setupShader.glsl"
import traceShaderChunk from "../../glsl/tracer/traceShader.glsl"

import {knobUniformDecls, knobUniforms, withValues} from "./knobs.js";
import {engineKnobs} from "./engineKnobs.js";


let buildTraceShader= function(sceneData, settings){

    let sceneShaderChunk = '';
    for(let key in sceneData){
        sceneShaderChunk = sceneShaderChunk.concat(sceneData[key]);
    }

    let location = settings.location;
    let uiParams = settings.uiParams;

    //all tunable controls are knobs: the engine-owned camera/render/scratch
    //knobs (values from settings.uiParams) plus this scene's named params.
    //One generator produces their GLSL uniform decls, three.js uniforms, GUI,
    //and serialization (see js/shaderData/knobs.js).
    let sceneParams = settings.params ?? [];
    let allKnobs = [...withValues(engineKnobs, uiParams), ...sceneParams];

    //inject the uniform declarations at the TOP: camera knobs are used inside
    //the setup chunk (camera.glsl), so they must be declared before it.
    let knobDecls = `//--- generated uniforms (knobs) ---\n` + knobUniformDecls(allKnobs) + `\n`;
    let tracerShader = knobDecls.concat(setupShaderChunk).concat(sceneShaderChunk).concat(traceShaderChunk);


    let tracerUniforms = {

        //default resultion and framenumber
        iResolution: {
            value: new Vector3(window.innerWidth, window.innerHeight, 0.)
        },
        frameNumber: {
            value: 0
        },

        //loaded directly above: skybox image
        sky: {
            value: skyTex
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
        uniforms: tracerUniforms
    }
}

export default buildTraceShader;

