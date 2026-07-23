// Fog / god-ray reference: shares the neutral reference room (dial roomLight
// down and lightPower up — the fog knobs live in objects.glsl's ambient hook).
import createScene from "../../../js/createScene.js";

import environment from "../../_studio/neutral.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
