import Stats from "three/addons/libs/stats.module";

import PathTracer from "./js/PathTracer.js";
import UI from "./js/UI.js";
import shaders from "./js/shaders.js";



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


//build the path tracer
let pathtracer = new PathTracer(shaders);
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

