// The MICROFACET half of the roughness A/B pair: loads the SAME glsl as
// demos/roughSweep (geometry can never drift between the two pages) — only the
// settings differ, injecting #define MICROFACET_ROUGHNESS into the engine.
import createScene from "../../js/createScene.js";

import environment from "../roughSweep/src/environment.glsl";
import objects from "../roughSweep/src/objects.glsl";
import settings from "./src/settings.js";

createScene({environment, objects, settings});
