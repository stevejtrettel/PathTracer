let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 38,
    maxBounces: 16,
    spectral: true,      //thin-film rainbows need per-ray wavelengths
}

export {uiParams};


//camera: straight on at the bubble row.
let position = [0, 2.8, 14];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'thickScale', label: 'Thickness x', min: 0.1, max: 3,   step: 0.01, value: 1 },
    { name: 'lightPower', label: 'Light Power', min: 0,   max: 600, step: 1,    value: 250 },
    { name: 'roomLight',  label: 'Room Light',  min: 0,   max: 2,   step: 0.01, value: 0.04 },
];

export default {uiParams: uiParams, location: location, params: params};
