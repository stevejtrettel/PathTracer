import walls from "./walls.glsl";
import lights from "./lights.glsl";
import objects from "./objects.glsl";
import {uiParams,location} from "./settings.js";

const sceneGLSL = walls+lights+objects;

const sceneSettings = {uiParams:uiParams, location:location};

const scene = {glsl: sceneGLSL, settings: sceneSettings};
export default scene;
