let uiParams = {
    aperture: 0.02,      //mild depth of field, like the original
    focalLength: 2.16,   //focus just in front of the form (0.36 * focalLength 6)
    exposure: 1.0,
    focusHelp: false,
    fov: 21,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


//soft gradient sky lights the form
let sky = {
    type: 'gradient',
    top:    [0.50, 0.70, 1.00],
    bottom: [0.16, 0.20, 0.28],
};

export {sky};


//pose from the shadertoy: camPos=(0,0,2.4) looking at the origin, up=+y.
//position = camPos - CAMERA_OFFSET(-2,0,6); facing = identity (axis-aligned view).
let position = [2.0, 0.0, -3.6];

let facing = [
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0,
];

let location = {
    position: position,
    facing: facing
};

export {location};


//named knob: the breathing phase (0.5 = still pose; sweep 0->1 for the cycle)
export const params = [
    { name: 'breath', label: 'Breathing Phase', min: 0.0, max: 1.0, step: 0.001, value: 0.5 },
];

export default {uiParams: uiParams, location: location, sky: sky, params: params};
