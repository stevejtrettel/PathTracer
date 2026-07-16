import Panel from "./gui/Panel.js";
import {el, control, toggle, button, numberField, select, section, collapsible} from "./gui/widgets.js";
import {serializeKnobs, serializeUiParams, withValues, toUniformValue} from "./shaderData/knobs.js";
import {cameraKnobs, renderKnobs, scratchKnobs, engineKnobs} from "./shaderData/engineKnobs.js";


// camera keybindings, for the static Help map (mirrors js/KeyControls.js)
const KEYBINDINGS = [
    ['↑ / ↓',      'move forward / back'],
    ['← / →',      'move left / right'],
    ["' / /",      'move up / down'],
    ['W / S',      'pitch up / down'],
    ['A / D',      'yaw left / right'],
    ['Q / E',      'roll'],
    ['Shift',      'hold to move faster'],
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

        //X saves an image (S is the camera pitch-down key). Skip while typing in
        //a field so 'x' still types normally.
        window.addEventListener('keydown', (e) => {
            if(e.key !== 'x' && e.key !== 'X') return;
            let a = document.activeElement, tag = a && a.tagName;
            if(tag === 'TEXTAREA' || tag === 'SELECT' ||
               (tag === 'INPUT' && (a.type === 'number' || a.type === 'text'))) return;
            pathtracer.saveImage();
        });

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
            this.values[knob.name] = value;   // stored as-is (array for color/vec2) for serialization
            pathtracer.tracer.updateUniforms({ [knob.name]: toUniformValue(knob, value) });
            pathtracer.reset();
        };

        const panel = new Panel();

        //Stop button for an in-progress HD render. Lives on the panel itself
        //(not a tab body), so the render lock — which greys the bodies — leaves
        //it clickable. Hidden unless rendering (CSS keys off the .rendering class).
        const stopBtn = button('Stop Render', () => pathtracer.stopHDRender());
        stopBtn.classList.add('gui-stop');
        panel.panel.append(stopBtn);

        //--- Scene: named params + scratch dials ---
        const scene = panel.tab('Scene');
        for(let k of [...sceneParams, ...scrKnobs]) scene.append(control(k, wire(k)));

        //--- Camera: lens knobs + live pose readout + reset ---
        const cam = panel.tab('Camera');
        for(let k of camKnobs) cam.append(control(k, wire(k)));

        //fly speed: a live multiplier on the keyboard move/turn steps. Drives
        //engine state directly (not a knob/uniform), so it isn't serialized.
        cam.append(section('Fly'));
        cam.append(control({label: 'Speed', type: 'float', min: 0.1, max: 10, step: 0.1, value: pathtracer.controls.speed},
            (v) => { pathtracer.controls.speed = v; }));
        cam.append(toggle({label: 'Mouse Orbit', value: pathtracer.orbitEnabled},
            (on) => { pathtracer.orbitEnabled = on; }));

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
        //copy just the position/facing block to the clipboard — paste it
        //straight over the pose in the scene's settings.js (skips the download)
        const copyBtn = button('Copy Pose', () => {
            navigator.clipboard.writeText(pathtracer.printLocation()).then(
                () => { copyBtn.textContent = 'Copied!';     setTimeout(() => copyBtn.textContent = 'Copy Pose', 1000); },
                () => { copyBtn.textContent = 'Copy failed'; setTimeout(() => copyBtn.textContent = 'Copy Pose', 1000); },
            );
        });
        cam.append(copyBtn);

        //Save to Scene: write the live settings/pose straight into the scene's
        //settings.js (dev only — the dev server does the write). Download is the
        //offline fallback (and the right tool in a build).
        if(import.meta.env.DEV){
            const saveBtn = button('Save to Scene', () => this.saveToScene(pathtracer, sceneParams, saveBtn));
            saveBtn.dataset.label = 'Save to Scene';
            cam.append(saveBtn);
        }

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

        exp.append(button('Save Image', () => pathtracer.saveImage()));
        if(import.meta.env.DEV){
            const saveBtn = button('Save to Scene', () => this.saveToScene(pathtracer, sceneParams, saveBtn));
            saveBtn.dataset.label = 'Save to Scene';
            exp.append(saveBtn);
        }
        exp.append(button('Download Settings', () => this.downloadSettings(pathtracer, sceneParams)));

        //one unified autosave for the live view
        exp.append(section('Auto Save'));
        exp.append(toggle({label: 'Auto Save', value: false},
            (on) => { pathtracer.autoSave = on; }));
        exp.append(numberField('Every (spp)', pathtracer.autoSaveSPP,
            (v) => { pathtracer.autoSaveSPP = v; }));

        //HD render: you set ONE dimension; the other is derived from the current
        //view's aspect (so the output matches whatever you've framed on screen).
        //planHD tiles it into a square grid, each tile saved as it finishes.
        exp.append(section('HD Render'));
        let hd = { fix: 'w', size: window.innerWidth * 2, spp: 1000, maxTile: 4000, tile: 0 };

        const fullSize = () => {
            let h = pathtracer.canvas.height || 1;
            let aspect = pathtracer.canvas.width / h;
            return hd.fix === 'w'
                ? { w: hd.size, h: Math.round(hd.size / aspect) }
                : { w: Math.round(hd.size * aspect), h: hd.size };
        };

        const sizeRow = numberField('Width', hd.size, (v) => hd.size = v);
        exp.append(select('Fix', [['Width', 'w'], ['Height', 'h']], 'w', (d) => {
            hd.fix = d;
            sizeRow.querySelector('.knob-label').textContent = (d === 'w') ? 'Width' : 'Height';
        }));
        exp.append(sizeRow);
        exp.append(numberField('Samples', hd.spp, (v) => hd.spp = v));
        exp.append(button('Start HD Render', () => {
            let s = fullSize();
            pathtracer.startHDRender(s.w, s.h, hd.spp, {maxTile: hd.maxTile});
        }));

        //live progress / plan readout (derived full size + tiling)
        const hdInfo = el('div', 'gui-pose');
        exp.append(hdInfo);
        const refreshHd = () => {
            //lock the controls (grey the tab bodies) while an HD render runs, so
            //touching a knob can't restart accumulation. Tabs/hamburger stay live.
            panel.el.classList.toggle('rendering', pathtracer.rendering);
            if(pathtracer.hd && pathtracer.hd.active){
                let pr = pathtracer.tracer.material.uniforms.panelToRender.value;
                let fn = Math.floor(pathtracer.tracer.material.uniforms.frameNumber.value);
                hdInfo.textContent = `tile ${pr + 1}/${pathtracer.hd.N} · ${fn}/${pathtracer.hd.spp} spp`;
            } else {
                let s = fullSize();
                let p = pathtracer.planHD(s.w, s.h, hd.maxTile);
                hdInfo.textContent = `${s.w}×${s.h} · ${p.root}×${p.root} · ${p.tileW}×${p.tileH} tiles`;
            }
            requestAnimationFrame(refreshHd);
        };
        refreshHd();

        const adv = collapsible('Advanced');
        exp.append(adv);
        adv.body.append(numberField('Max Tile', hd.maxTile, (v) => hd.maxTile = v));
        adv.body.append(numberField('Tile #',   hd.tile,    (v) => hd.tile = v));
        adv.body.append(button('Re-render Tile', () => {
            let s = fullSize();
            pathtracer.startHDRender(s.w, s.h, hd.spp, {maxTile: hd.maxTile, tile: hd.tile});
        }));

        //--- Help: static keybinding map + fps stats ---
        const help = panel.tab('Help');

        help.append(section('Panel'));
        let panelKeys = el('div', 'gui-keys');
        for(let [k, d] of [['H', 'show / hide panel'], ['X', 'save image'], ['= / −', 'nudge selected slider']]){
            panelKeys.append(el('span', 'key', k), el('span', 'desc', d));
        }
        help.append(panelKeys);

        help.append(section('Camera Keys'));
        let keys = el('div', 'gui-keys');
        for(let [k, d] of KEYBINDINGS){
            keys.append(el('span', 'key', k), el('span', 'desc', d));
        }
        help.append(keys);

        help.append(section('Mouse'));
        let mouseKeys = el('div', 'gui-keys');
        for(let [k, d] of [['drag', 'orbit the view'], ['pinch', 'zoom in / out']]){
            mouseKeys.append(el('span', 'key', k), el('span', 'desc', d));
        }
        help.append(mouseKeys);

        //host the fps meter here (createScene hands us stats instead of
        //appending it to <body>). Strip its fixed positioning to sit in-flow.
        if(stats){
            stats.dom.style.position = 'static';
            help.append(section('Performance'));
            help.append(stats.dom);
        }
    }

    //regenerate a scene's settings.js source (engine knob values + scene params
    //+ camera pose) from the current live GUI state. Shared by Download and Save.
    settingsText(pathtracer, sceneParams){
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
        return contents;
    }

    //the current scene folder, read from the page's <script src=".../example/<scene>/main.js">
    sceneName(){
        let s = document.querySelector('script[src*="/example/"]');
        let m = s && s.getAttribute('src').match(/example\/([^/]+)\//);
        return m ? m[1] : null;
    }

    //flash a transient label on a button, then restore its permanent one
    flash(btn, msg){
        btn.textContent = msg;
        setTimeout(() => { btn.textContent = btn.dataset.label; }, 1200);
    }

    //write the current settings straight into the scene's settings.js via the
    //dev-server endpoint (see vite.config.js). Dev only; Vite then hot-reloads.
    saveToScene(pathtracer, sceneParams, btn){
        let scene = this.sceneName();
        if(!scene){ this.flash(btn, 'No scene?'); return; }
        fetch('/__save-settings', {
            method:  'POST',
            headers: {'Content-Type': 'application/json'},
            body:    JSON.stringify({scene, contents: this.settingsText(pathtracer, sceneParams)}),
        }).then(r => r.json()).then(
            res => this.flash(btn, res.ok ? 'Saved!' : 'Failed'),
            ()  => this.flash(btn, 'Failed'),
        );
    }

    //trigger a browser download of the regenerated settings.js (offline fallback)
    downloadSettings(pathtracer, sceneParams){
        let contents = this.settingsText(pathtracer, sceneParams);
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
