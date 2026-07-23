let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 38,
    maxBounces: 16,
}

export {uiParams};


//camera: level view from +z over the row.
let position = [0, 3.2, 15];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


//coverage drives ALL SIX weathering layers at once — the point of the page
export const params = [
    { name: 'coverage',   label: 'Coverage',    min: 0, max: 1,   step: 0.01, value: 0.5 },
    { name: 'lightPower', label: 'Light Power', min: 0, max: 400, step: 1,    value: 80 },
    { name: 'roomLight',  label: 'Room Light',  min: 0, max: 2,   step: 0.01, value: 0.6 },
];

export default {uiParams: uiParams, location: location, params: params};
