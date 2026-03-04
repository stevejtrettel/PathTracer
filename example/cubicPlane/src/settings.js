let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 66,
    extra: 0.73,
    extra2: 0.73,
    extra3: 0.368,
    extra4: 0.5,
}

export {uiParams};


let position = [0, 5, -4];

let facing = [1, 0, 0, 0, 0.6, 0.8, 0, -0.8, 0.6];

let location = {
    position: position,
    facing: facing
};

export {location};

export default {uiParams: uiParams, location:location};
