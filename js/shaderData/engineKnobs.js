//-------------------------------------------------
// ENGINE KNOBS
//-------------------------------------------------
// Knob lists owned by the engine, identical for every scene. These declare
// name / label / range / group; the initial VALUE for each is overridden per
// scene from settings.uiParams (see withValues() in knobs.js). Together with a
// scene's own settings.params, they feed the one knob generator.
//
// (Scratch knobs are the always-present generic live-tweak dials scratch1..4,
// renamed from the legacy extra/extra2/extra3/extra4.)

// Camera lens controls -> Camera folder/tab
const cameraKnobs = [
    { name: 'aperture',    label: 'Aperture',     min: 0,  max: 2,   step: 0.001, value: 0,     group: 'camera' },
    { name: 'focalLength', label: 'Focal Length', min: 0,  max: 40,  step: 0.01,  value: 14.92, group: 'camera' },
    { name: 'focusHelp',   label: 'Focus Help',   type: 'bool',      value: false,              group: 'camera' },
    { name: 'fov',         label: 'FOV',          min: 15, max: 140, step: 1,     value: 29,    group: 'camera' },
    { name: 'exposure',    label: 'Exposure',     min: 0,  max: 2,   step: 0.01,  value: 1,     group: 'camera' },
];

// Render-quality controls -> Render folder/tab
const renderKnobs = [
    { name: 'maxBounces', label: 'Max Bounces', type: 'int', min: 1, max: 100, step: 1, value: 50, group: 'render' },
];

// Always-present live-tweak scratchpad dials -> Parameters/Scene folder
const scratchKnobs = [
    { name: 'scratch1',  label: 'scratch1',  min: 0, max: 1, step: 0.001, value: 0, group: 'scratch' },
    { name: 'scratch2', label: 'scratch2', min: 0, max: 1, step: 0.001, value: 0, group: 'scratch' },
    { name: 'scratch3', label: 'scratch3', min: 0, max: 1, step: 0.001, value: 0, group: 'scratch' },
    { name: 'scratch4', label: 'scratch4', min: 0, max: 1, step: 0.001, value: 0, group: 'scratch' },
];

// everything the engine declares, in shader-declaration order
const engineKnobs = [...cameraKnobs, ...renderKnobs, ...scratchKnobs];

export {cameraKnobs, renderKnobs, scratchKnobs, engineKnobs};
