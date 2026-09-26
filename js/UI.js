import Panel from "./gui/Panel.js";
import {el, control, toggle, button, numberField, select, section, collapsible, isTypingTarget} from "./gui/widgets.js";
import {serializeKnobs, serializeUiParams, withValues, toUniformValue} from "./shaderData/knobs.js";
import {cameraKnobs, renderKnobs, scratchKnobs, debugKnobs, engineKnobs} from "./shaderData/engineKnobs.js";


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

// seconds as a short duration: "42s", "3m 12s", "1h 05m"
function fmtDuration(secs){
    secs = Math.max(0, Math.round(secs));
    if(secs < 60)   return `${secs}s`;
    if(secs < 3600) return `${Math.floor(secs / 60)}m ${String(secs % 60).padStart(2, '0')}s`;
    return `${Math.floor(secs / 3600)}h ${String(Math.floor(secs / 60) % 60).padStart(2, '0')}m`;
}

class UI{
    constructor(pathtracer){

        //single-key shortcuts: X saves an image (S is the camera pitch-down key),
        //P pauses / resumes. Skipped while typing in a field, so the letters
        //still type normally; a held key's auto-repeat fires only once.
        window.addEventListener('keydown', (e) => {
            if(e.repeat || isTypingTarget(document.activeElement)) return;
            if(e.key === 'x' || e.key === 'X') pathtracer.saveImage();
            if(e.key === 'p' || e.key === 'P') pathtracer.paused = !pathtracer.paused;
        });

        //engine-owned knobs, with per-scene values pulled from settings.uiParams
        const uiParams    = pathtracer.settings.uiParams;
        const camKnobs    = withValues(cameraKnobs,  uiParams);
        const renKnobs    = withValues(renderKnobs,  uiParams);
        const scrKnobs    = withValues(scratchKnobs, uiParams);
        const dbgKnobs    = withValues(debugKnobs,   uiParams);
        const sceneParams = pathtracer.settings.params ?? [];

        //current knob values, seeded per-scene, kept live by wire() below so the
        //Download-Settings serialization sees exactly what the sliders show.
        this.values = {};
        for(let k of [...camKnobs, ...renKnobs, ...scrKnobs, ...dbgKnobs, ...sceneParams]){
            this.values[k.name] = k.value;
        }

        //the one place that knows a knob drives a uniform. Injected into every
        //widget as its onChange; also records the value for serialization.
        const wire = (knob) => (value) => {
            //the HD render lock: CSS blocks pointer input, this blocks the
            //keyboard paths (slider nudge keys, tab-focused controls)
            if(pathtracer.rendering) return;
            this.values[knob.name] = value;   // stored as-is (array for color/vec2) for serialization
            //a display-time knob (exposure) acts on the finished average: re-draw only
            if(knob.pass === 'display'){
                pathtracer.display.updateUniforms({ [knob.name]: toUniformValue(knob, value) });
                return;
            }
            pathtracer.tracer.updateUniforms({ [knob.name]: toUniformValue(knob, value) });
            pathtracer.reset();
        };

        //Save-to-Scene (dev only: the dev server does the write) + the offline
        //Download fallback. Both persist the whole scene (knobs + pose); they live
        //only on the Export tab (the single home for output/persistence).
        const saveButtons = (tabBody) => {
            if(import.meta.env.DEV){
                const saveBtn = button('Save to Scene', () => this.saveToScene(pathtracer, sceneParams, saveBtn));
                saveBtn.dataset.label = 'Save to Scene';
                tabBody.append(saveBtn);
            }
            tabBody.append(button('Download Settings', () => this.downloadSettings(pathtracer, sceneParams)));
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

        //focus peaking: a camera aid, so it sits with the lens controls (focalLength
        //above). The toggle flips the focus-peaking debug lens (uDebugMode 8); the band
        //knob sets its zone width. Concentric zones (cyan=sharp .. red=out) over a
        //lit preview — dial focal length above and watch the focus zones move.
        const focusBandKnob = dbgKnobs.find((k) => k.name === 'dbgFocusBand');
        cam.append(section('Focus Aid'));
        cam.append(toggle({label: 'Focus Peaking', value: this.values.uDebugMode === 8}, (on) => {
            if(pathtracer.rendering) return;
            let v = on ? 8 : 0;
            this.values.uDebugMode = v;
            pathtracer.tracer.updateUniforms({ uDebugMode: v });
            pathtracer.reset();
        }));
        cam.append(control(focusBandKnob, wire(focusBandKnob)));

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
        };

        const home = pathtracer.settings.location;
        cam.append(button('Reset Camera', () => {
            pathtracer.controls.position.set(home.position[0], home.position[1], home.position[2]);
            pathtracer.controls.facing.set(
                home.facing[0], home.facing[1], home.facing[2],
                home.facing[3], home.facing[4], home.facing[5],
                home.facing[6], home.facing[7], home.facing[8]
            ).orthonormalize();
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
                () => this.flash(copyBtn, 'Copied!'),
                () => this.flash(copyBtn, 'Copy failed'),
            );
        });
        copyBtn.dataset.label = 'Copy Pose';
        cam.append(copyBtn);

        //--- Debug: cheap one-shot preview + diagnostic lenses (see debugPass.glsl) ---
        const dbg = panel.tab('Debug');
        const modeKnob  = dbgKnobs.find((k) => k.name === 'uDebugMode');
        const scaleKnob = dbgKnobs.find((k) => k.name === 'dbgHeatScale');
        //focus peaking (mode 8) lives in the Camera tab with the lens controls.
        dbg.append(select('Mode', [
            ['Off (path trace)', 0],
            ['Lit Preview',      7],
            ['Albedo',           6],
            ['Normals',          1],
            ['Depth',            4],
            ['Cost Heatmap',     2],
            ['DE Quality',       3],
            ['Overstep',         5],
            ['Bound Shells',     9],
        ], this.values.uDebugMode, wire(modeKnob)));
        dbg.append(control(scaleKnob, wire(scaleKnob)));   // heatmap step scale

        //--- Render: quality + live image ---
        const ren = panel.tab('Render');
        for(let k of renKnobs) ren.append(control(k, wire(k)));   // maxBounces

        //render scale: the tracer/accumulate resolution as a fraction of the
        //CURRENT canvas (so a chosen aspect is respected). Full = native;
        //Half/Quarter render smaller and let the display stretch them up
        //(pixelated but fast) — Quarter is the old "preview".
        //(the scale lives on the path tracer, so resize() keeps it — including
        //the resize that restores the view after an HD render)
        ren.append(select('Scale', [['Full', 1], ['Half', 0.5], ['Quarter', 0.25]], 1,
            (scale) => pathtracer.setViewScale(scale)));

        //while the camera moves (keys or mouse), trace at quarter scale so flying
        //stays responsive; the chosen Scale returns a moment after it stops.
        //Off by default; a scene opts in with previewWhileMoving: true in its
        //settings (Save to Scene records the toggle's state)
        ren.append(toggle({label: 'Fast Preview While Moving', value: pathtracer.previewWhileMoving},
            (on) => { pathtracer.previewWhileMoving = on; }));

        //live aspect ratio: re-fit the canvas to a preset ratio, keeping the
        //current Scale (and re-fit to it when the window resizes). Preselects the
        //scene's settings.aspect (so cubic-portrait/landscape land on √2).
        ren.append(select('Aspect', ASPECTS, pathtracer.aspect,
            (aspect) => pathtracer.setAspect(aspect)));

        //samples accumulated (live), pause, an optional stopping point, restart
        ren.append(section('Samples'));
        const spp = el('div', 'gui-pose');
        ren.append(spp);
        const pauseBtn = button('Pause', () => { pathtracer.paused = !pathtracer.paused; });
        ren.append(pauseBtn);
        ren.append(numberField('Stop At (spp, 0 = never)', pathtracer.stopAt,
            (v) => { pathtracer.stopAt = Math.max(0, Math.round(v)); }));
        const refreshSpp = () => {
            let n = Math.floor(pathtracer.frameCount);
            let state = pathtracer.paused ? ' · paused'
                      : pathtracer.holding ? ' · done'
                      : '';
            spp.textContent = `${n} spp${state}`;
            pauseBtn.textContent = pathtracer.paused ? 'Resume' : 'Pause';
        };
        ren.append(button('Reset Samples', () => pathtracer.reset()));

        //--- Export: produce files ---
        const exp = panel.tab('Export');

        exp.append(button('Save Image', () => pathtracer.saveImage()));
        saveButtons(exp);

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
            let progress = pathtracer.hdProgress();
            if(progress){
                let pr = pathtracer.tracer.material.uniforms.panelToRender.value;
                let fn = Math.floor(pathtracer.frameCount);
                let eta = progress.eta === null ? '' : ` · ${fmtDuration(progress.eta)} left`;
                hdInfo.textContent = `tile ${pr + 1}/${pathtracer.hd.N} · ${fn}/${pathtracer.hd.spp} spp${eta}`;
            } else {
                let s = fullSize();
                let p = pathtracer.planHD(s.w, s.h, hd.maxTile);
                hdInfo.textContent = `${s.w}×${s.h} · ${p.root}×${p.root} · ${p.tileW}×${p.tileH} tiles`;
            }
        };

