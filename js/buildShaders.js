import * as THREE from "./libs/OLDthree.module.js";

//Scene Variables
//=============================================

//background sky texture
const skyTex = new THREE.TextureLoader().load('/js/tex/office.jpg');
//background sky texture
const skyTexSmall = new THREE.TextureLoader().load('/js/tex/office.jpg');



async function buildComputeShader() {

    let newShader = '';

    const shaders = [] = [
        {file: '../glsl/compute/1Setup/uniforms.glsl'},
        {file: '../glsl/compute/1Setup/math.glsl'},
        {file: '../glsl/compute/1Setup/random.glsl'},
        {file: '../glsl/compute/1Setup/sky.glsl'},
        {file: '../glsl/compute/2Space/geometry.glsl'},
        {file: '../glsl/compute/2Space/physics.glsl'},
        {file: '../glsl/compute/2Space/camera.glsl'},
        {file: '../glsl/compute/3Materials/material.glsl'},
        {file: '../glsl/compute/3Materials/path.glsl'},
        {file: '../glsl/compute/3Materials/setImpactData.glsl'},
        {file: '../glsl/compute/3Materials/scatterPath.glsl'},
        {file: '../glsl/compute/3Materials/updatePath.glsl'},
        {file: '../glsl/compute/4Objects/computations.glsl'},
        {file: '../glsl/compute/4Objects/simple/shapes.glsl'},
        {file: '../glsl/compute/4Objects/simple/varieties.glsl'},
        {file: '../glsl/compute/4Objects/simple/fractals.glsl'},
        {file: '../glsl/compute/4Objects/simple/polytope.glsl'},
        {file: '../glsl/compute/4Objects/compound/compoundObjects.glsl'},
        {file: '../glsl/compute/4Objects/compound/multiMatObjects.glsl'},
        {file: '../glsl/compute/5Scene/walls.glsl'},
        {file: '../glsl/compute/5Scene/lights.glsl'},
        {file: '../glsl/compute/5Scene/objects.glsl'},
        {file: '../glsl/compute/5Scene/scene.glsl'},
        {file: '../glsl/compute/6Trace/raymarch.glsl'},
        {file: '../glsl/compute/6Trace/raytrace.glsl'},
        {file: '../glsl/compute/6Trace/subSurfScatter.glsl'},
        {file: '../glsl/compute/6Trace/stepForward.glsl'},
        {file: '../glsl/compute/6Trace/pathTrace.glsl'},
        {file: '../glsl/compute/main.glsl'},
    ];

    //loop over the list of files
    let response, text;
    for (const shader of shaders) {
        response = await fetch(shader.file);
        text = await response.text();
        newShader = newShader + text;
    }

    return newShader;
}


let computeUniforms={
    iResolution: {
        value: new THREE.Vector3(window.innerWidth, window.innerHeight, 0.)
    },
    sky: {
        value: skyTex
    },
    skySM: {
        value: skyTexSmall
    },
    facing: {
        value: new THREE.Matrix3().identity()
    },
    location: {
        value: new THREE.Vector3(0, 0, 0)
    },
    frameSeed: {
        value: 0
    },

    aperture: {
        value: 0.0
    },
    focalLength: {
        value: 5.
    },
    brightness: {
        value: 1.
    },
    focusHelp: {
        value: false
    },
    fov: {
        value: 50
    },
    extra: {
        value: 0.5
    },
    extra2: {
        value: 0.5
    },
    extra3: {
        value: 0.5
    },
    extra4: {
        value: 0.5
    },
};






async function buildAccumulateShader() {
    let response = await fetch('../glsl/accumulate/combine.glsl');
    let text = await response.text();
    return text;
}

async function buildDisplayShader() {
    let response = await fetch('../glsl/display/display.glsl');
    let text = await response.text();
    return text;
}






async function buildShaders() {

    //return the shaders sorted by type, and with their shader text and uniforms ready to go.
    return {
        compute: {
            shader: await buildComputeShader(),
            uniforms: computeUniforms,
        },

        accumulate: {
            shader:  await buildAccumulateShader(),
            uniforms: {
                frameNumber: {
                    value: 0
                },
                iResolution: {
                    value: new THREE.Vector3(window.innerWidth, window.innerHeight, 0.)
                },
                acc: {
                    value: null
                },
                new: {
                    value: null
                }
            },
        },

        display: {
            shader: await buildDisplayShader(),
            uniforms: {
                iResolution: {
                    value: new THREE.Vector3(window.innerWidth, window.innerHeight, 0.)
                },
                acc: {
                    value: null
                }
            }
        }
    };
}


export default buildShaders;