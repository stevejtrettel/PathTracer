
//Uniforms for the tracer
//=============================================

//background sky texture
import {Matrix3, TextureLoader, Vector3} from "three";

const skyTex = new TextureLoader().load('src/js/tex/office.jpg');
//background sky texture
const skyTexSmall = new TextureLoader().load('src/js/tex/office.jpg');

import setupShaderChunk from "../glsl/tracer/setupShader.glsl"
import traceShaderChunk from "../glsl/tracer/traceShader.glsl"



let buildTraceShader= function(scene, settings){

    let walls = scene.walls;
    let objects = scene.objects;
    let lights = scene.lights;
    let sceneShaderChunk = walls.concat(lights).concat(objects);
    console.log(sceneShaderChunk);

    let tracerShader = setupShaderChunk.concat(sceneShaderChunk).concat(traceShaderChunk);




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

        //loaded directly above: skybox images
        sky: {
            value: skyTex
        },
        skySM: {
            value: skyTexSmall
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
        // renderBlocks: {
        //     value: false
        // },
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


    return {
        shader: tracerShader,
        uniforms: tracerUniforms
    }
}

export default buildTraceShader;

