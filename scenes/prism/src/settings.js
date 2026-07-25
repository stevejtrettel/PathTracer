let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 34,
    //this scene exists to show spectral dispersion, so ship with it ON:
    //spectral is the master switch, dispersion the strength of the IOR shift.
    spectral: true,
    dispersion: 0.15,
    maxBounces: 24,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

let position = [-21.6, 11.3, 28.1];

let facing = [0.8100377389035106, 0.15664458153457878, -0.5650675504997376, -0.02716274776054038, 0.9726473942724095, 0.23069293779628824, 0.5857482792855832, -0.17152119837163077, 0.7921359932631443];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'ior',        label: 'Index of Refraction', min: 1.0, max: 2.5,  step: 0.001, value: 1.52 },
    { name: 'lightPower', label: 'Light Power',         min: 0,   max: 2500, step: 5,     value: 320 },
];

export default {uiParams: uiParams, location: location, params: params};
