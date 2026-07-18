let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 66,
}

export {uiParams};


let position = [-0.8961560743665195,6.46548931609581,-5.115967842311577];

let facing = [0.9508939138614952,0.23754444710512487,-0.19842731724867738,0.03611116968416936,0.5515657806635672,0.8333493703273049,0.307403233563069,-0.7995922868877395,0.5159025360903449];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location:location, params: params};
