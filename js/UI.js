import Panel from "./gui/Panel.js";
import {el, control, toggle, button, numberField, select, section} from "./gui/widgets.js";
import {serializeKnobs, serializeUiParams, withValues} from "./shaderData/knobs.js";
import {cameraKnobs, renderKnobs, scratchKnobs, engineKnobs} from "./shaderData/engineKnobs.js";


// camera keybindings, for the static Help map (mirrors js/KeyControls.js)
const KEYBINDINGS = [
    ['↑ / ↓',      'move forward / back'],
    ['← / →',      'move left / right'],
    ["' / /",      'move up / down'],
    ['W / S',      'pitch up / down'],
    ['A / D',      'yaw left / right'],
    ['Q / E',      'roll'],
];


// on-screen aspect-ratio presets: [label, width/height]. null = fill window.
const ASPECTS = [
    ['Fill',        null],
    ['1:1',         1],
    ['3:2',         3/2],
    ['2:3',         2/3],
    ['16:9',        16/9],
    ['9:16',        9/16],
    ['√2',          Math.SQRT2],
    ['portrait √2', 1/Math.SQRT2],
];

// largest {x,y} box of the given width/height ratio that fits the window
// (mirrors resolutionFor() in createScene.js; duplicated to avoid a circular
// import, since createScene imports UI).
function fitAspect(aspect){
    let w = window.innerWidth, h = window.innerHeight;
    if(aspect){
        if(w / h > aspect) w = Math.round(h * aspect);
        else               h = Math.round(w / aspect);
    }
    return {x: w, y: h};
}


