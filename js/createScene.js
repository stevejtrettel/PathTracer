import "../style.css";

import FpsMeter from "./FpsMeter.js";

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

    //stats readout (fps); the UI hosts stats.dom inside its Help tab
    let stats = new FpsMeter();

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
    let res = resolutionFor(settings.aspect);

    //build and run the path tracer
    let pathtracer = new PathTracer(shaders, settings, res);
    let ui = new UI(pathtracer, stats);

    function animate(){
        requestAnimationFrame(animate);
        stats.begin();
        pathtracer.newFrame();
        stats.end();
    }
    animate();

    return pathtracer;
}


//largest {x,y} box of the given width/height ratio that fits in the window
function resolutionFor(aspect){
    let w = window.innerWidth;
    let h = window.innerHeight;
    if(aspect){
        if(w / h > aspect){ w = Math.round(h * aspect); }
        else             { h = Math.round(w / aspect); }
    }
    return {x: w, y: h};
}


export default createScene;
