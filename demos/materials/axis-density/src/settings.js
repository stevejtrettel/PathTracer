let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 38,
    maxBounces: 16,
}

export {uiParams};


//camera: level view from +z over both rows (identity facing looks down -z).
let position = [0, 3.2, 15];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


//mfpScale shifts the whole sweep (the ballistic endpoint stays pinned);
//scatterBlur is the phase width: 0 forward-scatters, 1 is isotropic.
export const params = [
    { name: 'mfpScale',       label: 'MFP Scale',    min: 0.05, max: 4,   step: 0.01, value: 1 },
    { name: 'absorbStrength', label: 'Absorb',       min: 0,    max: 10,  step: 0.1,  value: 1 },
    { name: 'scatterBlur',    label: 'Scatter Blur', min: 0,    max: 1,   step: 0.01, value: 0.5 },
    { name: 'lightPower',     label: 'Light Power',  min: 0,    max: 400, step: 1,    value: 100 },
    { name: 'roomLight',      label: 'Room Light',   min: 0,    max: 2,   step: 0.01, value: 0.25 },
];

export default {uiParams: uiParams, location: location, params: params};
