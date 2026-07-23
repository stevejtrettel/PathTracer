let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 16,
}

export {uiParams};


//camera: raised view from +z over the 5x4 grid.
let position = [0, 6.5, 19];

let facing = [1, 0, 0, 0, 0.96, 0.28, 0, -0.28, 0.96];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'neonPower',  label: 'Neon Power',  min: 0, max: 20,  step: 0.1, value: 4 },
    { name: 'lightPower', label: 'Light Power', min: 0, max: 400, step: 1,   value: 100 },
    { name: 'roomLight',  label: 'Room Light',  min: 0, max: 2,   step: 0.01, value: 0.3 },
];

export default {uiParams: uiParams, location: location, params: params};
