import "../style.css";

import FpsMeter from "./FpsMeter.js";
import {el, fitAspect} from "./gui/widgets.js";
import {watchErrors} from "./gui/ErrorOverlay.js";

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


//errors outside the shader (a scene the generator rejects, a JS bug) go to the
//on-screen overlay too. Installed on import, before main.js calls emit().
watchErrors();

//resolves after the browser has painted the next frame
const nextPaint = () => new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));


async function createScene({scene, environment, objects, settings}){

    //stats readout (fps): a minimal always-on overlay pinned to the upper-right
    //corner (see .fps-meter in gui.css). Updated once per frame by stats.end().
    let stats = new FpsMeter();
    document.body.append(stats.dom);

    //build the tracer shader for this scene. One `scene` chunk is the current
    //form (see scenes/proto): an object is six functions plus the dispatchers,
    //and the old environment/objects split is gone — walls are regions too.
    let sceneData = scene ? {scene: scene} : {environment: environment, objects: objects};
    let shaders = {
        tracer: buildTraceShader(sceneData, settings),
        accumulate: accShaderData,
        display: displayShaderData,
    };

    //initial resolution: settings.aspect (width/height) fits the largest box
    //of that ratio inside the window; omitted -> fill the window. Aspect is
    //also editable live in the Render panel.
    let res = fitAspect(settings.aspect);

    //compiling the tracer can take a few seconds (big scenes, some GPUs) and
    //blocks the page while it runs: put a notice up and let it paint first
    let notice = el('div', 'pt-notice', 'Compiling shader…');
    document.body.append(notice);
    await nextPaint();

    //build and run the path tracer
    let pathtracer = new PathTracer(shaders, settings, res);
    let ui = new UI(pathtracer);
    notice.remove();

    //keep the canvas fitted to the window. Debounced: resize fires continuously
    //while a window edge is dragged, and each re-fit restarts the render.
    let resizeTimer = null;
    window.addEventListener('resize', () => {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(() => pathtracer.fitToWindow(), 150);
    });

    function animate(){
        requestAnimationFrame(animate);
        pathtracer.newFrame();
        stats.end();
    }
    animate();

    return pathtracer;
}


export default createScene;
