//the white-sky energy test page: /render-tests/energy/?case=<name> renders one
//case from cases.js. `node scripts/render-diff.mjs --energy` drives it and reads
//the average straight out of the accumulation buffer (window.__pt), so the
//check sees true linear values — no tone map, no 8-bit rounding.
import createScene from "../../js/createScene.js";
import {emit} from "../../js/scenegen/index.js";
import cases from "./cases.js";

const name  = new URLSearchParams(location.search).get('case');
const build = cases[name];
if(!build){
    throw new Error(`energy test: no case '${name}' (have: ${Object.keys(cases).join(', ')})`);
}
const {description, settings} = build();
window.__pt = await createScene(emit(description, settings));
