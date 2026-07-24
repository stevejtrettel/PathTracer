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


//no room: the image sky IS the background, so the pattern behind the two balls
//shows at a glance which one bends light and which one does not.
let sky = {type: 'image', src: '/assets/office.jpg'};

export {sky};


//fly it and Save to Scene
let position = [-3.0126253110828656, 2.818905621714715, 5.780456240995506];

let facing = [
    0.9568508895670248,   0.07337507324132644, -0.2811627175879555,
   -0.020936275243809675, 0.9824872892838259,   0.18514966587744666,
    0.28982416654504506, -0.17127412245416165,  0.9416300374690048,
];

let location = { position: position, facing: facing };

export {location};


export const params = [
    //the two faces of the sheet, so you can see which is which
    { name: 'frontTint',  type: 'color', label: 'Sheet Front', value: [1.0, 0.72, 0.42] },
    { name: 'backTint',   type: 'color', label: 'Sheet Back',  value: [0.42, 0.72, 1.0] },
    { name: 'sheetGloss', label: 'Sheet Sheen', min: 0, max: 0.5, step: 0.005, value: 0.06 },
    //crank this to exaggerate the control ball's distortion
    { name: 'ballIOR',    label: 'Ball IOR', min: 1, max: 2.4, step: 0.01, value: 1.5 },
];

export default {uiParams: uiParams, location: location, sky: sky, params: params};
