let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 43,
}

export {uiParams};


let position = [0.04408199128962817,2.6787905918151256,-4.142461360687609];

let facing = [0.9233346655346455,0.37950821770376864,0.058537237013255236,-0.38040667067952505,0.8832177299977693,0.274257554718174,0.052381870187699624,-0.27549946299906297,0.9598730049140389];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'sssScatter', label: 'Scatter', min: 0, max: 1, step: 0.01, value: 0.926 },
    { name: 'sssDensity', label: 'Density', min: 0, max: 1, step: 0.01, value: 0.619 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.01 },
];

export default {uiParams: uiParams, location:location, params: params};
