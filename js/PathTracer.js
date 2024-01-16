import {GUI} from './libs/dat.gui.module.js';

import ComputeShader from "./ComputeShader.js";
import KeyControls from "./KeyControls.js";



//class to run the path tracer from
class PathTracer{
    constructor(shaders, renderer) {

        //view and controls
        this.renderer = renderer;
        this.controls = new KeyControls();

        //the shaders
        this.compute = new ComputeShader(shaders.compute, this.renderer);
        this.accumulate = new ComputeShader(shaders.accumulate, this.renderer);
        this.display = new ComputeShader(shaders.display, this.renderer);

    }

    updateUniforms(){
        this.compute.material.uniforms.frameSeed.value +=1.;
        this.accumulate.material.uniforms.frameNumber.value += 1.;

        if(this.controls.isPressed()){
            this.controls.update();
            this.compute.updateUniforms({
                facing: this.controls.facing,
                location: this.controls.position,
                frameSeed: 0,
            });
            this.accumulate.updateUniforms({frameNumber:0} );
        }
    }



    newFrame(){

        this.updateUniforms();

        //render a new frame
        this.compute.render();
        this.accumulate.updateUniforms({new: this.compute.getData()} );

        //accumulate it
        this.accumulate.render();
        this.accumulate.updateUniforms({acc: this.accumulate.getData()} );
        this.display.updateUniforms({acc: this.accumulate.getData()} );

        //display it
         this.display.renderToScreen();

    }

    reset(){
        this.compute.updateUniforms({frameSeed:0});
        this.accumulate.updateUniforms({frameNumber:0});
    }


    saveImage(){

    }

}


export default PathTracer;