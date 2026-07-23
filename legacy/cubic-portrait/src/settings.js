let uiParams = {
aperture: 0,
focalLength: 14.92,
exposure: 1,
focusHelp: false,
fov: 66,
}

export {uiParams};


let position = [-0.20290439362489537,1.1288237848324767,-12.101624495176383];

let facing = [-0.9428956974971693,-0.02902941324447221,-0.3318207299250514,-0.0986020868477136,0.9758719740199527,0.1948114955326305,0.3181592873241132,0.21640513739064712,-0.9230078463373621]; 

let location = {
position: position,
facing: facing
};

export {location};


//A-series portrait (1 : √2): width/height ratio for the initial render size
export const aspect = 1 / Math.SQRT2;

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'rotation', label: 'Rotation', min: 0, max: 1, step: 0.01, value: 0.73 },
];

export default {uiParams: uiParams, location:location, aspect:aspect, params: params};