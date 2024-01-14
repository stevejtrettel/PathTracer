        //Import Stuff
        //=============================================
        import * as THREE from './libs/three.module.js';

        import{
            newFrameUniforms,
            combineUniforms,
            displayUniforms,
        } from "./uniforms.js";


        //Scene Variables
        //=============================================


        // things for building display and accumulation scenes
        let newFrameScene, dispScene,combineScene;
        let newFrameMaterial, dispMaterial,combineMaterial;



        //Build Accumulation Scene
        //=============================================

        async function buildNewFrameShader() {

            let newShader = '';


            const shaders = [] = [
                {file: '../glsl/newFrame/1Setup/uniforms.glsl'},
                {file: '../glsl/newFrame/1Setup/math.glsl'},
                {file: '../glsl/newFrame/1Setup/random.glsl'},
                {file: '../glsl/newFrame/1Setup/sky.glsl'},
                {file: '../glsl/newFrame/2Space/geometry.glsl'},
                {file: '../glsl/newFrame/2Space/physics.glsl'},
                {file: '../glsl/newFrame/2Space/camera.glsl'},
                {file: '../glsl/newFrame/3Materials/material.glsl'},
                {file: '../glsl/newFrame/3Materials/path.glsl'},
                {file: '../glsl/newFrame/3Materials/setImpactData.glsl'},
                {file: '../glsl/newFrame/3Materials/scatterPath.glsl'},
                {file: '../glsl/newFrame/3Materials/updatePath.glsl'},
                {file: '../glsl/newFrame/4Objects/computations.glsl'},
                {file: '../glsl/newFrame/4Objects/simple/shapes.glsl'},
                {file: '../glsl/newFrame/4Objects/simple/varieties.glsl'},
                {file: '../glsl/newFrame/4Objects/simple/fractals.glsl'},
                {file: '../glsl/newFrame/4Objects/simple/polytope.glsl'},
                {file: '../glsl/newFrame/4Objects/compound/compoundObjects.glsl'},
                {file: '../glsl/newFrame/4Objects/compound/multiMatObjects.glsl'},
                {file: '../glsl/newFrame/4Objects/sample.glsl'},
                {file: '../glsl/newFrame/5Scene/walls.glsl'},
                {file: '../glsl/newFrame/5Scene/lights.glsl'},
                {file: '../glsl/newFrame/5Scene/objects.glsl'},
                {file: '../glsl/newFrame/5Scene/scene.glsl'},
                {file: '../glsl/newFrame/6Trace/raymarch.glsl'},
                {file: '../glsl/newFrame/6Trace/raytrace.glsl'},
                {file: '../glsl/newFrame/6Trace/sampleLight.glsl'},
                {file: '../glsl/newFrame/6Trace/subSurfScatter.glsl'},
                {file: '../glsl/newFrame/6Trace/stepForward.glsl'},
                {file: '../glsl/newFrame/6Trace/pathTrace.glsl'},
                {file: '../glsl/newFrame/main.glsl'},
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




        async function createNewFrameScene() {

            //make the actual scene, and the buffer Scene
            newFrameScene = new THREE.Scene();

            //make the plane we will add to both scenes
            const newFramePlane = new THREE.PlaneBufferGeometry(2, 2);

            newFrameMaterial = new THREE.ShaderMaterial({
                fragmentShader: await buildNewFrameShader(),
                uniforms: newFrameUniforms,
            });

            newFrameScene.add(new THREE.Mesh(newFramePlane, newFrameMaterial));

        }




        //Build Combine Scene
        //=============================================

        async function createCombineScene() {

            //build the shader
            const combineText = await fetch('../glsl/combine/combine.glsl');

            //make the actual scene, and the buffer Scene
            combineScene = new THREE.Scene();


            //make the plane we will add to both scenes
            const combinePlane = new THREE.PlaneBufferGeometry(2, 2);


            combineMaterial = new THREE.ShaderMaterial({
                fragmentShader: await combineText.text(),
                uniforms: combineUniforms,
            });

            combineScene.add(new THREE.Mesh(combinePlane, combineMaterial));
        }



        //Build Display Scene
        //=============================================

        async function createDispScene() {

            //build the shader
            const dispText = await fetch('../glsl/display/display.glsl');

            //make the actual scene, and the buffer Scene
            dispScene = new THREE.Scene();


            //make the plane we will add to both scenes
            const dispPlane = new THREE.PlaneBufferGeometry(2, 2);


            dispMaterial = new THREE.ShaderMaterial({
                fragmentShader: await dispText.text(),
                uniforms: displayUniforms,
            });

            dispScene.add(new THREE.Mesh(dispPlane, dispMaterial));

        }



        //Functions to Export
        //=============================================


        //run one time to set things up
        async function buildScenes() {

            await createNewFrameScene();

            await createCombineScene();

            await createDispScene();


        }




        export {
            newFrameMaterial,
            combineMaterial,
            dispMaterial,
            newFrameScene,
            combineScene,
            dispScene,
            buildScenes,
        }
