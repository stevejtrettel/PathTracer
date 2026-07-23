let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 24,      //glass wants depth: refract in, bounce, refract out
}

export {uiParams};


//camera: level view of a single sphere on the floor (identity looks down -z).
let position = [0, 2.6, 9];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


//the empty studio needs only roomLight (its ceiling IS the light source).
export const params = [
    { name: 'radius',    label: 'Radius',     min: 0.25, max: 4,  step: 0.01, value: 2 },
    { name: 'IOR',       label: 'IOR',        min: 1,    max: 2.5, step: 0.01, value: 1.5 },
    { name: 'roomLight', label: 'Room Light', min: 0,    max: 4,   step: 0.01, value: 1.2 },
];

export default {uiParams: uiParams, location: location, params: params};
