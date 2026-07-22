let uiParams = {
    aperture: 0,
    focalLength: 9,
    exposure: 1,
    fov: 45,
    maxBounces: 6,
}

export {uiParams};


// camera on the +z axis, looking down -z straight at the hole at the origin
let position = [0, 0, 9];

let facing = [1,0,0, 0,1,0, 0,0,1];

let location = {
    position: position,
    facing: facing
};

export {location};


// a busy equirectangular image so the gravitational lensing is legible: escaped
// rays sample it in their bent direction, warping it into an Einstein ring.
let sky = {type: 'image', src: '/assets/office.jpg'};

export {sky};


export const params = [
    { name: 'mass', label: 'Mass', min: 0, max: 0.5, step: 0.005, value: 0.25 },
];

export default {uiParams: uiParams, location: location, sky: sky, params: params};
