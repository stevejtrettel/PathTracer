let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1,
    focusHelp: false,
    fov: 40,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};


let position = [2, 2, 3];

let facing = [1,0,0, 0,1,0, 0,0,1];

let location = {
    position: position,
    facing: facing
};

export {location};


//this scene exists to exercise the image-sky path: no RoomBox, the
//equirectangular image lights the scene and shows in the reflections
let sky = {type: 'image', src: '/assets/office.jpg'};

export {sky};

export default {uiParams: uiParams, location: location, sky: sky};
