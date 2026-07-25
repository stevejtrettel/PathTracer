let uiParams = {
    aperture: 0,
    focalLength: 10,
    exposure: 1,
    focusHelp: false,
    fov: 52,
    scratch1: 0.5,
    scratch2: 0.5,
    scratch3: 0.5,
    scratch4: 0.5,
}

export {uiParams};

let position = [-6.192855190156275, 8.57560717454186, 15.972681151852354];

let facing = [0.9074702885423024, 0.09787742905302119, -0.40855560734707985, -0.007819733212547742, 0.9762489795898874, 0.2165104653869645, 0.42004348249348883, -0.1932820186452025, 0.8866823185803517];

let location = { position: position, facing: facing };

export {location};

export const params = [
    { name: 'sssScatter', label: 'Scatter',    min: 0, max: 1, step: 0.01, value: 0.368 },
    { name: 'roomLight',  label: 'Room Light', min: 0, max: 2, step: 0.01, value: 0.1 },
];

export default {uiParams: uiParams, location: location, params: params};
