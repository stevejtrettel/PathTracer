let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 62,
}

export {uiParams};


let position = [-7.699953853786372,4.463880172165793,-0.8381119200607524];

let facing = [0.6117428657753403,0.21468632042506297,-0.7613674868255912,-0.008618388906180496,0.9642205979314041,0.2649610573222665,0.7910097278450163,-0.15552627542321198,0.5917053220204819];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location:location, params: params};