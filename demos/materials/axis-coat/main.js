// Coat-sweep reference: shares the neutral reference room with demos/roughSweep.
import createScene from "../../../js/createScene.js";

import environment from "../../_studio/neutral.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
