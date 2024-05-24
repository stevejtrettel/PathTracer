import {Vector3, Matrix3, TextureLoader} from "three";

import accumulate from '/src/glsl/accumulate/accumulate.glsl';
import display from '/src/glsl/display/display.glsl';
import tracer from '/src/glsl/tracer/tracer.glsl';

import {uiParams,location} from "./settings.js";


//Uniforms for the tracer
//=============================================

//background sky texture
const skyTex = new TextureLoader().load('src/js/tex/office.jpg');
//background sky texture
const skyTexSmall = new TextureLoader().load('src/js/tex/office.jpg');


let traceUniforms={

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
    renderBlocks: {
        value: false
    },
    extra: {
        value: uiParams.extra
    },
    extra2: {
        value: uiParams.extra2
    },
    extra3: {
        value: uiParams.extra2
    },
    extra4: {
        value: uiParams.extra2
    },


    //HD Rendering Default = disabled
    renderPanels: {
        value: false,
    },
    numPanels: {
        value: 1,
    },
    panelToRender: {
        value: 1,
    }

};




//Assembling the shaders
//=============================================

const shaders = {
    tracer: {
        shader: tracer,
        uniforms: traceUniforms,
    },

    accumulate: {
        shader: accumulate,
        uniforms: {
            frameNumber: {
                value: 0
            },
            iResolution: {
                value: new Vector3(window.innerWidth, window.innerHeight, 0.)
            },
            accTex: {
                value: null
            },
            newTex: {
                value: null
            }
        },
    },

    display: {
        shader: display,
        uniforms: {
            iResolution: {
                value: new Vector3(window.innerWidth, window.innerHeight, 0.)
            },
            accTex: {
                value: null
            }
        }
    }
};

export default shaders;