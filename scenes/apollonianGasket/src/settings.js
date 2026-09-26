let uiParams = {
    aperture: 0,
    focalLength: 10.3,
    exposure: 1,
    focusHelp: false,
    fov: 24,
    spectral: false,
    dispersion: 0.2,
    maxBounces: 16,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//the legacy eye, re-aimed at the gasket (it sat off-centre and small at fov 42)
let position = [-7.227914966664514, 3.425884297140259, -1.6402922666599955];

let facing = [0.4272, 0.1422, -0.8929, 0, 0.9875, 0.1573, 0.9042, -0.0672, 0.4219];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'foldOffset', label: 'Fold Offset', min: 0.4, max: 0.6, step: 0.001, value: 0.5 },
    { name: 'roomLight',  label: 'Room Light',  min: 0, max: 2, step: 0.01,  value: 0.5 },
];

export default {uiParams: uiParams, location: location, params: params};
