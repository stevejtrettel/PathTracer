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


class UI{
    constructor(pathtracer){

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

        //--- Camera: lens knobs ---
        const cam = panel.tab('Camera');
        for(let k of camKnobs) cam.append(control(k, wire(k)));

        //--- Render: quality + on-screen geometry ---
        const ren = panel.tab('Render');
        for(let k of renKnobs) ren.append(control(k, wire(k)));

        ren.append(button('Size to Screen',
            () => pathtracer.resize({x: window.innerWidth, y: window.innerHeight})));

        ren.append(toggle({label: 'Preview (pixelated)', value: false}, (on) => {
            let adjust = on ? 1/4 : 1;
            let res = {x: Math.floor(adjust * window.innerWidth), y: Math.floor(adjust * window.innerHeight)};
            pathtracer.accumulate.setSize(res);
            pathtracer.tracer.setSize(res);
        }));

        //--- Export: files (images + settings), incl. the whole HD-tile feature ---
        const exp = panel.tab('Export');

        exp.append(button('Save Image',        () => pathtracer.saveImage()));
        exp.append(button('Download Settings', () => this.downloadSettings(pathtracer, sceneParams)));

        exp.append(section('Auto Save'));
        exp.append(toggle({label: 'Auto Save', value: false},
            (on) => { pathtracer.autoSave = on; }));
        exp.append(numberField('Save At (spp)', pathtracer.autoSaveSPP,
            (v) => { pathtracer.autoSaveSPP = v; }));

        exp.append(section('HD Tiles'));
        //panel dimensions: resize keeps the other dimension (mirrors legacy pairing)
        let panelW = window.innerWidth, panelH = window.innerHeight;
        exp.append(numberField('Panel Width',  panelW,
            (v) => { panelW = v; pathtracer.resize({x: panelW, y: panelH}); }));
        exp.append(numberField('Panel Height', panelH,
            (v) => { panelH = v; pathtracer.resize({x: panelW, y: panelH}); }));
        exp.append(select('# Panels', [1, 4, 9, 16, 25], 1, (v) => {
            pathtracer.tracer.updateUniforms({numPanels: v});
            pathtracer.reset();
        }));
        exp.append(toggle({label: 'Auto Save Panels', value: false}, (on) => {
            pathtracer.autoSavePanels = on;
            pathtracer.tracer.updateUniforms({renderPanel: on, panelToRender: 0});
            pathtracer.reset();
        }));
        exp.append(numberField('Save At (spp)', pathtracer.autoSavePanelsSPP,
            (v) => { pathtracer.autoSavePanelsSPP = v; }));

        exp.append(section('Individual Panel'));
        exp.append(numberField('Current Panel', 0, (v) => {
            pathtracer.tracer.updateUniforms({panelToRender: v});
            pathtracer.reset();
        }));
        exp.append(toggle({label: 'Render This Panel', value: false}, (on) => {
            pathtracer.tracer.updateUniforms({renderPanel: on});
            pathtracer.reset();
        }));

        //--- Help: static keybinding map ---
        const help = panel.tab('Help');
        help.append(section('Camera Keys'));
        let keys = el('div', 'gui-keys');
        for(let [k, d] of KEYBINDINGS){
            keys.append(el('span', 'key', k), el('span', 'desc', d));
        }
        help.append(keys);
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
