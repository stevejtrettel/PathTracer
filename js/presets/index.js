//-------------------------------------------------
// PRESETS — the content library: plain JS over the scenegen schema
//
// One file per domain; add a file when a pattern repeats across ports.
// Never new core machinery — if a preset can't be written over the public
// schema, the schema is missing something (raise that instead).
//-------------------------------------------------

export {room, sphereLight, fog} from './studio.js';
export {fbmHeight, fbm2Height} from './fields.js';
//the named Kleinian boxes: one estimator, its classic parameter bundles
export {kleinianStandardBox, kleinianSeahorse, kleinianSpiralBox} from './fractals.js';

//the six regular 4-polytopes — named bundles over the one polytope4D shape
export {fiveCell, hypercube, sixteenCell, twentyFourCell,
        oneHundredTwentyCell, sixHundredCell} from './polytopes.js';
//materials: the archetypes (the model's canonical menu) and their looks, all
//presets over the scenegen primitives
export {matte, gloss, metal, plastic, glass, subsurface, light, glow, withCoat,
        terracotta, tile, rubber, carPaint, mirror,
        gold, copper, brass, bronze, silver, aluminum, iron, chrome,
        liquid, honey, diamond, neon, soapFilm, oilSlick,
        jade, porcelain, wax, milk, marble} from './materials.js';
