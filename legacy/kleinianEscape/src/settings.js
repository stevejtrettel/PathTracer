let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1.0,
    focusHelp: false,
    fov: 33,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


//gradient sky lights the fractal and shows behind it
let sky = {
    type: 'gradient',
    top:    [0.42, 0.46, 0.55],
    bottom: [0.06, 0.04, 0.03],
};

export {sky};


//pose from the shadertoy at t=0: ro=(5,0,5) looking at the origin.
//position = ro - CAMERA_OFFSET(-2,0,6); facing rows = [right(cu) | up(cv) | -forward(cw)].
let position = [7.0, 0.0, -1.0];

let facing = [
    0.7071, 0.0,  0.7071,
    0.0,    1.0,  0.0,
   -0.7071, 0.0,  0.7071,
];

let location = {
    position: position,
    facing: facing
};

export {location};


//named knobs: each becomes a labeled GUI slider + a GLSL uniform of the same
//name. THE PARAMETER EXPLORER -- sweep KleinR/KleinI to morph the limit set.
export const params = [
    { name: 'kleinR', label: 'Klein R', min: 1.4, max: 2.2, step: 0.001, value: 1.8 },
    { name: 'kleinI', label: 'Klein I', min: 0.0, max: 2.0, step: 0.001, value: 1.8 },
    { name: 'detail', label: 'Detail (iterations)', type: 'int', min: 10, max: 22, step: 1, value: 17 },
];

export default {uiParams: uiParams, location: location, sky: sky, params: params};
