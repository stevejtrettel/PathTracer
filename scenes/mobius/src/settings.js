let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 42,
}

export {uiParams};


let position = [5.038585716032173,8.73028383143686,4.3078682075183545];

let facing = [0.8441553550729692,-0.2793228048739361,0.45758114818990425,0.031638454397953965,0.8780084343052899,0.4775983642057115,-0.53516422218302,-0.38869005642799676,0.7500128634424096];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'sssScatter', label: 'Scatter', min: 0, max: 1, step: 0.01, value: 0.877 },
    { name: 'sssDensity', label: 'Density', min: 0, max: 1, step: 0.01, value: 0.557 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location:location, params: params};