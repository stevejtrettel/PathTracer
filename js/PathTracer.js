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

        //live-view render scale (Render tab: Full/Half/Quarter). Lives here, not
        //in the UI, so that resize() — including the one that ends an HD render —
        //keeps it.
        this.viewScale = 1;

        //true while an HD render is in progress: locks the inputs that would
        //restart accumulation (camera keys + GUI knobs) so a stray touch can't
        //wreck a long tiled export. Live-view tweaking is unaffected.
        this.rendering = false;

        //raw WebGL2 canvas + context. preserveDrawingBuffer keeps toDataURL
        //working for saveImage; float render targets need EXT_color_buffer_float.
        this.canvas = document.createElement('canvas');
        this.gl = this.canvas.getContext('webgl2', {preserveDrawingBuffer: true});
        if(!this.gl || !this.gl.getExtension('EXT_color_buffer_float')){
            const msg = !this.gl
                ? 'WebGL2 is not available in this browser.'
                : 'float render targets (EXT_color_buffer_float) are not supported.';
            const div = document.createElement('div');
            div.style.cssText = 'position:fixed;inset:0;display:grid;place-items:center;background:#111;color:#eee;font:16px system-ui;z-index:99';
            div.textContent = 'PathTracer cannot start: ' + msg;
            document.body.appendChild(div);
            throw new Error(msg);
        }
        document.body.appendChild(this.canvas);
        this.maxTextureSize = this.gl.getParameter(this.gl.MAX_TEXTURE_SIZE);
        this.size = res;
        this._setCanvasSize(res);

        //the control system
        this.controls = new KeyControls(this.settings.location);

        //the shaders
        //(render targets: the tracer's output is only read by accumulate -> 1;
        //accumulate reads its own last frame -> 2; display draws to the screen -> 0.
        //At a 4000px HD tile each RGBA32F target is ~180MB, so this matters.)
        this.tracer = new ComputeShader(shaders.tracer, this.gl, res, 1);
        this.accumulate = new ComputeShader(shaders.accumulate, this.gl, res, 2);
        this.display = new ComputeShader(shaders.display, this.gl, res, 0);

        //the sky sampler needs a real texture; the uniforms were assembled before
        //the gl context existed, so build it here from the scene's sky descriptor
        //(1x1 white until an image loads — see buildSky / _makeSkyTexture).
        this.tracer.updateUniforms({sky: this._makeSkyTexture(shaders.tracer.sky)});

        //mouse orbit (adapted from the PathTracerGLSL repo): drag orbits the
        //look-point, pinch dollies. Writes the same position/facing the keyboard
        //uses, so the two compose. Suspended during an HD render (the lock).
        //the shader shifts every camera by the legacy CAMERA_OFFSET
        //(glsl/tracer/2Space/camera.glsl); subtract it here so the orbit
        //pivot's VISUAL location is the scene target (the origin by default)
        const CAMERA_OFFSET = [-2, 0, 6];
        const target = (this.settings.target ?? [0, 0, 0]).map((t, i) => t - CAMERA_OFFSET[i]);

        this.orbitEnabled = true;
        this.orbit = new OrbitControls(this.canvas, this.controls, {
            onChange: () => { this.tracer.updateUniforms({facing: this.controls.facing, location: this.controls.position}); this.reset(); },
            target:   target,
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
    //and replaces it (flipY, mipmaps, trilinear filtering, RGBA8 with no sRGB
    //decode — the shader does its own SRGBToLinear), then restarts accumulation.
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
            img.onerror = () => console.error('sky image failed to load: ' + desc.src);
            img.src = desc.src;
        }
        return tex;
    }

    //samples accumulated so far (the tracer's frame counter)
    get frameCount(){
        return this.tracer.material.uniforms.frameNumber.value;
    }

    //per-frame bookkeeping: advance the frame counters and poll the keyboard
    tick(){
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

        this.tick();

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
            if(this.frameCount % this.autoSaveSPP == 0){
                this.saveImage();
            }
        }

        //HD tile render: render each tile to `spp` samples, save it, advance;
        //restore the view size when the whole grid is done (see startHDRender)
        if(this.hd && this.hd.active){
            let hd = this.hd;
            let pr = this.tracer.material.uniforms.panelToRender.value;
            if(pr < hd.stopAfter){
                if(this.frameCount >= hd.spp){
                    //the shader lays panel pr out at x = floor(pr/root) from the LEFT
                    //and y = pr % root from the BOTTOM (camera.glsl panelFragCoord);
                    //name tiles by row from the TOP and column from the left, the
                    //way they are stitched
                    let col = Math.floor(pr / hd.root), row = hd.root - 1 - (pr % hd.root);
                    let saved = this.saveImage(`hd_${hd.spp}spp_${hd.root}x${hd.root}_r${row}c${col}`);
                    hd.tiles.push(saved.then((blob) => ({row, col, blob})));
                    this.tracer.material.uniforms.panelToRender.value = pr + 1;
                    this.reset();
                }
            } else {
                //a whole grid (not a one-tile re-render) also gets stitched
                if(hd.stopAfter === hd.N && hd.start === 0 && hd.N > 1){ this._stitchHD(hd); }
                this.stopHDRender();
            }
        }
    }

    reset(){
        this.tracer.updateUniforms({frameNumber:0});
        this.accumulate.updateUniforms({frameNumber:0});
    }


    //download the canvas as <label>.png (default: spp + timestamp). Returns a
    //promise of the PNG blob. toBlob snapshots the canvas now and encodes off the
    //main thread — unlike toDataURL, which blocks and builds a huge string at HD
    //tile sizes.
    saveImage(label){

        let name = label;
        if(!name){
            const date = new Date();
            let day = date.getDate();
            let month = date.getMonth() + 1;
            let hour = String(date.getHours()).padStart(2, '0');
            let minute = String(date.getMinutes()).padStart(2, '0');
            name = `${this.frameCount}spp pathtrace ${month}-${day}-${hour}${minute}`;
        }

        return new Promise((resolve) => {
            this.canvas.toBlob((blob) => {
                if(!blob){ console.error(`saveImage: could not encode ${name}.png`); resolve(null); return; }
                downloadBlob(blob, name + '.png');
                resolve(blob);
            }, 'image/png');
        });
    }


    //assemble the saved tiles of a finished HD render into the full image and
    //download it too. The tiles are already on disk, so if this fails (browsers
    //cap a canvas at ~16k px a side / ~268M px) nothing is lost but convenience.
    async _stitchHD(hd){
        try {
            let tiles = (await Promise.all(hd.tiles)).filter((t) => t.blob);
            let canvas = document.createElement('canvas');
            canvas.width  = hd.root * hd.tileW;
            canvas.height = hd.root * hd.tileH;
            let g = canvas.getContext('2d');
            if(!g) throw new Error(`a ${canvas.width}×${canvas.height} canvas is too large for this browser`);
            for(let t of tiles){
                let bmp = await createImageBitmap(t.blob);
                g.drawImage(bmp, t.col * hd.tileW, t.row * hd.tileH);
                bmp.close();
            }
            let blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/png'));
            if(!blob) throw new Error(`could not encode a ${canvas.width}×${canvas.height} image`);
            downloadBlob(blob, `hd_${hd.spp}spp_${canvas.width}x${canvas.height}.png`);
        } catch(err){
            console.error(`HD stitch failed (the tiles themselves were saved): ${err.message ?? err}`);
        }
    }


    //plan a square √N tiling of a finalW×finalH image so each tile is <= maxTile
    //and (when possible) >= minTile. Tiles share the final image's aspect ratio.
    planHD(finalW, finalH, maxTile=4000, minTile=1000){
        //Max Tile comes from a free number field: 0 / negative / NaN made root
        //infinite (and the loop below never ended). A tile can't exceed the GPU's
        //texture limit either.
        if(!(maxTile > 0)) maxTile = 4000;
        maxTile = Math.min(maxTile, this.maxTextureSize);
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
        if(this.rendering) return;   //re-entry would clobber hdRestore with the tile size
        //the inputs come from free number fields
        finalW = Math.max(1, Math.round(finalW) || 1);
        finalH = Math.max(1, Math.round(finalH) || 1);
        spp    = Math.max(1, Math.round(spp) || 1);
        let plan = this.planHD(finalW, finalH, opts.maxTile);
        let start = (opts.tile != null) ? Math.min(Math.max(Math.round(opts.tile) || 0, 0), plan.N - 1) : 0;

        //remember the current view size, to restore when the render finishes
        this.hdRestore = {x: this.size.x, y: this.size.y};

        //(set before resize: tiles always render at full scale, see resize)
        this.rendering = true;
        this.resize({x: plan.tileW, y: plan.tileH});
        this.tracer.updateUniforms({numPanels: plan.N, panelToRender: start, renderPanel: true});
        this.reset();

        this.hd = {
            active:    true,
            root:      plan.root,
            N:         plan.N,
            tileW:     plan.tileW,
            tileH:     plan.tileH,
            spp:       spp,
            start:     start,
            stopAfter: (opts.tile != null) ? start + 1 : plan.N,
            tiles:     [],   //promises of {row, col, blob}, for the stitch
        };
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

    //res is the canvas size. The live view may trace at a fraction of it
    //(Render tab Scale: the display stretches it up); HD tiles never do.
    resize(res){
        this.size = res;
        this._setCanvasSize(res);
        let s = this.rendering ? 1 : this.viewScale;
        let r = {x: Math.max(1, Math.floor(s * res.x)), y: Math.max(1, Math.floor(s * res.y))};
        this.tracer.setSize(r);
        this.accumulate.setSize(r);
        this.display.setSize(res);
    }

    printLocation(){
        return this.controls.printLocation();
    }



}


//trigger a browser download of a blob
function downloadBlob(blob, filename){
    let url = URL.createObjectURL(blob);
    let link = document.createElement('a');
    link.download = filename;
    link.href = url;
    link.click();
    //revoking straight away can cancel the download in some browsers
    setTimeout(() => URL.revokeObjectURL(url), 60000);
}


export default PathTracer;
