//-------------------------------------------------
// SCENEGEN — the public surface
//
// A scene is authored as src/scene.js:
//
//     import {scene, object, lib, knob, glsl, makeGlass, ...} from '../../../js/scenegen/index.js';
//     export default scene({ objects: [...] });
//
// and its main.js hands the description straight to the engine:
//
//     createScene(emit(description, settings));
//
// Design + conventions: docs/generator.md (§2.7, §5).
//-------------------------------------------------

export {scene, object, group, sheet} from './nodes.js';
export {lib, catalogue, catalogueInfo} from './catalogue.js';
export {knob} from './knobs.js';
export {glsl} from './glslTag.js';
export {displace, repLim} from './combinators.js';
export {field} from './fields.js';
export {emit} from './emitter.js';

export {absorbFor, makeMatte, makeGloss, makeMetal, makePlastic,
        makeGlass, makeSubsurface, makeLight, withCoat} from './materials.js';

export {room, sphereLight, fbmHeight, fbm2Height} from './presets.js';
