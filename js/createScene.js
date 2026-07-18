import "../style.css";

import FpsMeter from "./FpsMeter.js";
import {fitAspect} from "./gui/widgets.js";

import PathTracer from "./PathTracer.js";
import UI from "./UI.js";

import accShaderData from "./shaderData/accShaderData.js";
import displayShaderData from "./shaderData/displayShaderData.js";
import buildTraceShader from "./shaderData/buildTraceShader.js";


//-------------------------------------------------
// createScene
//-------------------------------------------------
// The shared entry point for every scene. A scene folder is just its three
// src/ files; its main.js is a five-line stub that imports them and calls this.
//
//     createScene({ environment, objects, settings })
//
// (environment/objects are the scene's GLSL strings; settings is its default
// export: { uiParams, location, params?, aspect? }.)

function createScene({environment, objects, settings}){

    //stats readout (fps): a minimal always-on overlay pinned to the upper-right
    //corner (see .fps-meter in gui.css). Updated once per frame by stats.end().
    let stats = new FpsMeter();
    document.body.append(stats.dom);

    //build the tracer shader for this scene
    let sceneData = {
        environment: environment,
        objects: objects,
    };
    let shaders = {
        tracer: buildTraceShader(sceneData, settings),
        accumulate: accShaderData,
        display: displayShaderData,
    };

    //initial resolution: settings.aspect (width/height) fits the largest box
    //of that ratio inside the window; omitted -> fill the window. Aspect is
    //also editable live in the Render panel.
    let res = fitAspect(settings.aspect);

    //build and run the path tracer
    let pathtracer = new PathTracer(shaders, settings, res);
    let ui = new UI(pathtracer);

    function animate(){
        requestAnimationFrame(animate);
        pathtracer.newFrame();
        stats.end();
    }
    animate();

    return pathtracer;
}


export default createScene;
