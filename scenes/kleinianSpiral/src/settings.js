let uiParams = {
    aperture: 0,
    focalLength: 13,
    exposure: 1,
    focusHelp: false,
    fov: 46,
    spectral: false,
    dispersion: 0.2,
    maxBounces: 6,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//CAMERA_OFFSET (-2,0,6) is added in the shader, so this puts the eye at
//(0, 1.6, 6) looking down -z at the limit set. Place it by eye — this is an
//experiment page, not a composed shot.
let position = [2, 1.6, 0];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'invRadius', label: 'Inversion Radius',   min: 0.1,  max: 3.0, step: 0.01, value: 0.8 },
    { name: 'invY',      label: 'Inversion Centre y', min: -2.0, max: 3.0, step: 0.01, value: 0.96 },
    { name: 'invX',      label: 'Inversion Centre x', min: -2.0, max: 2.0, step: 0.01, value: 0.0 },
    { name: 'detail',    type: 'int', label: 'Iterations', min: 6, max: 60, step: 1, value: 24 },
    { name: 'fudge',     label: 'DE Fudge',           min: 0.05, max: 1.0, step: 0.01, value: 0.24 },
    { name: 'roomLight', label: 'Room Light',         min: 0,    max: 2,   step: 0.01, value: 0.6 },
];

export default {uiParams: uiParams, location: location, params: params};
