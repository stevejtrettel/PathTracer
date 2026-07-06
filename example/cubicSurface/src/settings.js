let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 66,
    scratch1: 0.73,
    scratch2: 0.73,
    scratch3: 0.368,
    scratch4: 0.5,
}

export {uiParams};


let position = [0, 2, -6];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};

export default {uiParams: uiParams, location:location};
