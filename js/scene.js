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
        let accScene, dispScene,combineScene;
        let accMaterial, dispMaterial,combineMaterial;



        //Build Accumulation Scene
        //=============================================

        async function buildAccShader() {

            let newShader = '';


            const shaders = [] = [
                {
                    file: '../glsl/accShader/01setup.glsl'
                },
                {
                    file: '../glsl/accShader/02random.glsl'
                },
                {
                    file: '../glsl/accShader/03spectral.glsl'
                },
                {
                    file: '../glsl/accShader/04geometry.glsl'
                },
                {
                    //NEW
                    file: '../glsl/newFrame/2Geometry/camera.glsl'
                },
                {
                    file: '../glsl/accShader/05materials.glsl'
                },
                {
                    file: '../glsl/accShader/06path.glsl'
                },
                {
                    file: '../glsl/accShader/07BSDF.glsl'
                },
                {
                    //NEW
                    file: '../glsl/newFrame/3Renderer/Basic/update.glsl'
                },
                {
                    file: '../glsl/accShader/08distanceFields.glsl'
                },
                {
                    file: '../glsl/accShader/09basicObjects.glsl'
                },
                {
                    file: '../glsl/accShader/10compoundObjects.glsl'
                },
                {
                    file: '../glsl/accShader/11scene.glsl'
                },
                {
                    //NEW
                    file: '../glsl/newFrame/6Trace/raymarch.glsl'
                },
                {
                    //NEW
                    file: '../glsl/newFrame/6Trace/pathTrace.glsl'
                },
                {
                    //NEW
                    file: '../glsl/newFrame/main.glsl'
                },
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




        async function createAccScene() {

            //make the actual scene, and the buffer Scene
            accScene = new THREE.Scene();

            //make the plane we will add to both scenes
            const accPlane = new THREE.PlaneBufferGeometry(2, 2);

            accMaterial = new THREE.ShaderMaterial({
                fragmentShader: await buildAccShader(),
                uniforms: newFrameUniforms,
            });

            accScene.add(new THREE.Mesh(accPlane, accMaterial));

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

            await createAccScene();

            await createCombineScene();

            await createDispScene();


        }




        export {
            accMaterial,
            combineMaterial,
            dispMaterial,
            accScene,
            combineScene,
            dispScene,
            buildScenes,
        }
