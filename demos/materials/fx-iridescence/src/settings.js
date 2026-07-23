let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 16,
    spectral: true,      //required: without it the film gives angle-only bands
}

export {uiParams};


//camera: level view from +z across the row (identity facing looks down -z).
let position = [0, 3.0, 15];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


//thickness sweeps every sphere through the interference orders together;
//filmIOR is the film's own index (soap/water ~1.33, oil ~1.45).
export const params = [
    { name: 'thickness',  label: 'Film (nm)',   min: 0, max: 900, step: 1,    value: 380 },
    { name: 'filmIOR',    label: 'Film IOR',    min: 1, max: 2,   step: 0.01, value: 1.45 },
    { name: 'lightPower', label: 'Light Power', min: 0, max: 400, step: 1,    value: 140 },
    { name: 'roomLight',  label: 'Room Light',  min: 0, max: 2,   step: 0.01, value: 0.2 },
];

export default {uiParams: uiParams, location: location, params: params};
