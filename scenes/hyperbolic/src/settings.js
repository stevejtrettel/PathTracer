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

//CAMERA_OFFSET = (-2,0,6) is added in the shader, so this puts the eye (0, 4.2, 17)
let position = [2, 4.2, 16];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'dihedral',   label: 'Cube Dihedral (< 4)', min: 2.0, max: 3.9, step: 0.01, value: 3.0 },
    { name: 'coreRadius', label: 'Hollow Core',         min: 0.0, max: 0.9, step: 0.01, value: 0.0 },
];

export default {uiParams: uiParams, location: location, params: params};
