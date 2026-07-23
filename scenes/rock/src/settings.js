let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1,
    focusHelp: false,
    fov: 60,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//world camera = position + CAMERA_OFFSET(-2,0,6). Aim by flying + Save to Scene.
let position = [2.0, 3.2, 3.0];

let facing = [
    1.0,  0.0,    0.0,
    0.0,  0.981,  0.196,
    0.0, -0.196,  0.981,
];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'rockAmp',   label: 'Displacement', min: 0, max: 0.6, step: 0.005, value: 0.28 },
    { name: 'rockFreq',  label: 'Feature Size', min: 0.3, max: 6, step: 0.05, value: 2.2  },
    { name: 'tintDepth', label: 'Colour follows Height', min: 0, max: 1, step: 0.01, value: 1.0 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 3,  step: 0.01, value: 1.1 },
    { name: 'lampPower', label: 'Lamp Power', min: 0, max: 90, step: 0.5,  value: 25.  },
];

export default {uiParams: uiParams, location: location, params: params};
