let uiParams = {
    aperture: 0,
    focalLength: 13,
    fov: 30,
    exposure: 1,
    maxBounces: 32,
    spectral: true,
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


let position = [0.07090756181980473,6.046950201482015,12.607014221268109];

let facing = [0.9943096396447139,0.034327381947244516,-0.10084627587695559,-0.012672416007063484,0.9780517403993415,0.20797644812421812,0.10577216260503948,-0.20551502122830276,0.9729212844148232]; 

let location = {
position: position,
facing: facing
};

export {location};

export const params = [
    { name: 'ior', label: 'Index of Refraction', min: 1, max: 2.6, step: 0.001, value: 2.42 },
    { name: 'gemTilt', label: 'Gem Tilt', min: -90, max: 90, step: 1, value: 12 },
    { name: 'lightPower', label: 'Light Power', min: 0, max: 6000, step: 5, value: 400 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0 },
    { name: 'floorColor', type: 'color', label: 'Floor', value: [0.55, 0.55, 0.55] },
    { name: 'warmColor', type: 'color', label: 'Left Wall', value: [0.012, 0.012, 0.012] },
    { name: 'coolColor', type: 'color', label: 'Right Wall', value: [0.012, 0.012, 0.012] },
    { name: 'wallColor', type: 'color', label: 'Walls', value: [0.012, 0.012, 0.012] },
    { name: 'wallRough', label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.3 },
];


export default {uiParams: uiParams, location: location, params: params};