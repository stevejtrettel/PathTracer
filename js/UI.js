import {GUI} from "./libs/dat.gui.module.js";

class UI extends GUI{
    constructor(pathtracer) {
        super();

        this.params = {
            aperture: 0.0,
            focalLength:5,
            brightness:1,
            focusHelp:false,
            fov:50,
            extra:0.5,
            extra2:0.5,
            extra3:0.5,
            extra4:0.5,
        };

        //make folders
        const cam = this.addFolder('Camera');
        const params = this.addFolder('Parameters');


        cam.add(this.params, 'aperture',0,2,0.001).name('Aperture').onChange(function(value){
            pathtracer.compute.updateUniforms({aperture: value});
            pathtracer.reset();
        });
        cam.add(this.params, 'focalLength',0,40,0.01).name('Focal Length').onChange(function(value){
            pathtracer.compute.updateUniforms({focalLength: value});
            pathtracer.reset();
        });;
        cam.add(this.params, 'focusHelp').name('Focus Help').onChange(function(value){
            pathtracer.compute.updateUniforms({focusHelp: value});
            pathtracer.reset();
        });;
        cam.add(this.params, 'fov',40,140,1).name('FOV').onChange(function(value){
            pathtracer.compute.updateUniforms({fov: value});
            pathtracer.reset();
        });


        params.add(this.params, 'extra',0,1,0.01).onChange(function(value){
            pathtracer.compute.updateUniforms({extra:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra2',0,1,0.01).onChange(function(value){
            pathtracer.compute.updateUniforms({extra2:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra3',0,1,0.01).onChange(function(value){
            pathtracer.compute.updateUniforms({extra3:value});
            pathtracer.reset();
        });
        params.add(this.params, 'extra4',0,1,0.01).onChange(function(value){
            pathtracer.compute.updateUniforms({extra4:value});
            pathtracer.reset();
        });

    }

}


export default UI;