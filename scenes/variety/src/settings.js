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


//camera shared with the other room scenes. Fly it and Save to Scene.
let position = [-3.0126253110828656, 2.818905621714715, 5.780456240995506];

let facing = [
    0.9568508895670248,   0.07337507324132644, -0.2811627175879555,
   -0.020936275243809675, 0.9824872892838259,   0.18514966587744666,
    0.28982416654504506, -0.17127412245416165,  0.9416300374690048,
];

let location = { position: position, facing: facing };

export {location};


export const params = [
    //the equation's internal zoom: how many gyroid cells fit inside the clip ball
    { name: 'varScale',       label: 'Variety Scale', min: 0.3, max: 5, step: 0.01, value: 1.1 },
    //thickness of the SOLID's shell. Keep it well above 2*AT_THRESH (0.006).
    { name: 'shellThickness', label: 'Shell Thickness', min: 0.005, max: 0.2, step: 0.001, value: 0.035 },

    //--- the sheet's two faces ---
    { name: 'frontColor', type: 'color', label: 'Sheet Front', value: [0.85, 0.28, 0.22] },
    { name: 'backColor',  type: 'color', label: 'Sheet Back',  value: [0.90, 0.82, 0.30] },
    { name: 'sheetGloss', label: 'Sheet Sheen', min: 0, max: 1, step: 0.01, value: 0.3 },

    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.6 },

    //--- the room: six walls, one region, all live ---
    { name: 'floorColor', type: 'color', label: 'Floor',      value: [0.28, 0.28, 0.29] },
    { name: 'warmColor',  type: 'color', label: 'Left Wall',  value: [0.30, 0.20, 0.17] },
    { name: 'coolColor',  type: 'color', label: 'Right Wall', value: [0.17, 0.21, 0.30] },
    { name: 'wallColor',  type: 'color', label: 'Walls',      value: [0.22, 0.22, 0.23] },
    { name: 'wallRough',  label: 'Wall Roughness', min: 0, max: 1, step: 0.01, value: 0.2 },
];

export default {uiParams: uiParams, location: location, params: params};
