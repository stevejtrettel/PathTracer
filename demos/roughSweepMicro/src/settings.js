let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 38,
    maxBounces: 16,
}

export {uiParams};


//camera: identical to demos/roughSweep — the point is a pixel-comparable A/B.
let position = [0, 3.2, 15];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'maxRough',   label: 'Max Rough',   min: 0, max: 1,   step: 0.01, value: 0.6 },
    { name: 'lightPower', label: 'Light Power', min: 0, max: 400, step: 1,    value: 60 },
    { name: 'roomLight',  label: 'Room Light',  min: 0, max: 2,   step: 0.01, value: 0.25 },
];

//the whole point of this page: one-microfacet-per-event roughness
//(+ multi-bounce), see docs/material-system.md §4/§6b
let defines = ['MICROFACET_ROUGHNESS'];

export default {uiParams: uiParams, location: location, params: params, defines: defines};
