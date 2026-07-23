let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 22,
}

export {uiParams};


let position = [-9.709353885254124,5.652663825675289,12.118716138386164];

let facing = [0.815692261653397,0.14523137023825022,-0.559958912222419,-0.029175496952103974,0.9770692393380395,0.21091347021201615,0.5777498807063486,-0.15570340599356403,0.801225015027397];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'sssScatter', label: 'Scatter', min: 0, max: 1, step: 0.01, value: 0.73 },
    { name: 'sssDensity', label: 'Density', min: 0, max: 1, step: 0.01, value: 0.84 },
    { name: 'roughAmt', label: 'Roughness', min: 0, max: 1, step: 0.01, value: 0.368 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location:location, params: params};
