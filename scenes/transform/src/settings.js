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


//camera shared with cocktail / glassball / subsurface. Fly it and Save to Scene.
let position = [-3.0126253110828656, 2.818905621714715, 5.780456240995506];

let facing = [
    0.9568508895670248,   0.07337507324132644, -0.2811627175879555,
   -0.020936275243809675, 0.9824872892838259,   0.18514966587744666,
    0.28982416654504506, -0.17127412245416165,  0.9416300374690048,
];

let location = { position: position, facing: facing };

export {location};


export const params = [
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
    //spin the body and watch the highlight: if the chain-rule normal is right it
    //tracks the ellipsoid, not a sphere
    { name: 'spin',      label: 'Body Spin',  min: 0, max: 360, step: 1, value: 35 },
    { name: 'bodyRough', label: 'Body Polish', min: 0, max: 0.5, step: 0.005, value: 0.04 },

    //--- the room: six walls, one region, all live ---
    { name: 'floorColor', type: 'color', label: 'Floor',      value: [0.1006, 0.1194, 0.1412] },
    { name: 'warmColor',  type: 'color', label: 'Left Wall',  value: [0.1006, 0.1194, 0.1412] },
    { name: 'coolColor',  type: 'color', label: 'Right Wall', value: [0.1006, 0.1194, 0.1412] },
    { name: 'wallColor',  type: 'color', label: 'Walls',      value: [0.1006, 0.1194, 0.1412] },
    { name: 'wallRough',  label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.1 },
];

export default {uiParams: uiParams, location: location, params: params};
