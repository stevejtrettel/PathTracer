//this file gets the settings from our chosen scene, and imports them.
//then it exports them to wherever they are needed in the code

import settings from "../scenes/sceneSettings.js";

let location = settings.location;
let uiParams = settings.uiParams;

export {location};
export {uiParams};