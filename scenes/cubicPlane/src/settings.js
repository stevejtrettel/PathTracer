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


//x=2 so effective camera (position + CAMERA_OFFSET.x=-2) sits at x=0, centering
//the plate diagram (which is at the origin) horizontally
let position = [2, 5, -4];

let facing = [1, 0, 0, 0, 0.6, 0.8, 0, -0.8, 0.6];

let location = {
    position: position,
    facing: facing
};

export {location};

export default {uiParams: uiParams, location:location};
