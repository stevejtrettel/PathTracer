// Field chart · weathering: one `coverage` knob drives six layers-on-a-base.
import createScene from "../../../js/createScene.js";

import environment from "../../_studio/accent.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
