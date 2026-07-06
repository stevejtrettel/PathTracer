
//Uniforms for the tracer
//=============================================

//background sky texture
import {Matrix3, TextureLoader, Vector3} from "three";

const skyTex = new TextureLoader().load('/assets/office.jpg');

import setupShaderChunk from "../../glsl/tracer/setupShader.glsl"
import traceShaderChunk from "../../glsl/tracer/traceShader.glsl"

import {knobUniformDecls, knobUniforms} from "./knobs.js";


let buildTraceShader= function(sceneData, settings){

    let sceneShaderChunk = '';
    for(let key in sceneData){
        sceneShaderChunk = sceneShaderChunk.concat(sceneData[key]);
    }

    //named scene parameters (knobs) declared in settings.js: generate their
    //GLSL uniform declarations and inject them just before the scene code.
    let sceneParams = settings.params ?? [];
    let paramDecls = `\n//--- scene params ---\n` + knobUniformDecls(sceneParams) + `\n`;

    let tracerShader = setupShaderChunk.concat(paramDecls).concat(sceneShaderChunk).concat(traceShaderChunk);

    let location = settings.location;
    let uiParams = settings.uiParams;


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


        //imported from settings: uiParams
        aperture: {
            value: uiParams.aperture
        },
        focalLength: {
            value: uiParams.focalLength
        },
        exposure: {
            value: uiParams.exposure
        },
        focusHelp: {
            value: false
        },
        fov: {
            value: uiParams.fov
        },
        maxBounces: {
            value: uiParams.maxBounces ?? 50
        },
        extra: {
            value: uiParams.extra
        },
        extra2: {
            value: uiParams.extra2
        },
        extra3: {
            value: uiParams.extra3
        },
        extra4: {
            value: uiParams.extra4
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

    //add a uniform for each named scene parameter
    Object.assign(tracerUniforms, knobUniforms(sceneParams));


    return {
        shader: tracerShader,
        uniforms: tracerUniforms
    }
}

export default buildTraceShader;

