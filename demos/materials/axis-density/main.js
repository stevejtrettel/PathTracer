// The density continuum: interior mfp from dense (diffuse) to ballistic (glass).
import createScene from "../../../js/createScene.js";

import environment from "../../_studio/neutral.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
