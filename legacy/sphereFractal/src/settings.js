let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 69,
}

export {uiParams};


let position = [-7.201976259965927,0.9895780966324851,0.7222901982590041];

let facing = [0.5264804207150101,0.1340913701289542,-0.8395462292574694,-0.05662908757108964,0.990821805723144,0.12274076643171414,0.8482991884025193,-0.017077873413257817,0.5292417530723282];

let location = {
    position: position,
    facing: facing
};

export {location};

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'emission', label: 'Emission', min: 0, max: 1, step: 0.01, value: 0.368 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location:location, params: params};
