import {GUI} from "./libs/dat.gui.module.js";

class UI extends GUI{
    constructor(pathtracer) {
        super();

        this.params = {
            aperture: 0.0,
            focalLength:5,
            exposure:1,
            focusHelp:false,
            fov:50,
            extra:0.5,
            extra2:0.5,
            extra3:0.5,
            extra4:0.5,
            saveit: ()=>pathtracer.saveImage(),
            preview: false,
            renderBlocks:false,
        };

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

        ren.add(this.params, 'preview').name('Preview').onChange(function(value){
            let adjust = 1.;
            if(value){ adjust =1/4;}
            let res = {x: Math.floor(adjust * window.innerWidth), y: Math.floor(adjust * window.innerHeight)};
            pathtracer.accumulate.setSize(res);
            pathtracer.tracer.setSize(res);
            //pathtracer.display.resize(res);
        });

        ren.add(this.params,'renderBlocks').name('Render Blocks').onChange(function(value){
            pathtracer.tracer.updateUniforms({renderBlocks:value});
        });

         this.add(this.params,'saveit').name('Save Image');

    }

}


export default UI;