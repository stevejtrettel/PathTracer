import {WebGLRenderer} from "./libs/three.module.js";
import Stats from "./libs/stats.module.js";

import PathTracer from "./PathTracer.js";
import UI from "./UI.js";
import buildShaders from "./buildShaders.js";





function animate() {

    requestAnimationFrame(animate);

    stats.begin();

    tracer.newFrame();

    stats.end();

}







//Actually Running Things
//=============================================


//set the canvas
let canvas = document.querySelector('#World');

//build up stats
let panelType = (typeof type !== 'undefined' && type) && (!isNaN(type)) ? parseInt(type) : 0;
let stats = new Stats();
stats.showPanel(panelType); // 0: fps, 1: ms, 2: mb, 3+: custom
document.body.appendChild(stats.dom);

//build the renderer
let renderer = new WebGLRenderer({
    canvas,
    alpha: true,
    depth: false,
    stencil: false,
});
renderer.setSize(window.innerWidth, window.innerHeight);

//make all the objects
let shaders = await buildShaders();
let tracer = new PathTracer(shaders, renderer);
let ui = new UI(tracer);

animate();


