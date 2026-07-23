// Sphere: the analytic primitive, in glass, in an empty ceiling-lit studio.
import createScene from "../../../js/createScene.js";

import environment from "../../_studio/empty.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
