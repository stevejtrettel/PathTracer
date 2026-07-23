let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 62,
}

export {uiParams};


let position = [-2.920570474892029,5.440804593985878,10.275012381895698];

let facing = [0.8333690207748797,0.06840206413805923,-0.5484680782271459,0.06646440183394467,0.9727101064037655,0.222300544733267,0.5487062588502066,-0.22171199002647812,0.8060801665944561];

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
