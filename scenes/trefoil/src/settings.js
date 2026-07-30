let uiParams = {
    aperture: 0,
    focalLength: 13,
    exposure: 1,
    focusHelp: false,
    fov: 42,
    spectral: false,
    dispersion: 0.2,
    maxBounces: 6,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//CAMERA_OFFSET = (-2,0,6) is added in the shader, so this puts the eye (0, 5.2, 15)
let position = [2, 5.2, 14];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'knotSize', label: 'Knot Size', min: 2.0, max: 14.0, step: 0.1, value: 6.5 },
];

export default {uiParams: uiParams, location: location, params: params};
