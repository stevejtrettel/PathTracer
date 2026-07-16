import {Vector3} from "../math/index.js";

import accumulate from '../../glsl/accumulate/accumulate.glsl';


let  accShaderData =  {
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
};


export default accShaderData;
