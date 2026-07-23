let uiParams = {
    aperture: 0,
    focalLength: 14,
    exposure: 1,
    fov: 40,
    maxBounces: 16,
    spectral: true,      //so dispersion and the thin film work when dialled in
}

export {uiParams};


//camera: level three-quarter view of a single sphere on the floor.
let position = [0, 3.4, 10];

let facing = [1, 0, 0, 0, 1, 0, 0, 0, 1];

let location = {
    position: position,
    facing: facing
};

export {location};


//the panel maps 1:1 onto Surface and Medium in 3Materials/material.glsl.
//Defaults open on a tinted clear glass; see the recipes in objects.glsl.
export const params = [

    //---- Surface ----------------------------------------------------------
    { name: 'baseColor',     type: 'color', label: 'Diffuse',        value: [0.85, 0.85, 0.85] },
    { name: 'roughness',     label: 'Roughness',      min: 0, max: 1,   step: 0.01, value: 0 },
    { name: 'gloss',         label: 'Gloss Floor',    min: 0, max: 1,   step: 0.01, value: 0 },
    { name: 'transmit',      label: 'Transmit',       min: 0, max: 1,   step: 0.01, value: 1 },
    { name: 'coat',          label: 'Coat',           min: 0, max: 1,   step: 0.01, value: 0 },
    { name: 'coatRoughness', label: 'Coat Rough',     min: 0, max: 1,   step: 0.01, value: 0 },
    { name: 'film',          label: 'Film (nm)',      min: 0, max: 800, step: 1,    value: 0 },
    { name: 'filmIOR',       label: 'Film IOR',       min: 1, max: 2,   step: 0.01, value: 1.33 },

    //---- Medium -----------------------------------------------------------
    { name: 'IOR',           label: 'IOR',            min: 1,    max: 2.5, step: 0.01, value: 1.5 },
    { name: 'absorbTint',    type: 'color', label: 'Absorb Tint',    value: [0.35, 0.70, 0.75] },
    { name: 'absorbDepth',   label: 'Absorb Depth',   min: 0.05, max: 10,  step: 0.05, value: 2 },
    { name: 'ballistic',     type: 'bool',  label: 'Ballistic (glass)', value: true },
    { name: 'mfp',           label: 'MFP',            min: 0.01, max: 3,   step: 0.01, value: 0.1 },
    { name: 'blur',          label: 'Scatter Blur',   min: 0,    max: 1,   step: 0.01, value: 0.8 },

    //---- lighting ---------------------------------------------------------
    { name: 'lightPower',    label: 'Light Power',    min: 0, max: 400, step: 1,    value: 100 },
    { name: 'roomLight',     label: 'Room Light',     min: 0, max: 2,   step: 0.01, value: 0.3 },
];

export default {uiParams: uiParams, location: location, params: params};
