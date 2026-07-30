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

//the original art pose, carried over verbatim from the legacy scene
let position = [-0.22434820231330066, 2.695685136141385, -14.131184849491484];

let facing = [-0.9413490868639125, -0.05507316981210375, -0.3329096613607225, -0.16449386728565513, 0.9363206888416046, 0.31023432316972627, 0.2946246158858293, 0.34680039448364935, -0.8904638241389158];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'rotation',  label: 'Rotation',   min: 0, max: 1, step: 0.01, value: 0.73 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location: location, params: params};
