import {
    OrthographicCamera,
    BufferGeometry,
    Float32BufferAttribute,
    Mesh,
    ShaderMaterial, Scene, RGBAFormat, FloatType, ClampToEdgeWrapping, NearestFilter, WebGLRenderTarget,
    Vector3,
} from "./libs/three.module.js";


const _geometry = new BufferGeometry();
_geometry.setAttribute( 'position', new Float32BufferAttribute( [ - 1, 3, 0, - 1, - 1, 0, 3, - 1, 0 ], 3 ) );
_geometry.setAttribute( 'uv', new Float32BufferAttribute( [ 0, 2, 0, 0, 2, 0 ], 2 ) );


const rtSettings = {
    format:  RGBAFormat,
    type:  FloatType,
    wrapS: ClampToEdgeWrapping,
    wrapT: ClampToEdgeWrapping,
    minFilter: NearestFilter,
    magFilter: NearestFilter,
    depthBuffer: false,
    stencilBuffer:  false,
};


class ComputeShader {
    //data is an object of the form {shader: text, uniforms: list}
    constructor( data, renderer, res = {x:window.innerWidth,y:window.innerHeight} ) {

        this.res=res;

        this.renderer = renderer;
        this.uniforms = data.uniforms;
        this.shader = data.shader;

        this.material = new ShaderMaterial({
            uniforms: this.uniforms,
            fragmentShader: this.shader,
        } );
        this.mesh = new Mesh( _geometry, this.material );

        this.scene = new Scene();
        this.scene.add(this.mesh);
        this.camera = new OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );

        this.a = new WebGLRenderTarget(this.res.x,this.res.y, rtSettings);
        this.b = new WebGLRenderTarget(this.res.x,this.res.y, rtSettings);
        this.data = null;

        this.updateUniforms({iResolution: new Vector3(this.res.x,this.res.y, 0.) });
    }

    rtSwap(){
        //swap the render targets
        let temp = this.a;
        this.a = this.b;
        this.b = temp;
    }

    render( ) {
        this.renderer.setRenderTarget(this.a);
        this.renderer.render( this.scene, this.camera );
        this.rtSwap();
        this.data = this.b.texture;
        this.renderer.setRenderTarget(null);
    }

    renderToScreen( ){
        this.renderer.setRenderTarget(null);
        this.renderer.render(this.scene, this.camera);
    }

    getData(){
        return this.data;
    }

    updateUniforms(obj){
        for (const [key, value] of Object.entries(obj)) {
            this.material.uniforms[key].value = value;
        }
    }

    setSize(res){
        this.res=res;
        this.a.setSize(res.x,res.y);
        this.b.setSize(res.x,res.y);
        this.updateUniforms({iResolution: new Vector3(res.x,res.y, 0.) });
    }


}


export default ComputeShader;
