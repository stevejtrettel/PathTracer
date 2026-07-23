let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 29,
}

export {uiParams};


let position = [-3.0126253110828656,2.818905621714715,5.780456240995506];

let facing = [0.9568508895670248,0.07337507324132644,-0.2811627175879555,-0.020936275243809675,0.9824872892838259,0.18514966587744666,0.28982416654504506,-0.17127412245416165,0.9416300374690048];

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