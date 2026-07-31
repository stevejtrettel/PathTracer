let uiParams = {
    aperture: 0,
    focalLength: 13,
    fov: 46,
    exposure: 1,
    maxBounces: 6,
    spectral: false,
    dispersion: 0.2,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
    uDebugMode: 0,
    dbgHeatScale: 128,
    dbgFocusBand: 0.1,
}

export {uiParams};


let position = [2.6911394671044144,2.820065325980304,-3.6218013592037597];

let facing = [0.9936293258336163,-0.03604781764048381,-0.10677695297579542,0.06627418721160365,0.9532215066440648,0.2949177705406393,0.09115094597906272,-0.30011550129004977,0.9495378828317214]; 

let location = {
position: position,
facing: facing
};

export {location};

export const params = [
    { name: 'invRadius', label: 'Inversion Radius', min: 0.1, max: 3, step: 0.01, value: 0.8 },
    { name: 'invCenter', type: 'vec2', label: 'Inversion Centre (x, y)', min: -2, max: 3, step: 0.01, value: [-0.3536585365853657, 0.9997141768292677] },
    { name: 'detail', type: 'int', label: 'Iterations', min: 6, max: 60, step: 1, value: 60 },
    { name: 'fudge', label: 'DE Fudge', min: 0.05, max: 1, step: 0.01, value: 0.24 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.6 },
    { name: 'floorColor', type: 'color', label: 'Floor', value: [0.1006, 0.1194, 0.1412] },
    { name: 'warmColor', type: 'color', label: 'Left Wall', value: [0.1006, 0.1194, 0.1412] },
    { name: 'coolColor', type: 'color', label: 'Right Wall', value: [0.1006, 0.1194, 0.1412] },
    { name: 'wallColor', type: 'color', label: 'Walls', value: [0.1006, 0.1194, 0.1412] },
    { name: 'wallRough', label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.1 },
];


export default {uiParams: uiParams, location: location, params: params};