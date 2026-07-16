import {Vector3} from "../math/index.js";

import display from '../../glsl/display/display.glsl';

let  displayShaderData = {
    shader: display,
    uniforms: {
        iResolution: {
            value: new Vector3(window.innerWidth, window.innerHeight, 0.)
        },
        accTex: {
            value: null
        }
    }
};

export default displayShaderData;
