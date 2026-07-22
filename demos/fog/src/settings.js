let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 38,
    maxBounces: 16,
}

export {uiParams};


//camera: level view from +z, looking through the fog toward the key light.
let position = [0, 3.2, 15];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'fogMFP',     label: 'Fog MFP',     min: 0.5, max: 60,  step: 0.5,   value: 12 },
    { name: 'fogBlur',    label: 'Fog Blur',    min: 0,   max: 1,   step: 0.01,  value: 0.7 },
    { name: 'fogAbsorb',  label: 'Fog Absorb',  min: 0,   max: 0.2, step: 0.001, value: 0.01 },
    { name: 'lightPower', label: 'Light Power', min: 0,   max: 600, step: 1,     value: 200 },
    { name: 'roomLight',  label: 'Room Light',  min: 0,   max: 2,   step: 0.01,  value: 0.02 },
];

export default {uiParams: uiParams, location: location, params: params};
