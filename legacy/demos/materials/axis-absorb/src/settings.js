let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 24,      //glass wants depth: refract in, bounce, refract out
}

export {uiParams};


//camera: raised slightly, so the growing front row does not hide the back one.
let position = [0, 4.2, 16];

let facing = [1, 0, 0, 0, 0.98, 0.17, 0, -0.17, 0.98];

let location = {
    position: position,
    facing: facing
};

export {location};


//tintDepth is the distance at which the medium shows its nominal tint —
//the second argument of absorbFor, made draggable.
export const params = [
    { name: 'tintDepth',  label: 'Tint Depth',  min: 0.05, max: 6,   step: 0.05, value: 1 },
    { name: 'lightPower', label: 'Light Power', min: 0,    max: 400, step: 1,    value: 120 },
    { name: 'roomLight',  label: 'Room Light',  min: 0,    max: 2,   step: 0.01, value: 0.4 },
];

export default {uiParams: uiParams, location: location, params: params};
