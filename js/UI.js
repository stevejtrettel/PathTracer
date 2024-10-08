import {GUI} from "three/addons/libs/lil-gui.module.min";


class UI extends GUI{
    constructor(pathtracer) {
        super();

        this.params = {
            aperture: pathtracer.settings.uiParams.aperture,
            focalLength: pathtracer.settings.uiParams.focalLength,
            exposure: pathtracer.settings.uiParams.exposure,
            focusHelp:false,
            fov: pathtracer.settings.uiParams.fov,

            extra: pathtracer.settings.uiParams.extra,
            extra2: pathtracer.settings.uiParams.extra2,
            extra3: pathtracer.settings.uiParams.extra3,
            extra4: pathtracer.settings.uiParams.extra4,

            preview: false,
            // renderBlocks:false,
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
                contents += `export default {uiParams: uiParams, location:location};`

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


        this.printParams = () => {
                let str = `let uiParams = {\n`;
                str += `aperture: ${this.params.aperture},\n`;
                str += `focalLength: ${this.params.focalLength},\n`;
                str += `exposure: ${this.params.exposure},\n`;
                str += `focusHelp: ${this.params.focusHelp},\n`;
                str += `fov: ${this.params.fov},\n`;
                str += `extra: ${this.params.extra},\n`;
                str += `extra2: ${this.params.extra2},\n`;
                str += `extra3: ${this.params.extra3},\n`;
                str += `extra4: ${this.params.extra4},\n`;
                str += `}`;
                str += `\n\n`;
                str += `export {uiParams};`;
                return str;
        }

        //make folders
        const cam = this.addFolder('Camera');
        const params = this.addFolder('Parameters');
        const ren = this.addFolder('Render');
        //in case we need let
        let theParams = this.params;

        cam.add(this.params, 'aperture',0,2,0.001).name('Aperture').onChange(function(value){
            pathtracer.tracer.updateUniforms({aperture: value});
            pathtracer.reset();
        });
        cam.add(this.params, 'focalLength',0,40,0.01).name('Focal Length').onChange(function(value){
            pathtracer.tracer.updateUniforms({focalLength: value});
            pathtracer.reset();
        });
        cam.add(this.params, 'focusHelp').name('Focus Help').onChange(function(value){
            pathtracer.tracer.updateUniforms({focusHelp: value});
            pathtracer.reset();
        });;
        cam.add(this.params, 'fov',15,140,1).name('FOV').onChange(function(value){
            pathtracer.tracer.updateUniforms({fov: value});
            pathtracer.reset();
        });
        cam.add(this.params, 'exposure',0,2,0.01).name('Exposure').onChange(function(value){
            pathtracer.tracer.updateUniforms({exposure: value});
            pathtracer.reset();
        });


        params.add(this.params, 'extra',0,1,0.001).onChange(function(value){
            pathtracer.tracer.updateUniforms({extra:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra2',0,1,0.001).onChange(function(value){
            pathtracer.tracer.updateUniforms({extra2:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra3',0,1,0.001).onChange(function(value){
            pathtracer.tracer.updateUniforms({extra3:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra4',0,1,0.001).onChange(function(value){
            pathtracer.tracer.updateUniforms({extra4:value});
            pathtracer.reset();
        });

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







        //
        // HD.add(this.params, 'customWidth').name('Width (px)').onFinishChange(function(value){
        //     let aspect = window.innerHeight/window.innerWidth;
        //     let xRes = value;
        //     let yRes = aspect*value;
        //     pathtracer.resize({x:xRes,y: yRes});
        // });


        this.add(this.params,'printSettings').name('Download Settings');
        this.add(this.params,'saveit').name('Save Image');

    }

}


export default UI;
