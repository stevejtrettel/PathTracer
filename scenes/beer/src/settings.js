let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 62,
}

export {uiParams};


let position = [0.2986175621846792,4.505845034725215,3.702245125666192];

let facing = [0.9836018092297768,0.02858751826607753,-0.17807367767050886,0.021827626094020613,0.9612307403435585,0.2748800075624779,0.17902803026010736,-0.274259398412944,0.9448442976296111];

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