let uiParams = {
    aperture: 0,
    focalLength: 9,
    exposure: 1,
    fov: 50,
    maxBounces: 6,
}

export {uiParams};


// camera on the +z axis, looking down -z at the triangle of holes (in the z=0 plane)
let position = [0, 0, 9];

let facing = [1,0,0, 0,1,0, 0,0,1];

let location = {
    position: position,
    facing: facing
};

export {location};


// busy equirectangular image so the lensing around each shadow is legible.
let sky = {type: 'image', src: '/assets/office.jpg'};

export {sky};


export const params = [
    { name: 'mass', label: 'Mass', min: 0, max: 0.5, step: 0.005, value: 0.25 },
];

export default {uiParams: uiParams, location: location, sky: sky, params: params};
