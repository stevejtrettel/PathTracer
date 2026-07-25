let uiParams = {
    aperture: 0,
    focalLength: 7,
    exposure: 1,
    focusHelp: false,
    fov: 45,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//camera on the +z axis, looking down -z at the cube at the origin
let position = [0, 0, 7];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'mass', label: 'Mass', min: 0, max: 0.5, step: 0.005, value: 0.25 },
];

export default {uiParams: uiParams, location: location, params: params};
