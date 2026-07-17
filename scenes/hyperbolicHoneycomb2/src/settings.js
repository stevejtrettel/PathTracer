let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1.3,
    focusHelp: false,
    fov: 66,
    scratch1: 0.6,   //fold depth: honeycomb detail toward the ideal boundary
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


//gradient sky lights the scene and shows behind the honeycomb
let sky = {
    type: 'gradient',
    top:    [0.50, 0.60, 0.72],
    bottom: [0.28, 0.38, 0.48],
};

export {sky};


//pose converted from the Shadertoy's orthonormal camera frame:
//  position = CAMERA_POS - CAMERA_OFFSET(-2,0,6)
//  facing rows = [RIGHT | UP | -DIR]
let position = [2.68535, 1.50286, 0.02741];

let facing = [
   -0.888298, -0.453970,  0.069559,
    0.458755, -0.869906,  0.181127,
   -0.021716,  0.192805,  0.980997,
];

let location = {
    position: position,
    facing: facing
};

export {location};

export default {uiParams: uiParams, location: location, sky: sky};
