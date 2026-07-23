// Liquid in glass: the submerged wall vanishes as the indices approach.
import createScene from "../../../js/createScene.js";

import environment from "../../_studio/neutral.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
