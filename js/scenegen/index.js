//-------------------------------------------------
// SCENEGEN — the public surface
//
// A scene is authored as src/scene.js:
//
//     import {scene, object, lib, mat, knob, glsl, ...} from '../../../js/scenegen/index.js';
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
export {glsl, valueText} from './glslTag.js';
export {displace, repLim, carve,
        mirror, radial, round, shell, clip, subtract} from './combinators.js';
export {field} from './fields.js';
export {emit} from './emitter.js';

//the material PRIMITIVES only — every named material is a preset over these
//in js/presets/materials.js (material() is the escape hatch for raw fields)
export {material, withSurface, withMedium, named,
        absorbFor, matKind, matIsMedium, checkArgs, materialInfo} from './materials.js';

//content (room, sphereLight, the field presets) lives in js/presets/ —
//presets import FROM this surface, never the reverse
