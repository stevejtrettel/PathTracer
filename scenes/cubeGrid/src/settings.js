let uiParams = {
    aperture: 0,
    focalLength: 16,
    exposure: 1.2,
    focusHelp: false,
    fov: 45,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//a raised three-quarter view from off the corner of the block, the whole
//skyline in frame. eye(14, 7, 22) -> target(0, 1.5, 0)
//position = eye - CAMERA_OFFSET(-2,0,6); facing rows = [right | up | -forward]
let position = [16.0, 7.0, 16.0];

let facing = [
    0.8437, -0.1108,  0.5253,
    0.0000,  0.9785,  0.2064,
   -0.5368, -0.1741,  0.8255,
];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'towerHeight',  label: 'Tower Height',   min: 0.5,  max: 6.0,  step: 0.01,  value: 3.2 },
    { name: 'districtSize', label: 'District Size',  min: 0.02, max: 0.6,  step: 0.005, value: 0.13 },
    { name: 'cellJitter',   label: 'Cell Jitter',    min: 0.0,  max: 1.0,  step: 0.01,  value: 0.55 },
    { name: 'heightPower',  label: 'Height Falloff', min: 0.5,  max: 5.0,  step: 0.01,  value: 2.2 },
    { name: 'citySeed',     label: 'Seed',           min: 0.0,  max: 20.0, step: 0.5,   value: 3.0 },
    { name: 'paletteShift', label: 'Palette Shift',  min: 0.0,  max: 1.0,  step: 0.001, value: 0.12 },
    { name: 'barRough',     label: 'Bar Roughness',  min: 0.0,  max: 1.0,  step: 0.01,  value: 0.28 },
    { name: 'lampPower',    label: 'Lamp Power',     min: 0.0,  max: 8.0,  step: 0.05,  value: 1.0 },
    { name: 'lampChance',   label: 'Lamps',          min: 0.0,  max: 0.4,  step: 0.005, value: 0.03 },
    { name: 'metalChance',  label: 'Metal Bars',     min: 0.0,  max: 0.6,  step: 0.005, value: 0.18 },
];

export default {uiParams: uiParams, location: location, params: params};
