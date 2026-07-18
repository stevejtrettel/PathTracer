let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 52,
}

export {uiParams};


let position = [-5.574045964942773,6.124540239963508,9.814738819685829];

let facing = [0.8148093234823944,0.0925498281300304,-0.572293889255406,0.005722806623585538,0.985842598150683,0.16757571767935467,0.5797007985593384,-0.1398173844144668,0.8027440956899095];

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