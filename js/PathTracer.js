import {GUI} from './libs/dat.gui.module.js';

import ComputeShader from "./ComputeShader.js";
import KeyControls from "./KeyControls.js";




//class to run the path tracer from
class PathTracer{
    constructor(shaders, renderer, res={x:window.innerWidth,y:window.innerHeight}) {

        //view and controls
        this.renderer = renderer;
        this.controls = new KeyControls();

        //the shaders
        this.trace = new ComputeShader(shaders.trace, this.renderer,res);
        this.accumulate = new ComputeShader(shaders.accumulate, this.renderer,res);
        this.display = new ComputeShader(shaders.display, this.renderer,res);

    }s

    updateUniforms(){
        this.trace.material.uniforms.frameSeed.value +=1.;
        this.accumulate.material.uniforms.frameNumber.value += 1.;

        if(this.controls.isPressed()){
            this.controls.update();
            this.trace.updateUniforms({
                facing: this.controls.facing,
                location: this.controls.position,
            });
           this.reset();
        }
    }



    newFrame(){

        this.updateUniforms();

        //render a new frame
        this.trace.render();
        this.accumulate.updateUniforms({new: this.trace.getData()} );

        //accumulate it
        this.accumulate.render();
        this.accumulate.updateUniforms({acc: this.accumulate.getData()} );
        this.display.updateUniforms({acc: this.accumulate.getData()} );

        //display it
         this.display.renderToScreen();

    }

    reset(){
        this.trace.updateUniforms({frameSeed:0});
        this.accumulate.updateUniforms({frameNumber:0});
    }


    saveImage(){
        // // Grab the canvas element
        // let canvas = document.getElementById("World");
        // console.log(canvas);
        // // Create a PNG image of the pixels drawn on the canvas using the toDataURL method.
        // let dataURL = canvas.toDataURL("image/png");
        // // Create a dummy link text
        // let a = document.createElement('a');
        // // Set the link to the image so that when clicked, the image begins downloading
        // a.href = dataURL
        // // Specify the image filename
        // a.download = `${this.compute.material.uniforms.frameSeed.value}`+'.png';
        // // Click on the link to set off download
        // a.click();
        // //remove this element fromm the doc
        // //document.removeChild(a);
    }

    resize(res){
        this.trace.resize(res);
        this.accumulate.resize(res);
        this.display.resize(res);
    }

}


export default PathTracer;