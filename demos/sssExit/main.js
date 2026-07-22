// SSS exit-Fresnel A/B, legacy half: shares the neutral reference room.
import createScene from "../../js/createScene.js";

import environment from "../roughSweep/src/environment.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
