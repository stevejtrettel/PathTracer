let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 38,
    maxBounces: 32,      //three nested media: many interfaces per path
}

export {uiParams};


//camera: slightly raised, close enough that the waterline crossing the wall
//fills the frame (identity-ish facing, looking down -z).
let position = [0, 3.0, 9];

let facing = [1, 0, 0, 0, 0.99, 0.14, 0, -0.14, 0.99];

let location = {
    position: position,
    facing: facing
};

export {location};


//THE KNOB: drag liquidIOR up to glassIOR and the submerged wall disappears.
//Past it, the interface returns inverted.
export const params = [
    { name: 'liquidIOR',   label: 'Liquid IOR',  min: 1,   max: 2,   step: 0.005, value: 1.33 },
    { name: 'glassIOR',    label: 'Glass IOR',   min: 1,   max: 2,   step: 0.005, value: 1.5 },
    { name: 'fill',        label: 'Fill',        min: 0,   max: 1,   step: 0.01,  value: 0.6 },
    { name: 'liquidTint',  type: 'color', label: 'Liquid Tint', value: [0.85, 0.45, 0.12] },
    { name: 'liquidDepth', label: 'Tint Depth',  min: 0.1, max: 8,   step: 0.05,  value: 2.5 },
    { name: 'lightPower',  label: 'Light Power', min: 0,   max: 400, step: 1,     value: 140 },
    { name: 'roomLight',   label: 'Room Light',  min: 0,   max: 2,   step: 0.01,  value: 0.45 },
];

export default {uiParams: uiParams, location: location, params: params};
