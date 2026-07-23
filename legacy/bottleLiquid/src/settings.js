let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 62,
}

export {uiParams};


let position = [-0.3108664886915453,5.336140089058401,6.324100656700949];

let facing = [0.8333690207748797,0.14959602802248775,-0.5320874962000339,0.06646440183394467,0.9285674421753304,0.36516433098085666,0.5487062588502066,-0.3396815180897093,0.763896529489903];

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