let uiParams = {
    aperture: 0.053,
    focalLength: 1.6,
    fov: 41,
    exposure: 1,
    maxBounces: 12,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
    uDebugMode: 0,
    dbgHeatScale: 128,
    dbgFocusBand: 0.4,
}

export {uiParams};


let position = [0.5350486895790809,-0.1543830697572576,-6.582869175333679];

let facing = [-0.31091324722381924,0.2169887915113987,-0.9253450394632206,0.7573337390085378,0.6448205826815526,-0.10327503187890734,0.5742613718455742,-0.7329021499977287,-0.3648268629566131]; 

let location = {
position: position,
facing: facing
};

export {location};

export const params = [
    { name: 'detail', type: 'int', label: 'Detail (iterations)', min: 20, max: 80, step: 1, value: 70 },
    { name: 'lightBrightness', label: 'Light Brightness', min: 0, max: 40, step: 0.25, value: 6 },
    { name: 'wallColor', type: 'color', label: 'Wall Color', value: [0.55, 0.42, 0.30] },
];

//warm medium-dim ambient: reads the fractal everywhere in muted warm tones; the
//local light in environment.glsl adds the brighter warm key/highlights on top
let sky = { type: 'solid', color: [0.45, 0.42, 0.38] };

export {sky};

export default {uiParams: uiParams, location:location, params:params, sky:sky};