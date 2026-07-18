let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 66,
}

export {uiParams};


let position = [-6.290304754788599,5.12056084213657,-3.2762793258114473];

let facing = [0.49535759027535275,0.35595515501977837,-0.7924120048126735,-0.02574720671537458,0.917808154169187,0.39618843179321567,0.8683075141346889,-0.17585255117641213,0.4638080865420532];

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
