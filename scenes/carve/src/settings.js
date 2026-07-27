let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1,
    focusHelp: false,
    fov: 72,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//world camera = position + CAMERA_OFFSET(-2,0,6). Aim by flying + Save to Scene.
let position = [2.7, 3.4, 7.5];

let facing = [
    1.0,  0.0,    0.0,
    0.0,  0.981,  0.196,
    0.0, -0.196,  0.981,
];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'erosion',   label: 'Erosion',       min: 0.0,  max: 1.0, step: 0.005, value: 0.85 },
    { name: 'gain',      label: 'Octave Gain',   min: 0.3,  max: 0.7, step: 0.005, value: 0.5 },
    { name: 'blend',     label: 'Bite Softness', min: 0.02, max: 0.4, step: 0.005, value: 0.15 },
    { name: 'detail',    label: 'Octaves', type: 'int', min: 1, max: 9, step: 1, value: 6 },
    { name: 'lampPower', label: 'Lamp Power', min: 0, max: 90, step: 0.5, value: 30. },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 3, step: 0.01, value: 1.0 },

    //--- the room: six walls, one region, all live ---
    { name: 'floorColor', type: 'color', label: 'Floor',      value: [0.55, 0.54, 0.52] },
    { name: 'warmColor',  type: 'color', label: 'Left Wall',  value: [0.50, 0.36, 0.30] },
    { name: 'coolColor',  type: 'color', label: 'Right Wall', value: [0.30, 0.35, 0.50] },
    { name: 'wallColor',  type: 'color', label: 'Walls',      value: [0.44, 0.44, 0.44] },
    { name: 'wallRough',  label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.45 },
];

export default {uiParams: uiParams, location: location, params: params};
