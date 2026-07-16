import ComputeShader from "./ComputeShader.js";
import KeyControls from "./KeyControls.js";
import OrbitControls from "./OrbitControls.js";


//class to run the path tracer from
class PathTracer{
    constructor(shaders, settings, res={x:window.innerWidth,y:window.innerHeight}) {

        this.settings = settings;

        //set up for autosave (live view)
        this.autoSave = false;
        this.autoSaveSPP = 100000;

        //HD tile render state (null when idle); see startHDRender()
        this.hd = null;

        //true while an HD render is in progress: locks the inputs that would
        //restart accumulation (camera keys + GUI knobs) so a stray touch can't
        //wreck a long tiled export. Live-view tweaking is unaffected.
        this.rendering = false;

        //raw WebGL2 canvas + context. preserveDrawingBuffer keeps toDataURL
        //working for saveImage; float render targets need EXT_color_buffer_float.
        this.canvas = document.createElement('canvas');
        this.gl = this.canvas.getContext('webgl2', {preserveDrawingBuffer: true});
        this.gl.getExtension('EXT_color_buffer_float');
        document.body.appendChild(this.canvas);
        this.size = res;
        this._setCanvasSize(res);

        //the control system
        this.controls = new KeyControls(this.settings.location);

        //the shaders
        this.tracer = new ComputeShader(shaders.tracer, this.gl, res);
        this.accumulate = new ComputeShader(shaders.accumulate, this.gl, res);
        this.display = new ComputeShader(shaders.display, this.gl, res);

        //the sky sampler needs a real texture; the uniforms were assembled before
        //the gl context existed, so build it here from the scene's sky descriptor
        //(1x1 white until an image loads — see buildSky / _makeSkyTexture).
        this.tracer.updateUniforms({sky: this._makeSkyTexture(shaders.tracer.sky)});

        //mouse orbit (adapted from the PathTracerGLSL repo): drag orbits the
        //look-point, pinch dollies. Writes the same position/facing the keyboard
        //uses, so the two compose. Suspended during an HD render (the lock).
        this.orbitEnabled = true;
        this.orbit = new OrbitControls(this.canvas, this.controls, {
            onChange: () => { this.tracer.updateUniforms({facing: this.controls.facing, location: this.controls.position}); this.reset(); },
            target:   this.settings.target ?? [0, 0, 0],
            enabled:  () => this.orbitEnabled && !this.rendering,
        });
    }

    //set the canvas backing-store size and its on-screen (CSS) size to match
    _setCanvasSize(res){
        this.canvas.width  = res.x;
        this.canvas.height = res.y;
        this.canvas.style.width  = res.x + 'px';
        this.canvas.style.height = res.y + 'px';
    }

    //build the sky WebGLTexture from a descriptor ({mode, src, color1, color2}).
    //1x1 white so the sampler is always complete; for image mode, an <img> loads
    //and replaces it (matching three's TextureLoader defaults: flipY, mipmaps,
    //linear-mipmap-linear, RGBA8/no sRGB decode), then restarts accumulation.
    _makeSkyTexture(desc){
        let gl = this.gl;
        let tex = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, new Uint8Array([255,255,255,255]));
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        if(desc && desc.src){
            let img = new Image();
            img.onload = () => {
                gl.bindTexture(gl.TEXTURE_2D, tex);
                gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
                gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
                gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, false);
                gl.generateMipmap(gl.TEXTURE_2D);
                gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
                this.reset();
            };
            img.src = desc.src;
        }
        return tex;
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
                this.stopHDRender();
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
        this.hdRestore = {x: this.size.x, y: this.size.y};

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

    //end an HD render: on natural completion (all tiles saved) OR user cancel.
    //Clears the tile state, unlocks the controls, and restores the live view.
    //Safe to call when idle (no-op).
    stopHDRender(){
        if(!this.rendering) return;
        if(this.hd) this.hd.active = false;
        this.rendering = false;
        this.tracer.updateUniforms({renderPanel: false, panelToRender: 0});
        this.resize(this.hdRestore);
        this.reset();
    }

    resize(res){
        this.size = res;
        this._setCanvasSize(res);
        this.tracer.setSize(res);
        this.accumulate.setSize(res);
        this.display.setSize(res);
    }

    printLocation(){
        return this.controls.printLocation();
    }



}


export default PathTracer;
