let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 29,
}

export {uiParams};


let position = [-3.0126253110828656,2.818905621714715,5.780456240995506];

let facing = [0.8317716007008322,0.25863527559746435,-0.4911861138957586,-0.17194918316611477,0.9613521101521096,0.21502464676051633,0.5278157658462889,-0.09439234355921591,0.8440975078753322];

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