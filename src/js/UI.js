import {GUI} from "three/addons/libs/lil-gui.module.min";

import {uiParams} from "./settings.js";

class UI extends GUI{
    constructor(pathtracer) {
        super();

        this.params = {
            aperture: uiParams.aperture,
            focalLength: uiParams.focalLength,
            exposure: uiParams.exposure,
            focusHelp:false,
            fov: uiParams.fov,

            extra: uiParams.extra,
            extra2: uiParams.extra2,
            extra3: uiParams.extra3,
            extra4: uiParams.extra4,

            preview: false,
            renderBlocks:false,

            customSize: window.innerWidth,

            resize: ()=>pathtracer.resize({x:window.innerWidth,y:window.innerHeight}),

            saveit: ()=>pathtracer.saveImage(),


            printSettings: ()=> {

                //assemble all the contents of the file here
                let contents = ``;
                contents += this.printParams();
                contents += `\n\n\n`;
                contents += pathtracer.printLocation();

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


        cam.add(this.params, 'aperture',0,2,0.001).name('Aperture').onChange(function(value){
            pathtracer.tracer.updateUniforms({aperture: value});
            pathtracer.reset();
        });
        cam.add(this.params, 'focalLength',0,40,0.01).name('Focal Length').onChange(function(value){
            pathtracer.tracer.updateUniforms({focalLength: value});
            pathtracer.reset();
        });;
        cam.add(this.params, 'focusHelp').name('Focus Help').onChange(function(value){
            pathtracer.tracer.updateUniforms({focusHelp: value});
            pathtracer.reset();
        });;
        cam.add(this.params, 'fov',40,140,1).name('FOV').onChange(function(value){
            pathtracer.tracer.updateUniforms({fov: value});
            pathtracer.reset();
        });
        cam.add(this.params, 'exposure',0,2,0.01).name('Exposure').onChange(function(value){
            pathtracer.tracer.updateUniforms({exposure: value});
            pathtracer.reset();
        });


        params.add(this.params, 'extra',0,1,0.01).onChange(function(value){
            pathtracer.tracer.updateUniforms({extra:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra2',0,1,0.01).onChange(function(value){
            pathtracer.tracer.updateUniforms({extra2:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra3',0,1,0.01).onChange(function(value){
            pathtracer.tracer.updateUniforms({extra3:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra4',0,1,0.01).onChange(function(value){
            pathtracer.tracer.updateUniforms({extra4:value});
            pathtracer.reset();
        });


        ren.add(this.params, 'customSize').name('Custom Width (px)').onFinishChange(function(value){
            let aspect = window.innerHeight/window.innerWidth;
            let xRes = value;
            let yRes = aspect*value;
            pathtracer.resize({x:xRes,y: yRes});
        });

        ren.add(this.params,'resize').name('Size to Screen');

        ren.add(this.params, 'preview').name('Preview Quality (Pixelated)').onChange(function(value){
            let adjust = 1.;
            if(value){ adjust =1/4;}
            let res = {x: Math.floor(adjust * window.innerWidth), y: Math.floor(adjust * window.innerHeight)};
            pathtracer.accumulate.setSize(res);
            pathtracer.tracer.setSize(res);
        });

        ren.add(this.params,'renderBlocks').name('Render Blocks').onChange(function(value){
            pathtracer.tracer.updateUniforms({renderBlocks:value});
        });

        this.add(this.params,'printSettings').name('Download Settings');

         this.add(this.params,'saveit').name('Save Image');


    }

}


export default UI;