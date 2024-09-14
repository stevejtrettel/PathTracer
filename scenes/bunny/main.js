import Stats from "three/addons/libs/stats.module";

//the main components
import PathTracer from "../../src/js/PathTracer.js";
import UI from "../../src/js/UI.js";

//the shaders
import accShaderData from "../../src/js/accShaderData.js";
import displayShaderData from "../../src/js/displayShaderData.js";
import buildTraceShader from "../../src/js/buildTraceShader.js";

//the pieces specific to this scene
import walls from "./src/walls.glsl";
import lights from "./src/lights.glsl";
import objects from "./src/objects.glsl";
import settings from "./src/settings.js";



//---------------------------------
// The scene we are rendering
//---------------------------------
const sceneName = 'test';
//----------------------------------
export {sceneName};
//----------------------------------

//build up stats
let panelType = (typeof type !== 'undefined' && type) && (!isNaN(type)) ? parseInt(type) : 0;
let stats = new Stats();
stats.showPanel(panelType); // 0: fps, 1: ms, 2: mb, 3+: custom
document.body.appendChild(stats.dom);




//build the main shader:
let sceneData = {
        walls: walls,
        objects:objects,
        lights:lights,
    };

let traceShaderData = buildTraceShader( sceneData, settings);

//collect all the shaders:
let shaders = {
    tracer: traceShaderData,
    accumulate: accShaderData,
    display: displayShaderData,
};


//build the path tracer
let pathtracer = new PathTracer(shaders, settings);
let ui = new UI(pathtracer);



//the animation loop
function animate() {
    requestAnimationFrame(animate);
    stats.begin();
    pathtracer.newFrame();
    stats.end();
}

//run the program
animate();

