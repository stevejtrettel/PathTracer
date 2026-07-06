import {GUI} from "three/addons/libs/lil-gui.module.min";
import {addKnobControls, serializeKnobs, serializeUiParams, withValues} from "./shaderData/knobs.js";
import {cameraKnobs, renderKnobs, scratchKnobs, engineKnobs} from "./shaderData/engineKnobs.js";


class UI extends GUI{
    constructor(pathtracer) {
        super();

        //named scene parameters (knobs) declared in the scene's settings.js
        const sceneParams = pathtracer.settings.params ?? [];

        //engine-owned knobs, with per-scene values pulled from settings.uiParams
        const uiParams = pathtracer.settings.uiParams;
        const camKnobs = withValues(cameraKnobs, uiParams);
        const renKnobs = withValues(renderKnobs, uiParams);
        const scrKnobs = withValues(scratchKnobs, uiParams);

        this.params = {

            preview: false,
            resize: ()=>pathtracer.resize({x:window.innerWidth,y:window.innerHeight}),


            autoSave: false,
            autoSavePanels: false,
            renderPanel: false,

            autoSaveSPP:pathtracer.autoSaveSPP,
            autoSavePanelsSPP:pathtracer.autoSavePanelsSPP,

            numPanels: 1,
            panelToRender:0,
            panelWidth: window.innerWidth,
            panelHeight: window.innerHeight,

            saveit: ()=>pathtracer.saveImage(),



            printSettings: ()=> {

                //assemble all the contents of the file here
                let contents = ``;
                contents += this.printParams();
                contents += `\n\n\n`;
                contents += pathtracer.printLocation();
                contents += `\n\n`;
                if(sceneParams.length){
                    contents += serializeKnobs(sceneParams, this.params);
                    contents += `\n\n`;
                    contents += `export default {uiParams: uiParams, location:location, params:params};`
                } else {
                    contents += `export default {uiParams: uiParams, location:location};`
                }

                const file = new File([contents], `settingsNew.js`, {
                    type: 'javascript',
                });

                //a function which allows the browser to automatically downlaod the file created
                //(a hack from online: it makes a download link, artificially clicks it, and removes the link)
                //https://javascript.plainenglish.io/javascript-create-file-c36f8bccb3be
                function download() {
                    const link = document.createElement('a')
                    const url = URL.createObjectURL(file)

                    link.href = url
                    link.download = file.name
                    document.body.appendChild(link)
                    link.click()

                    document.body.removeChild(link)
                    window.URL.revokeObjectURL(url)
                }

                download();
            }


        };


        //serialize the engine knobs (camera/render/scratch) to the flat
        //uiParams object, reading current values off this.params
        this.printParams = () => serializeUiParams(engineKnobs, this.params);

        //make folders
        const cam = this.addFolder('Camera');
        const params = this.addFolder('Parameters');
        const ren = this.addFolder('Render');
        //in case we need let
        let theParams = this.params;

        //generated controls: camera + scratch knobs, then the scene's named
        //params, then the render-quality knobs (maxBounces)
        addKnobControls(cam, camKnobs, this.params, pathtracer);
        addKnobControls(params, scrKnobs, this.params, pathtracer);

        if(sceneParams.length){
            const scene = this.addFolder('Scene');
            addKnobControls(scene, sceneParams, this.params, pathtracer);
        }

        addKnobControls(ren, renKnobs, this.params, pathtracer);

        ren.add(this.params,'resize').name('Size to Screen');

        ren.add(this.params, 'preview').name('Preview Quality (Pixelated)').onChange(function(value){
            let adjust = 1.;
            if(value){ adjust =1/4;}
            let res = {x: Math.floor(adjust * window.innerWidth), y: Math.floor(adjust * window.innerHeight)};
            pathtracer.accumulate.setSize(res);
            pathtracer.tracer.setSize(res);
        });

        ren.add(this.params, 'autoSaveSPP').name('Auto Save At').onChange(function(value){
            pathtracer.autoSaveSPP = value;
        });
        ren.add(this.params,'autoSave').name('Auto Save').onChange(function(value){
            pathtracer.autoSave=value;
        });

        //THE PANEL FOR HD RENDERING

        const HD = ren.addFolder('HD');
        HD.close();

        HD.add(this.params, 'panelWidth').name('Panel Width (px)').onFinishChange(function(value){
            pathtracer.resize({x:value,y: theParams.panelHeight});
        });
        HD.add(this.params, 'panelHeight').name('Panel Height (px)').onFinishChange(function(value){
            pathtracer.resize({x:theParams.panelWidth,y: value});
        });

        HD.add(this.params,'numPanels',{1:1,4:4,9:9,16:16,25:25}).onFinishChange(function(value){
            pathtracer.tracer.updateUniforms({numPanels:value});
            pathtracer.reset();
        });
        HD.add(this.params, 'autoSavePanelsSPP').name('Auto Save At').onChange(function(value){
            pathtracer.autoSavePanelsSPP = value;
        });
        HD.add(this.params,'autoSavePanels').onChange(function(value){
            //turn on auto-rendering:
            pathtracer.autoSavePanels=value;
            //let the camera know we are rendering panel-by-panel
            pathtracer.tracer.updateUniforms({renderPanel:value});
            //make sure we start with the first panel
            pathtracer.tracer.updateUniforms({panelToRender:0});
            //reset the frame
            pathtracer.reset();
        });

        const indi = HD.addFolder('Individual Panel');
        indi.close();

        indi.add(this.params,'panelToRender').name('Current Panel').onFinishChange(function(value){
            pathtracer.tracer.updateUniforms({panelToRender:value});
            pathtracer.reset();
        });

        indi.add(this.params,'renderPanel').name('Render This Panel').onChange(function(value){
            pathtracer.tracer.updateUniforms({renderPanel:value});
            pathtracer.reset();
        });


        this.add(this.params,'printSettings').name('Download Settings');
        this.add(this.params,'saveit').name('Save Image');

    }

}


export default UI;
