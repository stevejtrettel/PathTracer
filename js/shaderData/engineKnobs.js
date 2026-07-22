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
    { name: 'aperture',    label: 'Aperture',     min: 0,  max: 0.3, step: 0.0005, value: 0,    group: 'camera' },
    { name: 'focalLength', label: 'Focal Length', min: 0,  max: 40,  step: 0.01,  value: 14.92, group: 'camera' },
    { name: 'fov',         label: 'FOV',          min: 15, max: 140, step: 1,     value: 29,    group: 'camera' },
    { name: 'exposure',    label: 'Exposure',     min: 0,  max: 2,   step: 0.01,  value: 1,     group: 'camera' },
];

// Render-quality controls -> Render folder/tab
const renderKnobs = [
    { name: 'maxBounces', label: 'Max Bounces', type: 'int', min: 1, max: 100, step: 1, value: 50, group: 'render' },
    // spectral rendering: the master switch. ON gives each ray a random wavelength
    // (tinted throughput, integrated by the accumulator); OFF pins the mid-wavelength
    // with a white tint, byte-identical to the non-spectral tracer. `dispersion` is
    // the STRENGTH of the wavelength->IOR shift (prism rainbows) and does nothing
    // until spectral is on. See glsl/tracer/1Setup/spectral.glsl.
    { name: 'spectral',   label: 'Spectral',   type: 'bool', value: false, group: 'render' },
    { name: 'dispersion', label: 'Dispersion', min: 0, max: 0.3, step: 0.005, value: 0, group: 'render' },
];

// (The sphere marcher — over-relaxed enhanced sphere tracing with adaptive cone
// epsilon — has no knobs: its ω and cone-epsilon are tuned constants baked into
// glsl/tracer/6Trace/raymarch.glsl. See docs/marching.md.)

// Always-present live-tweak scratchpad dials -> Parameters/Scene folder
const scratchKnobs = [
    { name: 'scratch1', label: 'scratch1', min: 0, max: 1, step: 0.001, value: 0, group: 'scratch' },
    { name: 'scratch2', label: 'scratch2', min: 0, max: 1, step: 0.001, value: 0, group: 'scratch' },
    { name: 'scratch3', label: 'scratch3', min: 0, max: 1, step: 0.001, value: 0, group: 'scratch' },
    { name: 'scratch4', label: 'scratch4', min: 0, max: 1, step: 0.001, value: 0, group: 'scratch' },
];

// Debug lenses -> Debug folder/tab. uDebugMode forks the tracer to a cheap one-shot
// debug pass (see glsl/tracer/6Trace/debugPass.glsl and docs/debug-suite.md):
//   0 off | 1 normals | 2 cost heatmap | 3 DE quality | 4 depth
//   5 overstep | 6 albedo | 7 lit preview | 8 focus peaking | 9 bound shells
const debugKnobs = [
    { name: 'uDebugMode',   label: 'Mode',       type: 'int', min: 0,    max: 9,   step: 1,    value: 0,   group: 'debug' },
    { name: 'dbgHeatScale', label: 'Heat Scale',              min: 8,    max: 512, step: 1,    value: 128, group: 'debug' },
    { name: 'dbgFocusBand', label: 'Focus Band',              min: 0.002, max: 2, step: 0.002, value: 0.1, group: 'debug' },
];

// everything the engine declares, in shader-declaration order
const engineKnobs = [...cameraKnobs, ...renderKnobs, ...scratchKnobs, ...debugKnobs];

export {cameraKnobs, renderKnobs, scratchKnobs, debugKnobs, engineKnobs};
