let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    fov: 36,
    maxBounces: 24,
}

export {uiParams};


let position = [-16.5, 9.0, 21.0];

let facing = [0.8100377389035106, 0.15664458153457878, -0.5650675504997376, -0.02716274776054038, 0.9726473942724095, 0.23069293779628824, 0.5857482792855832, -0.17152119837163077, 0.7921359932631443];

let location = {
    position: position,
    facing: facing
};

export {location};


export const params = [
    { name: 'lightPower', label: 'Light Power', min: 0, max: 400, step: 1, value: 22 },
];

export default {uiParams: uiParams, location:location, params:params};
