let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 45,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


//this scene has scattering interiors, so the medium walk is compiled in.
//Scenes without them omit this and the whole walk vanishes from the shader.
export const defines = ['SCENE_SUBSURFACE'];


//camera shared with scenes/cocktail and scenes/glassball. Fly it and Save to
//Scene — the three balls sit in a row along x.
let position = [-3.0126253110828656, 2.818905621714715, 5.780456240995506];

let facing = [
    0.9568508895670248,   0.07337507324132644, -0.2811627175879555,
   -0.020936275243809675, 0.9824872892838259,   0.18514966587744666,
    0.28982416654504506, -0.17127412245416165,  0.9416300374690048,
];

let location = { position: position, facing: facing };

export {location};


export const params = [
    { name: 'roomLight',   label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },

    //--- the wax ball ---
    { name: 'waxTint',     type: 'color', label: 'Wax Tint', value: [0.95, 0.55, 0.28] },
    { name: 'waxDepth',    label: 'Wax Tint Depth', min: 0.05, max: 3, step: 0.01, value: 0.6 },
    { name: 'waxDensity',  label: 'Wax mfp',        min: 0.01, max: 1.5, step: 0.01, value: 0.18 },
    { name: 'waxBlur',     label: 'Wax Phase',      min: 0, max: 1, step: 0.01, value: 0.8 },

    //--- the core, inside the glass shell ---
    { name: 'coreTint',    type: 'color', label: 'Core Tint', value: [0.22, 0.68, 0.52] },
    { name: 'coreDepth',   label: 'Core Tint Depth', min: 0.05, max: 3, step: 0.01, value: 0.4 },
    { name: 'coreDensity', label: 'Core mfp',        min: 0.01, max: 1.5, step: 0.01, value: 0.12 },

    //--- the room: six walls, one region, all live ---
    { name: 'floorColor', type: 'color', label: 'Floor',      value: [0.1006, 0.1194, 0.1412] },
    { name: 'warmColor',  type: 'color', label: 'Left Wall',  value: [0.1006, 0.1194, 0.1412] },
    { name: 'coolColor',  type: 'color', label: 'Right Wall', value: [0.1006, 0.1194, 0.1412] },
    { name: 'wallColor',  type: 'color', label: 'Walls',      value: [0.1006, 0.1194, 0.1412] },
    { name: 'wallRough',  label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.1 },
];

export default {uiParams: uiParams, location: location, params: params, defines: defines};
