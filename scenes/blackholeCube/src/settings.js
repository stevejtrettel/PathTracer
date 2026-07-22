let uiParams = {
    aperture: 0,
    focalLength: 7,
    exposure: 1,
    fov: 45,
    maxBounces: 16,   // enough for several internal (TIR) bounces inside the cube
}

export {uiParams};


// camera on the +z axis, looking down -z at the cube (centered at the origin)
let position = [0, 0, 7];

let facing = [1,0,0, 0,1,0, 0,0,1];

let location = {
    position: position,
    facing: facing
};

export {location};


// a busy equirectangular image so the refraction + gravitational lensing is
// legible: the cube warps it, and at mass = 0 the cube is invisible against it.
let sky = {type: 'image', src: '/assets/office.jpg'};

export {sky};


export const params = [
    { name: 'mass', label: 'Mass', min: 0, max: 0.5, step: 0.005, value: 0.25 },
];

export default {uiParams: uiParams, location: location, sky: sky, params: params};
