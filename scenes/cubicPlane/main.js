import createScene from "../../js/createScene.js";
import {emit} from "../../js/scenegen/index.js";

import description from "./src/scene.js";
import settings from "./src/settings.js";

createScene(emit(description, settings));
