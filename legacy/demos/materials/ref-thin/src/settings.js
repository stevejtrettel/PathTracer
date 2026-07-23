let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 16,
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


//shadeRough converges the crossing ray toward Lambert transmission at 1:
//0 = stained glass (the bulb is visible through it), 1 = paper (even glow).
//Keep roomLight low — these pages are about light coming THROUGH the shades.
export const params = [
    { name: 'shadeRough', label: 'Shade Rough', min: 0, max: 1,   step: 0.01, value: 0.5 },
    { name: 'bulbPower',  label: 'Bulb Power',  min: 0, max: 200, step: 1,    value: 40 },
    { name: 'lightPower', label: 'Key Light',   min: 0, max: 400, step: 1,    value: 20 },
    { name: 'roomLight',  label: 'Room Light',  min: 0, max: 2,   step: 0.01, value: 0.08 },
];

export default {uiParams: uiParams, location: location, params: params};
