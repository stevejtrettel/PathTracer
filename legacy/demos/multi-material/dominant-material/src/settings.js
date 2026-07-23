let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 32,      //nested glass: many interfaces per path
}

export {uiParams};


//camera: level view of the pair (identity facing looks down -z).
let position = [0, 3.0, 12];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


//`frost` is the core's surface roughness. It is stored on BOTH objects'
//core material — but only the right-hand object names the core dominant, so
//only the right-hand inclusion responds. That asymmetry is the whole page.
export const params = [
    { name: 'frost',      label: 'Core Frost',  min: 0,   max: 1,   step: 0.01, value: 0.35 },
    { name: 'coreIOR',    label: 'Core IOR',    min: 1,   max: 2.5, step: 0.01, value: 1.8 },
    { name: 'coreTint',   type: 'color', label: 'Core Tint',  value: [0.9, 0.55, 0.35] },
    { name: 'lightPower', label: 'Light Power', min: 0,   max: 400, step: 1,    value: 140 },
    { name: 'roomLight',  label: 'Room Light',  min: 0,   max: 2,   step: 0.01, value: 0.4 },
];

export default {uiParams: uiParams, location: location, params: params};
