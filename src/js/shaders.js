import {Vector3, Matrix3, TextureLoader} from "three";

import accumulate from '/src/glsl/accumulate/accumulate.glsl';
import display from '/src/glsl/display/display.glsl';
import tracer from '/src/glsl/tracer/tracer.glsl';

//Uniforms for the tracer
//=============================================

//background sky texture
const skyTex = new TextureLoader().load('src/js/tex/office.jpg');
//background sky texture
const skyTexSmall = new TextureLoader().load('src/js/tex/office.jpg');


let traceUniforms={
    iResolution: {
        value: new Vector3(window.innerWidth, window.innerHeight, 0.)
    },
    sky: {
        value: skyTex
    },
    skySM: {
        value: skyTexSmall
    },
    facing: {
        value: new Matrix3().identity()
    },
    location: {
        value: new Vector3(0, 0, 0)
    },
    frameNumber: {
        value: 0
    },

    aperture: {
        value: 0.0
    },
    focalLength: {
        value: 5.
    },
    exposure: {
        value: 1.
    },
    focusHelp: {
        value: false
    },
    fov: {
        value: 50
    },
    renderBlocks: {
        value: false
    },
    extra: {
        value: 0.5
    },
    extra2: {
        value: 0.5
    },
    extra3: {
        value: 0.5
    },
    extra4: {
        value: 0.5
    },
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