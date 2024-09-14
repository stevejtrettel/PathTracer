import {Vector3} from "three";

import display from '../glsl/display/display.glsl';

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
