import {WebGLRenderer} from "three";

import ComputeShader from "./ComputeShader.js";
import KeyControls from "./KeyControls.js";


//class to run the path tracer from
class PathTracer{
    constructor(shaders, settings, res={x:window.innerWidth,y:window.innerHeight}) {

        this.settings = settings;

        //build the renderer
        this.renderer = new WebGLRenderer({
            //this is what lets me screenshot the canvas I guess?
            preserveDrawingBuffer:true,
        });

        //set up for autosave
        this.autoSave = false;
        this.autoSaveSPP = 100000;

        this.autoSavePanels = false;
        this.autoSavePanelsSPP = 100000;


        this.canvas = this.renderer.domElement;
        document.body.appendChild(this.canvas);
        this.renderer.setSize(res.x,res.y);

        //the control system
        this.controls = new KeyControls(this.settings.location);

        //the shaders
        this.tracer = new ComputeShader(shaders.tracer, this.renderer,res);
        this.accumulate = new ComputeShader(shaders.accumulate, this.renderer,res);
        this.display = new ComputeShader(shaders.display, this.renderer,res);

    }

    updateUniforms(){
        this.tracer.material.uniforms.frameNumber.value +=1.;
        this.accumulate.material.uniforms.frameNumber.value += 1.;

        if(this.controls.isPressed()){
            this.controls.update();
            this.tracer.updateUniforms({
                facing: this.controls.facing,
                location: this.controls.position,
            });
           this.reset();
        }
    }



    newFrame(){

        this.updateUniforms();

        //render a new frame
        this.tracer.render();
        this.accumulate.updateUniforms({newTex: this.tracer.getData()} );

        //accumulate it
        this.accumulate.render();
        this.accumulate.updateUniforms({accTex: this.accumulate.getData()} );
        this.display.updateUniforms({accTex: this.accumulate.getData()} );

        //display it
         this.display.renderToScreen();

         //if autosave is enabled: save when asked
        if(this.autoSave){
            if(this.tracer.material.uniforms.frameNumber.value % this.autoSaveSPP == 0){
                this.saveImage();
            }
        }

        if(this.autoSavePanels){

            if(this.tracer.material.uniforms.panelToRender.value<this.tracer.material.uniforms.numPanels.value) {
                if (this.tracer.material.uniforms.frameNumber.value == this.autoSavePanelsSPP) {
                    this.saveImage();
                    this.tracer.material.uniforms.panelToRender.value += 1;
                    this.reset();
                }
            }
        }
    }

    reset(){
        this.tracer.updateUniforms({frameNumber:0});
        this.accumulate.updateUniforms({frameNumber:0});
    }


    saveImage(){

        const date = new Date();
        let day = date.getDate();
        let month = date.getMonth() + 1;
        let hour = date.getHours();
        let minute = date.getMinutes();

        let canvas = this.canvas;
        let link = document.createElement('a');
        link.download = `${this.tracer.material.uniforms.frameNumber.value}spp pathtrace ${month}-${day}-${hour}${minute}`+'.png';
        link.href = canvas.toDataURL("image/png");
            //.replace("image/png", "image/octet-stream");
        link.click();
    }

    resize(res){
        this.tracer.setSize(res);
        this.accumulate.setSize(res);
        this.display.setSize(res);
        this.renderer.setSize(res.x,res.y);
    }

    printLocation(){
        return this.controls.printLocation();
    }



}


export default PathTracer;
