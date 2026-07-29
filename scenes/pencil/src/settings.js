let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1,
    focusHelp: false,
    fov: 72,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//world camera = position + CAMERA_OFFSET(-2,0,6). Aim by flying + Save to Scene.
let position = [2.0, 3.6, 7.0];

let facing = [
    1.0,  0.0,    0.0,
    0.0,  0.981,  0.196,
    0.0, -0.196,  0.981,
];

let location = { position: position, facing: facing };

export {location};

//knob VALUES live here (Save-to-Scene rewrites this file); declarations
//live in scene.js — an empty list falls back to every declared default
export const params = [];

export default {uiParams: uiParams, location: location, params: params};
