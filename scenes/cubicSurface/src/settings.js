let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 66,
    spectral: false,
    dispersion: 0.2,
    maxBounces: 12,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//carried over from the legacy scene: CAMERA_OFFSET (-2,0,6) is added in the
//shader, so this puts the eye at (0, 1, 11) looking down -z at the surface,
//which sits at the origin inside a radius-2 ball
let position = [2, 1, 5];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'lineRadius', label: 'Line Thickness', min: 0.004, max: 0.06, step: 0.001, value: 0.02 },
    { name: 'ringRadius', label: 'Ring Thickness', min: 0.002, max: 0.05, step: 0.001, value: 0.01 },
    { name: 'shellDepth', label: 'Surface Shell',  min: 0.006, max: 0.08, step: 0.001, value: 0.02 },
    { name: 'roomLight',  label: 'Room Light',     min: 0,     max: 2,    step: 0.01,  value: 0.5 },
];

export default {uiParams: uiParams, location: location, params: params};
