let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 42,
    maxBounces: 16,
}

export {uiParams};


//camera: level view from +z over both rows (identity facing looks down -z).
//orbit + Save to Scene to tune by eye.
let position = [0, 3.4, 15];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'polish',     label: 'Polished Roughness', min: 0, max: 0.5, step: 0.005, value: 0.04 },
    { name: 'brushRough', label: 'Brushed Roughness',  min: 0, max: 0.8, step: 0.005, value: 0.35 },
    { name: 'lightPower', label: 'Light Power',        min: 0, max: 400, step: 1,     value: 60 },
    { name: 'roomLight',  label: 'Room Light',         min: 0, max: 2,   step: 0.01,  value: 0.3 },
];

export default {uiParams: uiParams, location:location, params:params};
