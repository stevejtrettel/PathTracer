// The preset chart: one sphere per named material (3Materials/presets.glsl).
import createScene from "../../js/createScene.js";

import environment from "../roughSweep/src/environment.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