class UI{
    constructor(pathtracer, stats){

        //engine-owned knobs, with per-scene values pulled from settings.uiParams
        const uiParams    = pathtracer.settings.uiParams;
        const camKnobs    = withValues(cameraKnobs,  uiParams);
        const renKnobs    = withValues(renderKnobs,  uiParams);
        const scrKnobs    = withValues(scratchKnobs, uiParams);
        const sceneParams = pathtracer.settings.params ?? [];

        //current knob values, seeded per-scene, kept live by wire() below so the
        //Download-Settings serialization sees exactly what the sliders show.
        this.values = {};
        for(let k of [...camKnobs, ...renKnobs, ...scrKnobs, ...sceneParams]){
            this.values[k.name] = k.value;
        }

        //the one place that knows a knob drives a uniform. Injected into every
        //widget as its onChange; also records the value for serialization.
        const wire = (knob) => (value) => {
            this.values[knob.name] = value;
            pathtracer.tracer.updateUniforms({ [knob.name]: value });
            pathtracer.reset();
        };

        const panel = new Panel();

        //--- Scene: named params + scratch dials ---
        const scene = panel.tab('Scene');
        for(let k of [...sceneParams, ...scrKnobs]) scene.append(control(k, wire(k)));

        //--- Camera: lens knobs + live pose readout + reset ---
        const cam = panel.tab('Camera');
        for(let k of camKnobs) cam.append(control(k, wire(k)));

        cam.append(section('Pose'));
        const pose = el('div', 'gui-pose');
        cam.append(pose);
        const refreshPose = () => {
            let p = pathtracer.controls.position;
            pose.textContent = `x ${p.x.toFixed(2)}   y ${p.y.toFixed(2)}   z ${p.z.toFixed(2)}`;
            requestAnimationFrame(refreshPose);
        };
        refreshPose();

        const home = pathtracer.settings.location;
        cam.append(button('Reset Camera', () => {
            pathtracer.controls.position.set(home.position[0], home.position[1], home.position[2]);
            pathtracer.controls.facing.set(
                home.facing[0], home.facing[1], home.facing[2],
                home.facing[3], home.facing[4], home.facing[5],
                home.facing[6], home.facing[7], home.facing[8]
            );
            pathtracer.tracer.updateUniforms({
                location: pathtracer.controls.position,
                facing:   pathtracer.controls.facing,
            });
            pathtracer.reset();
        }));
        //aim the camera here, then save the pose (settings.js) without leaving the tab
        cam.append(button('Download Settings', () => this.downloadSettings(pathtracer, sceneParams)));

        //--- Render: quality + live image ---
        const ren = panel.tab('Render');
        for(let k of renKnobs) ren.append(control(k, wire(k)));   // maxBounces

        //render scale: the tracer/accumulate resolution as a fraction of the
        //window. Full = native (resizes everything); Half/Quarter render smaller
        //and let the display stretch them up (pixelated but fast) — Quarter is
        //the old "preview".
        ren.append(select('Scale', [['Full', 1], ['Half', 0.5], ['Quarter', 0.25]], 1, (scale) => {
            let w = window.innerWidth, h = window.innerHeight;
            if(scale === 1){
                pathtracer.resize({x: w, y: h});
            } else {
                let r = {x: Math.floor(scale * w), y: Math.floor(scale * h)};
                pathtracer.tracer.setSize(r);
                pathtracer.accumulate.setSize(r);
            }
            pathtracer.reset();
        }));

        //live aspect ratio: re-fit the canvas to a preset ratio. Preselects the
        //scene's settings.aspect (so cubic-portrait/landscape land on √2).
        ren.append(select('Aspect', ASPECTS, pathtracer.settings.aspect ?? null,
            (aspect) => pathtracer.resize(fitAspect(aspect))));

        //samples accumulated (live) + restart accumulation
        ren.append(section('Samples'));
        const spp = el('div', 'gui-pose');
        ren.append(spp);
        const refreshSpp = () => {
            spp.textContent = `${Math.floor(pathtracer.tracer.material.uniforms.frameNumber.value)} spp`;
            requestAnimationFrame(refreshSpp);
        };
        refreshSpp();
        ren.append(button('Reset', () => pathtracer.reset()));

        //--- Export: produce files ---
        const exp = panel.tab('Export');

        exp.append(button('Save Image',        () => pathtracer.saveImage()));
        exp.append(button('Download Settings', () => this.downloadSettings(pathtracer, sceneParams)));

        //one unified autosave for the live view
        exp.append(section('Auto Save'));
        exp.append(toggle({label: 'Auto Save', value: false},
            (on) => { pathtracer.autoSave = on; }));
        exp.append(numberField('Every (spp)', pathtracer.autoSaveSPP,
            (v) => { pathtracer.autoSaveSPP = v; }));

        //HD render: final size + samples -> auto-tiled square grid, each tile
        //saved as it finishes. The tiling is worked out for you (planHD); Advanced
        //lets you cap tile size or re-render a single tile after a crash.
        exp.append(section('HD Render'));
        let hd = { w: window.innerWidth * 2, h: window.innerHeight * 2, spp: 1000, maxTile: 4000, tile: 0 };
        exp.append(numberField('Width',   hd.w,   (v) => hd.w = v));
        exp.append(numberField('Height',  hd.h,   (v) => hd.h = v));
        exp.append(numberField('Samples', hd.spp, (v) => hd.spp = v));
        exp.append(button('Start HD Render',
            () => pathtracer.startHDRender(hd.w, hd.h, hd.spp, {maxTile: hd.maxTile})));

        //live progress / plan readout
        const hdInfo = el('div', 'gui-pose');
        exp.append(hdInfo);
        const refreshHd = () => {
            if(pathtracer.hd && pathtracer.hd.active){
                let pr = pathtracer.tracer.material.uniforms.panelToRender.value;
                let fn = Math.floor(pathtracer.tracer.material.uniforms.frameNumber.value);
                hdInfo.textContent = `tile ${pr + 1}/${pathtracer.hd.N} · ${fn}/${pathtracer.hd.spp} spp`;
            } else {
                let p = pathtracer.planHD(hd.w, hd.h, hd.maxTile);
                hdInfo.textContent = `${p.root}×${p.root} grid · ${p.tileW}×${p.tileH} tiles`;
            }
            requestAnimationFrame(refreshHd);
        };
        refreshHd();

        exp.append(section('Advanced'));
        exp.append(numberField('Max Tile', hd.maxTile, (v) => hd.maxTile = v));
        exp.append(numberField('Tile #',        hd.tile,    (v) => hd.tile = v));
        exp.append(button('Re-render Tile',
            () => pathtracer.startHDRender(hd.w, hd.h, hd.spp, {maxTile: hd.maxTile, tile: hd.tile})));

        //--- Help: static keybinding map + fps stats ---
        const help = panel.tab('Help');
        help.append(section('Camera Keys'));
        let keys = el('div', 'gui-keys');
        for(let [k, d] of KEYBINDINGS){
            keys.append(el('span', 'key', k), el('span', 'desc', d));
        }
        help.append(keys);

        //host the fps meter here (createScene hands us stats instead of
        //appending it to <body>). Strip its fixed positioning to sit in-flow.
        if(stats){
            stats.dom.style.position = 'static';
            help.append(section('Performance'));
            help.append(stats.dom);
        }
    }

    //regenerate settings.js (engine knob values + scene params + camera pose)
    //and trigger a browser download. Same format/output as before.
    downloadSettings(pathtracer, sceneParams){
        let contents = '';
        contents += serializeUiParams(engineKnobs, this.values);
        contents += `\n\n\n`;
        contents += pathtracer.printLocation();
        contents += `\n\n`;
        if(sceneParams.length){
            contents += serializeKnobs(sceneParams, this.values);
            contents += `\n\n`;
            contents += `export default {uiParams: uiParams, location:location, params:params};`;
        } else {
            contents += `export default {uiParams: uiParams, location:location};`;
        }

        let file = new File([contents], 'settingsNew.js', {type: 'javascript'});
        let link = document.createElement('a');
        let url  = URL.createObjectURL(file);
        link.href = url;
        link.download = file.name;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    }
}


export default UI;
