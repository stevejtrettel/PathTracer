import {Vector3} from "./math/index.js";
import {showShaderError} from "./gui/ErrorOverlay.js";


//-------------------------------------------------
// COMPUTE SHADER  (raw WebGL2)
//-------------------------------------------------
// Runs a fragment shader over a fullscreen triangle into a float render target,
// ping-ponging two targets so a pass can read its own previous output. This is
// the whole GPGPU core — no three.js. The public interface is preserved exactly
// so PathTracer/UI are unchanged:
//   material.uniforms[name].value   (read/written directly by callers)
//   render() renderToScreen() getData() updateUniforms(obj) setSize(res)
//
// The shaders are written to three's old ABI (gl_FragColor, no #version), so the
// compile step prepends a header and rewrites those tokens (see shimFragment) —
// the .glsl files themselves are never edited.


// fullscreen triangle from gl_VertexID; fragments use gl_FragCoord (no varyings)
const VERT_SRC = `#version 300 es
void main(){
    vec2 p = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
}`;

const FRAG_PREFIX = `#version 300 es
precision highp float;
precision highp int;
out vec4 pc_fragColor;
`;

// three's ABI shim: header + gl_FragColor -> our out var, texture2D -> texture
function shimFragment(src){
    return FRAG_PREFIX + src
        .replace(/\bgl_FragColor\b/g, 'pc_fragColor')
        .replace(/\btexture2D\b/g, 'texture');
}

// per-gl shared resources (the vertex shader + an empty VAO), built once
const glShared = new WeakMap();
function shared(gl){
    let s = glShared.get(gl);
    if(!s){
        let vs = gl.createShader(gl.VERTEX_SHADER);
        gl.shaderSource(vs, VERT_SRC);
        gl.compileShader(vs);
        s = { vs, vao: gl.createVertexArray() };
        glShared.set(gl, s);
    }
    return s;
}


class ComputeShader {
    //data = { shader: fragmentSource, uniforms: {name:{value}} }
    constructor(data, gl, res = {x: window.innerWidth, y: window.innerHeight}){
        this.gl  = gl;
        this.res = res;

        //preserve the external interface: material.uniforms = {name:{value}}
        this.material = { uniforms: {} };
        for(let name in data.uniforms){
            this.material.uniforms[name] = { value: data.uniforms[name].value };
        }

        this.program = this._buildProgram(data.shader);
        this._cacheUniforms();

        //two float render targets, ping-ponged (see render())
        this.a = this._makeTarget(res.x, res.y);
        this.b = this._makeTarget(res.x, res.y);
        this.data = this.b.tex;

        this.updateUniforms({ iResolution: new Vector3(res.x, res.y, 0.) });
    }

    _buildProgram(fragSrc){
        let gl = this.gl;
        let vs = shared(gl).vs;
        let fs = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(fs, shimFragment(fragSrc));
        gl.compileShader(fs);

        let program = gl.createProgram();
        gl.attachShader(program, vs);
        gl.attachShader(program, fs);
        gl.linkProgram(program);

        //surface GLSL errors on-screen (was three's renderer.debug.onShaderError)
        if(!gl.getProgramParameter(program, gl.LINK_STATUS)){
            showShaderError(gl, program, vs, fs);
        }
        return program;
    }

    //cache location + GL type for every active uniform (+ a texture unit per
    //sampler). The GL type then drives the setter — no hand-maintained table.
    _cacheUniforms(){
        let gl = this.gl;
        this.uniforms = {};
        let count = gl.getProgramParameter(this.program, gl.ACTIVE_UNIFORMS);
        let unit = 0;
        for(let i = 0; i < count; i++){
            let info = gl.getActiveUniform(this.program, i);
            if(!info) continue;
            let name = info.name.replace(/\[0\]$/, '');
            let entry = { loc: gl.getUniformLocation(this.program, name), type: info.type };
            if(info.type === gl.SAMPLER_2D) entry.unit = unit++;
            this.uniforms[name] = entry;
        }
    }

    //a float (RGBA32F) render target: texture + framebuffer. Nearest / clamp.
    _makeTarget(w, h){
        let gl = this.gl;
        let tex = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, tex);
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA32F, w, h, 0, gl.RGBA, gl.FLOAT, null);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        let fbo = gl.createFramebuffer();
        gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
        gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, tex, 0);
        gl.bindFramebuffer(gl.FRAMEBUFFER, null);
        return { tex, fbo, w, h };
    }

    updateUniforms(obj){
        for(let key in obj){
            if(this.material.uniforms[key]) this.material.uniforms[key].value = obj[key];
            else this.material.uniforms[key] = { value: obj[key] };
        }
    }

    //set every uniform we have a value for, dispatched on its cached GL type
    _applyUniforms(){
        let gl = this.gl;
        for(let name in this.material.uniforms){
            let u = this.uniforms[name];
            if(!u || u.loc === null) continue;          //not an active uniform
            let v = this.material.uniforms[name].value;
            switch(u.type){
                case gl.FLOAT:      gl.uniform1f(u.loc, v); break;
                case gl.INT:        gl.uniform1i(u.loc, v); break;
                case gl.BOOL:       gl.uniform1i(u.loc, v ? 1 : 0); break;
                case gl.FLOAT_VEC2: gl.uniform2f(u.loc, v.x, v.y); break;
                case gl.FLOAT_VEC3: gl.uniform3f(u.loc, v.x, v.y, v.z); break;
                case gl.FLOAT_MAT3: gl.uniformMatrix3fv(u.loc, false, v.elements); break;
                case gl.FLOAT_MAT4: gl.uniformMatrix4fv(u.loc, false, v.elements); break;
                case gl.SAMPLER_2D:
                    gl.activeTexture(gl.TEXTURE0 + u.unit);
                    gl.bindTexture(gl.TEXTURE_2D, v || null);
                    gl.uniform1i(u.loc, u.unit);
                    break;
            }
        }
    }

    _draw(fbo, w, h){
        let gl = this.gl;
        gl.useProgram(this.program);
        gl.bindVertexArray(shared(gl).vao);
        gl.bindFramebuffer(gl.FRAMEBUFFER, fbo);
        gl.viewport(0, 0, w, h);
        this._applyUniforms();
        gl.drawArrays(gl.TRIANGLES, 0, 3);
        gl.bindVertexArray(null);
    }

    //render into a target, then swap so getData() returns the just-drawn texture
    //(and the next render writes the OTHER target — a pass can read its own last
    //output without a read/write feedback loop)
    render(){
        this._draw(this.a.fbo, this.a.w, this.a.h);
        let t = this.a; this.a = this.b; this.b = t;
        this.data = this.b.tex;
    }

    renderToScreen(){
        this._draw(null, this.gl.canvas.width, this.gl.canvas.height);
    }

    getData(){ return this.data; }

    setSize(res){
        let gl = this.gl;
        this.res = res;
        for(let t of [this.a, this.b]){
            gl.bindTexture(gl.TEXTURE_2D, t.tex);
            gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA32F, res.x, res.y, 0, gl.RGBA, gl.FLOAT, null);
            t.w = res.x; t.h = res.y;
        }
        this.updateUniforms({ iResolution: new Vector3(res.x, res.y, 0.) });
    }
}


export default ComputeShader;
