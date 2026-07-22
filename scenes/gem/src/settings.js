let uiParams = {
    aperture: 0,
    focalLength: 12,
    exposure: 1,
    fov: 30,
    //this scene exists to show off spectral fire, so ship with it ON
    spectral: true,
    dispersion: 0.2,
    //brilliance IS deep TIR chains — the gem needs bounce depth
    maxBounces: 32,
}

export {uiParams};


//camera: level view from +z at gem height (identity facing looks down -z).
//orbit + Save to Scene to tune by eye.
let position = [0, 3.5, 13];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'ior',        label: 'Index of Refraction', min: 1.0, max: 2.6,  step: 0.001, value: 2.42 },
    { name: 'gemTilt',    label: 'Gem Tilt',            min: -90, max: 90,   step: 0.5,   value: 12 },
    //NOTE radiance-vs-flux: facet glints show the source's RADIANCE (power), not its
    //flux — shrinking a light at constant flux makes its specular images BRIGHTER.
    //Power scales the whole image linearly; raise it and the stone blazes white.
    { name: 'lightPower', label: 'Light Power',         min: 0,   max: 6000, step: 10,    value: 500 },
];

export default {uiParams: uiParams, location:location, params:params};
