let uiParams = {
aperture: 0,
focalLength: 14.92,
exposure: 1,
focusHelp: false,
fov: 66,
}

export {uiParams};


let position = [-6.839295941039322,6.6489496750477475,-19.44906687301756];

let facing = [-0.8521978897370898,0.057869586616138585,-0.5200094880600835,-0.11015654452168229,0.9517441330065896,0.28644133952095185,0.5114922212768007,0.30138715339640926,-0.8046996280233488]; 

let location = {
position: position,
facing: facing
};

export {location};


//A-series landscape (√2 : 1): width/height ratio for the initial render size
export const aspect = Math.SQRT2;

//named GUI knobs (converted from scratch)
export const params = [
    { name: 'rotation', label: 'Rotation', min: 0, max: 1, step: 0.01, value: 0.791 },
];

export default {uiParams: uiParams, location:location, aspect:aspect, params: params};