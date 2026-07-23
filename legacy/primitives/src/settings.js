let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1,
    focusHelp: false,
    fov: 45,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


//camera looking slightly down at the row of primitives on the floor.
//world camera ~= (0,3,12); position = that - CAMERA_OFFSET(-2,0,6).
let position = [2.0, 3.0, 6.0];

let facing = [
    1.0,  0.0,    0.0,
    0.0,  0.981,  0.196,
    0.0, -0.196,  0.981,
];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.4 },
];

export default {uiParams: uiParams, location: location, params: params};
