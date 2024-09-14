import Stats from "three/addons/libs/stats.module";

//the main components
import PathTracer from "../../js/PathTracer.js";
import UI from "../../js/UI.js";

//the shaders
import accShaderData from "../../js/accShaderData.js";
import displayShaderData from "../../js/displayShaderData.js";
import buildTraceShader from "../../js/buildTraceShader.js";

//the pieces specific to this scene
import environment from "./src/environment.glsl";
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
        environment: environment,
        objects: objects,
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

