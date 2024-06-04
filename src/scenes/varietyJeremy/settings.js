let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 29,
    extra: 0.926,
    extra2: 0.619,
    extra3: 0.368,
    extra4: 0.041,
}

export {uiParams};


let position = [0.03144491485600982,3.58668770471448,-0.5591129970849034];

let facing = [0.9442378373824072,0.32920763421763727,0.00610246081805651,-0.3228597333227389,0.9220749531584231,0.21339956269062746,0.06462583890350021,-0.2034701804456914,0.9769459486661779];

let location = {
    position: position,
    facing: facing
};

export {location};

export default {uiParams: uiParams, location:location};