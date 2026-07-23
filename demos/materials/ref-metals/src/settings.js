let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 16,
}

export {uiParams};


//camera: level view from +z over both rows (identity facing looks down -z).
let position = [0, 3.4, 17];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


//`brushed` is the back row's roughness — push it up to watch the conductors
//saturate rather than grey out (multi-bounce facet reflections re-tint).
export const params = [
    { name: 'brushed',    label: 'Brushed Rough', min: 0, max: 1,   step: 0.01, value: 0.35 },
    { name: 'lightPower', label: 'Light Power',   min: 0, max: 400, step: 1,    value: 80 },
    { name: 'roomLight',  label: 'Room Light',    min: 0, max: 2,   step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location: location, params: params};
