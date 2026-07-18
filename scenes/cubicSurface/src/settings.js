let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 66,
}

export {uiParams};


//effective camera = position + CAMERA_OFFSET(-2,0,6) = (0,1,11), looking -z
//at the surface (IDENTITY_FRAME at the origin, radius ~2)
let position = [2, 1, 5];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location:location, params: params};
