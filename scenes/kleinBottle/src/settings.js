let uiParams = {
    aperture: 0,
    focalLength: 13,
    exposure: 1,
    focusHelp: false,
    fov: 42,
    spectral: false,
    dispersion: 0.2,
    maxBounces: 32,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//CAMERA_OFFSET = (-2,0,6) is added in the shader, so this puts the eye (0, 3.4, 13)
let position = [2, 3.4, 9];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'bottleSize', label: 'Bottle Size',    min: 0.2, max: 1.6,  step: 0.01,  value: 0.9 },
    { name: 'wallThick',  label: 'Wall Thickness', min: 0.01, max: 0.2, step: 0.005, value: 0.05 },
];

export default {uiParams: uiParams, location: location, params: params};
