let uiParams = {
    aperture: 0.033,    //wide aperture -> shallow depth of field, like the original
    focalLength: 1.0,   //focus on the fractal (distance camPos->camTar * 1.1)
    exposure: 1.0,
    focusHelp: false,
    fov: 41,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


//gradient sky both lights the fractal and shows behind it
let sky = {
    type: 'gradient',
    top:    [0.55, 0.72, 1.00],
    bottom: [0.10, 0.14, 0.22],
};

export {sky};


//pose converted from the shadertoy's camPos/camTar (offset baked into the sdf,
//so world coords == the shadertoy's). position = camPos - CAMERA_OFFSET(-2,0,6);
//facing rows = [RIGHT(-uu) | UP(vv) | -FORWARD(-ww)].
let position = [1.1654, -0.1214, -6.4026];

let facing = [
   -0.33783,  0.23444, -0.91155,
    0.75073,  0.65127, -0.11075,
    0.56769, -0.72174, -0.39603,
];

let location = {
    position: position,
    facing: facing
};

export {location};


//named knob: iteration count (fractal detail; ~80 matches the original)
export const params = [
    { name: 'detail', label: 'Detail (iterations)', type: 'int', min: 20, max: 80, step: 1, value: 70 },
];

export default {uiParams: uiParams, location: location, sky: sky, params: params};
