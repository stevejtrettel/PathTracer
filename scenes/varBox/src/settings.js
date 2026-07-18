let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 66,
}

export {uiParams};


let position = [0.6176445298513266,3.290066052887829,0.8157927745246101];

let facing = [0.9212502835892487,0.1857547136151346,-0.3417500568490086,-0.020128163773305088,0.9001908329620385,0.4350302532860236,0.38844918845282767,-0.3938929430958844,0.8330399614480934];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'sssScatter', label: 'Scatter', min: 0, max: 1, step: 0.01, value: 0.73 },
    { name: 'sssDensity', label: 'Density', min: 0, max: 1, step: 0.01, value: 0.73 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location:location, params: params};
