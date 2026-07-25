let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1,
    focusHelp: false,
    fov: 60,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

let position = [2.0, 2.0, 3.0];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'fogMfp', label: 'Fog mean free path', min: 2, max: 40, step: 0.5, value: 8 },
];

export default {uiParams: uiParams, location: location, params: params};
