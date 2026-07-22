// The EXIT-FRESNEL half of the SSS A/B pair: loads the SAME glsl as
// demos/sssExit — only the settings differ, injecting #define SSS_EXIT_FRESNEL.
import createScene from "../../js/createScene.js";

import environment from "../roughSweep/src/environment.glsl";
import objects from "../sssExit/src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
