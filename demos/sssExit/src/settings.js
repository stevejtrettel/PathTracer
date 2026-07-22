let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 38,
    maxBounces: 16,
}

export {uiParams};


//camera: level view from +z over the row.
let position = [0, 2.6, 13];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'sssDensity',     label: 'MFP Scale',   min: 0.05, max: 4,  step: 0.01, value: 1 },
    { name: 'sssScatter',     label: 'Scatter Blur', min: 0,    max: 1,  step: 0.01, value: 0.5 },
    { name: 'absorbStrength', label: 'Absorb',      min: 0,    max: 60, step: 0.5,  value: 20 },
    { name: 'lightPower',     label: 'Light Power', min: 0,    max: 400, step: 1,   value: 60 },
    { name: 'roomLight',      label: 'Room Light',  min: 0,    max: 2,  step: 0.01, value: 0.25 },
];

export default {uiParams: uiParams, location: location, params: params};
