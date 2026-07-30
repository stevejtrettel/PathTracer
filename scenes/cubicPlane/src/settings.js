let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    fov: 46,
    exposure: 1,
    maxBounces: 12,
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


let position = [2.0106401628973307,5.182230388097506,-5.556745003849963];

let facing = [0.9999926448815223,-0.0028640573029763165,0.002550952493301671,-0.0022321336557838177,0.10627645345186723,0.9943341153862889,-0.003118936068683175,-0.9943324960079802,0.10626927881726174]; 

let location = {
position: position,
facing: facing
};

export {location};

export const params = [
    { name: 'curveRadius', label: 'Line / Conic Radius', min: 0.005, max: 0.06, step: 0.001, value: 0.025 },
    { name: 'checkerRadius', label: 'Checker Radius', min: 0.03, max: 0.2, step: 0.005, value: 0.08 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
    { name: 'floorColor', type: 'color', label: 'Floor', value: [0.1006, 0.1194, 0.1412] },
    { name: 'warmColor', type: 'color', label: 'Left Wall', value: [0.1006, 0.1194, 0.1412] },
    { name: 'coolColor', type: 'color', label: 'Right Wall', value: [0.1006, 0.1194, 0.1412] },
    { name: 'wallColor', type: 'color', label: 'Walls', value: [0.1006, 0.1194, 0.1412] },
    { name: 'wallRough', label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.1 },
];


export default {uiParams: uiParams, location: location, params: params};