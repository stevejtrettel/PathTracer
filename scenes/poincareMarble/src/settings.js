let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 34,
    spectral: false,
    dispersion: 0.2,
    maxBounces: 24,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//CAMERA_OFFSET (-2,0,6) is added in the shader, so the eye sits at (0, 2.6, 11)
//level with the marble. Place it by eye.
let position = [2, 2.6, 5];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'coreRadius', label: 'Hollow Core', min: 0,  max: 0.35, step: 0.01, value: 0.0 },
    { name: 'roomLight',  label: 'Room Light',  min: 0,  max: 2,   step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location: location, params: params};
