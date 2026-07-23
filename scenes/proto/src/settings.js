let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1,
    focusHelp: false,
    fov: 85,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


//world camera = position + CAMERA_OFFSET(-2,0,6), so this sits at (0,3,6):
//inside the room (interior z in [-10,10]), looking slightly down at the row.
//Aim it by flying + Save to Scene rather than editing these by hand.
let position = [2.0, 3.2, 3.0];

let facing = [
    1.0,  0.0,    0.0,
    0.0,  0.981,  0.196,
    0.0, -0.196,  0.981,
];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'roomLight', label: 'Room Light', min: 0, max: 3,  step: 0.01, value: 0.35 },
    { name: 'lampPower', label: 'Lamp Power', min: 0, max: 80, step: 0.5,  value: 30.  },
    { name: 'polish',    label: 'Marble Polish', min: 0, max: 1, step: 0.01, value: 0.25 },
];

export default {uiParams: uiParams, location: location, params: params};