        //one shared per-frame refresh for all live readouts (pose, spp, HD)
        const refreshUI = () => {
            refreshPose();
            refreshSpp();
            refreshHd();
            requestAnimationFrame(refreshUI);
        };
        refreshUI();

        const adv = collapsible('Advanced');
        exp.append(adv);
        adv.body.append(numberField('Max Tile', hd.maxTile, (v) => hd.maxTile = v));
        adv.body.append(numberField('Tile #',   hd.tile,    (v) => hd.tile = v));
        adv.body.append(button('Re-render Tile', () => {
            let s = fullSize();
            pathtracer.startHDRender(s.w, s.h, hd.spp, {maxTile: hd.maxTile, tile: hd.tile});
        }));

        //--- Help: static keybinding map ---
        const help = panel.tab('Help');

        help.append(section('Panel'));
        let panelKeys = el('div', 'gui-keys');
        for(let [k, d] of [['H', 'show / hide panel'], ['X', 'save image'], ['P', 'pause / resume'],
                           ['= / −', 'nudge selected slider']]){
            panelKeys.append(el('span', 'key', k), el('span', 'desc', d));
        }
        help.append(panelKeys);

        help.append(section('Knobs'));
        let knobKeys = el('div', 'gui-keys');
        for(let [k, d] of [['click name', 'select for = / − nudging'], ['double-click name', 'reset to the scene\'s value'],
                           ['click value', 'type a value (Enter / Esc)']]){
            knobKeys.append(el('span', 'key', k), el('span', 'desc', d));
        }
        help.append(knobKeys);

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
    }

    //regenerate a scene's settings.js source (engine knob values + scene params
    //+ camera pose) from the current live GUI state. Shared by Download and Save.
    settingsText(pathtracer, sceneParams){
        let contents = '';
        contents += serializeUiParams(engineKnobs, this.values);
        contents += `\n\n\n`;
        contents += pathtracer.printLocation();
        contents += `\n\n`;
        let exportKeys = ['uiParams: uiParams', 'location: location'];
        if(sceneParams.length){
            contents += serializeKnobs(sceneParams, this.values);
            contents += `\n\n`;
            exportKeys.push('params: params');
        }
        //preserve the non-GUI settings fields (sky, aspect, defines) — the
        //regenerated file used to silently drop them (skyDemo lost its sky on
        //Save; a demo scene would lose its engine #defines). Only as the FILE
        //had them (emit's `authored`): the generator merges derived defines and
        //the description's sky into the live settings, and writing those back
        //froze them into settings.js after the scene stopped deriving them.
        let authored = pathtracer.settings.authored ?? pathtracer.settings;
        for(let key of ['sky', 'aspect', 'defines']){
            if(authored[key] !== undefined){
                contents += `let ${key} = ${JSON.stringify(authored[key])};\n`;
                exportKeys.push(`${key}: ${key}`);
            }
        }
        //the fast-preview-while-moving opt-in, as currently toggled (off = omitted)
        if(pathtracer.previewWhileMoving){
            contents += `let previewWhileMoving = true;\n`;
            exportKeys.push('previewWhileMoving: previewWhileMoving');
        }
        contents += `\nexport default {${exportKeys.join(', ')}};`;
        return contents;
    }

    //the current scene folder, from the page URL (/scenes/<name>/ or /demos/<name>/)
    sceneName(){
        let m = window.location.pathname.match(/\/(?:scenes|demos)\/([^/]+)\//);
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
            res => {
                if(!res.ok && res.error) console.error('Save to Scene failed: ' + res.error);
                this.flash(btn, res.ok ? 'Saved!' : 'Failed');
            },
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
