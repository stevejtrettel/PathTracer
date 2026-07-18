let uiParams = {
    aperture: 0.007,
    focalLength: 0.6,
    focusHelp: false,
    fov: 85,
    exposure: 1.1,
    maxBounces: 50,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


let position = [1.9789326709336024,1.0575015666681562,-5.512278642165219];

let facing = [0.8586302127764323,-0.016223323717036026,-0.512082374323055,0.0923206652486789,0.9880630778771138,0.12337310630486684,0.5039949569168105,-0.15320329092924415,0.8500070544274051]; 

let location = {
position: position,
facing: facing
};

export {location};

export const params = [
    { name: 'detail', type: 'int', label: 'Detail (fold iterations)', min: 8, max: 60, step: 1, value: 60 },
    { name: 'lightIntensity', label: 'Ceiling Light', min: 0, max: 2, step: 0.01, value: 0.18 },
];

export default {uiParams: uiParams, location:location, params:params};