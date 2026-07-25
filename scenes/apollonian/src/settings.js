let uiParams = {
    aperture: 0,
    focalLength: 12,
    exposure: 1,
    focusHelp: false,
    fov: 67,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//position = ro - CAMERA_OFFSET(-2,0,6); facing rows = [right | up | -forward]
let position = [0.6, 2.1, -12.3];

let facing = [
   -0.9761,  0.0671, -0.2063,
    0.0000,  0.9508,  0.3094,
    0.2170,  0.3020, -0.9282,
];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'morph', label: 'Morph (inversion r²)', min: 0.9, max: 1.3, step: 0.001, value: 1.2 },
];

export default {uiParams: uiParams, location: location, params: params};
