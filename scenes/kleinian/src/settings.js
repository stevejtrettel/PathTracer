let uiParams = {
    aperture: 0,
    focalLength: 7,
    exposure: 1,
    focusHelp: false,
    fov: 33,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//position = ro - CAMERA_OFFSET(-2,0,6); facing rows = [right | up | -forward]
let position = [7.0, 0.0, -1.0];

let facing = [
    0.7071, 0.0,  0.7071,
    0.0,    1.0,  0.0,
   -0.7071, 0.0,  0.7071,
];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'kleinR', label: 'Klein R',             min: 1.4, max: 2.2, step: 0.001, value: 1.8 },
    { name: 'kleinI', label: 'Klein I',             min: 0.0, max: 2.0, step: 0.001, value: 1.8 },
    { name: 'detail', label: 'Detail (iterations)', type: 'int', min: 10, max: 22, step: 1, value: 17 },
];

export default {uiParams: uiParams, location: location, params: params};
