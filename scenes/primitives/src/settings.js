let uiParams = {
    aperture: 0,
    focalLength: 13,
    exposure: 1,
    focusHelp: false,
    fov: 40,
    spectral: false,
    dispersion: 0.2,
    maxBounces: 6,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//CAMERA_OFFSET = (-2,0,6) is added in the shader, so this puts the eye (0, 4.4, 20)
let position = [2, 4.4, 22];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'solidSize',  label: 'Platonic Inradius', min: 0.4, max: 2.0, step: 0.01, value: 1.1 },
    { name: 'coneTop',    label: 'Cone Top Radius',   min: 0.0, max: 1.4, step: 0.01, value: 0.35 },
    { name: 'rimRound',   label: 'Cylinder Rim',      min: 0.0, max: 0.6, step: 0.01, value: 0.12 },
    { name: 'tubeRadius', label: 'Torus Tube',        min: 0.1, max: 0.8, step: 0.01, value: 0.38 },
    { name: 'capRadius',  label: 'Capsule Radius',    min: 0.1, max: 0.9, step: 0.01, value: 0.42 },
    { name: 'frameEdge',  label: 'BoxFrame Strut',    min: 0.02, max: 0.4, step: 0.01, value: 0.11 },
    { name: 'hourFlare',  label: 'Hourglass Flare',   min: 0.2, max: 1.3, step: 0.01, value: 0.8 },
];

export default {uiParams: uiParams, location: location, params: params};
