let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 42,
}

export {uiParams};


let position = [-7.227914966664514,3.425884297140259,-1.6402922666599955];

let facing = [0.5033094254767588,0.2018349458086483,-0.840203711534576,-0.022809702559965866,0.9751028501200707,0.22057685544210714,0.8638051514636849,-0.09185361363616258,0.49538225035482514];

let location = {
    position: position,
    facing: facing
};

export {location};


//named GUI knobs: the fold offset that morphs the gasket (was the scratch1
//coupling) plus the room light (converted from scratch)
export const params = [
    { name: 'foldOffset', label: 'Fold Offset', min: 0.0, max: 1.0, step: 0.001, value: 0.877 },
    { name: 'roomLight', label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.5 },
];

export default {uiParams: uiParams, location: location, params: params};