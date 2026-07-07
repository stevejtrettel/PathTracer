import {WebGLRenderer, Vector2} from "three";

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

        //set up for autosave (live view)
        this.autoSave = false;
        this.autoSaveSPP = 100000;

        //HD tile render state (null when idle); see startHDRender()
        this.hd = null;

        //true while an HD render is in progress: locks the inputs that would
        //restart accumulation (camera keys + GUI knobs) so a stray touch can't
        //wreck a long tiled export. Live-view tweaking is unaffected.
        this.rendering = false;


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

        if(!this.rendering && this.controls.isPressed()){
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

        //HD tile render: render each tile to `spp` samples, save it, advance;
        //restore the view size when the whole grid is done (see startHDRender)
        if(this.hd && this.hd.active){
            let pr = this.tracer.material.uniforms.panelToRender.value;
            if(pr < this.hd.stopAfter){
                if(this.tracer.material.uniforms.frameNumber.value >= this.hd.spp){
                    let row = Math.floor(pr / this.hd.root), col = pr % this.hd.root;
                    this.saveImage(`hd_${this.hd.spp}spp_r${row}c${col}`);
                    this.tracer.material.uniforms.panelToRender.value = pr + 1;
                    this.reset();
                }
            } else {
                this.hd.active = false;
                this.rendering = false;
                this.tracer.updateUniforms({renderPanel: false, panelToRender: 0});
                this.resize(this.hdRestore);
                this.reset();
            }
        }
    }

    reset(){
        this.tracer.updateUniforms({frameNumber:0});
        this.accumulate.updateUniforms({frameNumber:0});
    }


    saveImage(label){

        let name = label;
        if(!name){
            const date = new Date();
            let day = date.getDate();
            let month = date.getMonth() + 1;
            let hour = date.getHours();
            let minute = date.getMinutes();
            name = `${this.tracer.material.uniforms.frameNumber.value}spp pathtrace ${month}-${day}-${hour}${minute}`;
        }

        let link = document.createElement('a');
        link.download = name + '.png';
        link.href = this.canvas.toDataURL("image/png");
        link.click();
    }


    //plan a square √N tiling of a finalW×finalH image so each tile is <= maxTile
    //and (when possible) >= minTile. Tiles share the final image's aspect ratio.
    planHD(finalW, finalH, maxTile=4000, minTile=1000){
        let maxDim = Math.max(finalW, finalH);
        let root = Math.max(1, Math.ceil(maxDim / maxTile));
        while(root > 1 && maxDim / root < minTile) root--;   //don't go below minTile
        return {
            root:  root,
            N:     root * root,
            tileW: Math.round(finalW / root),
            tileH: Math.round(finalH / root),
        };
    }


    //begin an HD tile render: split the final image into a √N grid, render each
    //tile to `spp` samples and save it (advancing automatically). Each tile is
    //saved as it finishes, so a crash mid-render only loses the current tile.
    //opts.tile renders ONLY that one tile (recovery); opts.maxTile caps tile px.
    startHDRender(finalW, finalH, spp, opts={}){
        let plan = this.planHD(finalW, finalH, opts.maxTile);
        let start = (opts.tile != null) ? Math.min(Math.max(opts.tile, 0), plan.N - 1) : 0;

        //remember the current view size, to restore when the render finishes
        let cur = new Vector2();
        this.renderer.getSize(cur);
        this.hdRestore = {x: cur.x, y: cur.y};

        this.resize({x: plan.tileW, y: plan.tileH});
        this.tracer.updateUniforms({numPanels: plan.N, panelToRender: start, renderPanel: true});
        this.reset();

        this.hd = {
            active:    true,
            root:      plan.root,
            N:         plan.N,
            spp:       spp,
            stopAfter: (opts.tile != null) ? start + 1 : plan.N,
        };
        this.rendering = true;
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
