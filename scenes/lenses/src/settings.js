let uiParams = {
    lens: 'thinLens',
    aperture: 0.4,
    focalLength: 14,
    exposure: 1,
    fov: 90,
    maxBounces: 8,
}

export {uiParams};


//the camera 1.8 above the floor at z = 8, looking a little down the room: the
//row of balls is 14 ahead (with the engine's CAMERA_OFFSET, the camera sits at
//position + (-2, 0, 6))
let position = [2.0, 1.8, 2.0];

let facing = [
    1, 0,      0,
    0, 0.9950, 0.0995,
    0, -0.0995, 0.9950,
];

let location = { position: position, facing: facing };

export {location};

export const params = [];

export default {uiParams: uiParams, location: location, params: params};
