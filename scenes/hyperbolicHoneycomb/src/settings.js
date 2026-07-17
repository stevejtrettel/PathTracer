let uiParams = {
    aperture: 0,
    focalLength: 10,
    focusHelp: false,
    fov: 65,
    exposure: 1.4,
    maxBounces: 50,
    scratch1: 0.7,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


let position = [2.5181224669675593,-0.7953664662092742,-5.5104049697421145];

let facing = [-0.6712401965939518,-0.2787671810724618,0.6872026789312896,0.741471415025816,-0.23695087184908192,0.6281333225801269,-0.012235161467065912,0.930652138603287,0.3656185678191266]; 

let location = {
position: position,
facing: facing
};

export {location};

export default {uiParams: uiParams, location:location};