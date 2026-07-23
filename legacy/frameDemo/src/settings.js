let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 29,
}

export {uiParams};


let position = [-14.421901291795352,7.540983416604139,18.73458147092391];

let facing = [0.8100377389035106,0.15664458153457878,-0.5650675504997376,-0.02716274776054038,0.9726473942724095,0.23069293779628824,0.5857482792855832,-0.17152119837163077,0.7921359932631443];

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
