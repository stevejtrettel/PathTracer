let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 32,      //nested glass: many interfaces per path
}

export {uiParams};


//camera: level view from +z across the row (identity facing looks down -z).
let position = [0, 3.2, 15];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


//Drag shellIOR and watch the MIDDLE core stay invisible: it is pinned to the
//shell's index, so it is index-matched by construction. coreTint/coreDepth
//keep the matched core findable by absorption alone (Beer still bills the
//distance even when the surface is optically silent).
export const params = [
    { name: 'shellIOR',   label: 'Shell IOR',    min: 1,    max: 2.5, step: 0.01, value: 1.5 },
    { name: 'maxCoreIOR', label: 'Max Core IOR', min: 1,    max: 3,   step: 0.01, value: 2.4 },
    { name: 'coreTint',   type: 'color', label: 'Core Tint',   value: [0.55, 0.75, 0.95] },
    { name: 'coreDepth',  label: 'Core Depth',   min: 0.1,  max: 8,   step: 0.05, value: 2 },
    { name: 'lightPower', label: 'Light Power',  min: 0,    max: 400, step: 1,    value: 140 },
    { name: 'roomLight',  label: 'Room Light',   min: 0,    max: 2,   step: 0.01, value: 0.4 },
];

export default {uiParams: uiParams, location: location, params: params};
