let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 29,
}

export {uiParams};


let position = [-14.110022332881364,6.280789948856104,0.9269533562920684];

let facing = [0.3535105677743531,0.3204434734886027,-0.8788323268805355,-0.050708019938349384,0.9446782253821477,0.32405516074068075,0.9340551242756734,-0.06999307670972493,0.35020278986170966];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'sssScatter', label: 'Scatter', min: 0, max: 1, step: 0.01, value: 0.73 },
    { name: 'sssDensity', label: 'Density', min: 0, max: 1, step: 0.01, value: 0.84 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location:location, params: params};