let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    fov: 50,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


//world camera = position + CAMERA_OFFSET(-2,0,6): about 9 units back and 2.5
//up, looking slightly down at the row of balls. Fly it and Save to Scene.
let position = [2.0, 2.5, 3.0];

let facing = [
    1, 0, 0,
    0, 0.9848077530122080, 0.1736481776669303,
    0, -0.1736481776669303, 0.9848077530122080,
];

let location = { position: position, facing: facing };

export {location};

export default {uiParams: uiParams, location: location};
