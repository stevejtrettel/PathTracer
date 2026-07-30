let uiParams = {
    aperture: 0,
    focalLength: 14.92,
    exposure: 1,
    focusHelp: false,
    fov: 29,
    spectral: false,
    dispersion: 0.2,
    maxBounces: 8,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

//the legacy pose, carried over verbatim
let position = [-8.370211937396613, 5.615017202998624, 10.662068264791179];

let facing = [0.8020503240461482, 0.1714388601700379, -0.5721223600951921, -0.043670728505207645, 0.9721869879379719, 0.23009851793483949, 0.5956577416345129, -0.15956559061270803, 0.7872297486268782];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'spin',      label: 'S³ Spin',       min: -180, max: 180,  step: 1,     value: -90 },
    { name: 'vertexRad', label: 'Vertex Radius', min: 0.02, max: 0.35, step: 0.005, value: 0.15 },
    { name: 'edgeRad',   label: 'Edge Radius',   min: 0.01, max: 0.2,  step: 0.005, value: 0.05 },
    { name: 'roomLight', label: 'Room Light',    min: 0,    max: 2,    step: 0.01,  value: 0.5 },
];

export default {uiParams: uiParams, location: location, params: params};
