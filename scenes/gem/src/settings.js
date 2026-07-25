let uiParams = {
    aperture: 0,
    focalLength: 13,
    exposure: 1,
    focusHelp: false,
    fov: 30,
    //dispersion scene: ship spectral ON. maxBounces high for deep TIR chains.
    spectral: true,
    dispersion: 0.2,
    maxBounces: 32,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//level view from +z at gem height (identity facing looks down -z)
let position = [0, 3.5, 13];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'ior',        label: 'Index of Refraction', min: 1.0, max: 2.6,  step: 0.001, value: 2.42 },
    { name: 'gemTilt',    label: 'Gem Tilt',            min: -90, max: 90,   step: 1,     value: 12 },
    { name: 'lightPower', label: 'Light Power',         min: 0,   max: 6000, step: 5,     value: 400 },
];

export default {uiParams: uiParams, location: location, params: params};
