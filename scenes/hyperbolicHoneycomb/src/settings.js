let uiParams = {
    aperture: 0,
    focalLength: 10,
    focusHelp: false,
    fov: 65,
    exposure: 1.4,
    maxBounces: 50,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
    uDebugMode: 0,
    dbgHeatScale: 128,
}

export {uiParams};


let position = [4.720546795680603,-1.399574809135772,-5.23721856348474];

let facing = [0.45788706918621713,-0.24529196938024386,0.8548060284804831,0.8817714267485511,0.0005055741806194707,-0.47218210604658173,0.11540213738330656,0.9694285492437981,0.216403960212297]; 

let location = {
position: position,
facing: facing
};

export {location};

export const params = [
    { name: 'foldDepth', type: 'int', label: 'Fold Depth', min: 10, max: 200, step: 1, value: 146 },
];

export default {uiParams: uiParams, location:location, params:params};