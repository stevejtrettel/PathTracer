        //Import Stuff
        //=============================================
        import * as THREE from './libs/three.module.js';

        import{
            newFrameUniforms,
            combineUniforms,
            displayUniforms,
        } from "./uniforms.js";

        import{ui} from "./ui.js";






        //Scene Variables
        //=============================================


        // things for building display and accumulation scenes
        let accScene, dispScene,combineScene;
        let accMaterial, dispMaterial,combineMaterial;
        let accShader, dispShader,combineShader;









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
                    file: '../glsl/accShader/05materials.glsl'
                },
                {
                    file: '../glsl/accShader/06path.glsl'
                },
                {
                    file: '../glsl/accShader/07BSDF.glsl'
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
                    file: '../glsl/accShader/12trace.glsl'
                },
                {
                    file: '../glsl/accShader/13render.glsl'
                },
                {
                    file: '../glsl/accShader/14accumulate.glsl'
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




        async function createAccShaderMat() {

            //OLD WAY: LOAD SINGLE SHADER
            //            const accText = await fetch('../glsl/accShader.glsl');
            //            accShader = await accText.text();
            //build the shader out of files

            //build the shader text
            accShader = await buildAccShader();
        }


        function createAccScene(accShader) {

            //make the actual scene, and the buffer Scene
            accScene = new THREE.Scene();

            //make the plane we will add to both scenes
            const accPlane = new THREE.PlaneBufferGeometry(2, 2);

            accMaterial = new THREE.ShaderMaterial({
                fragmentShader: accShader,
                uniforms: newFrameUniforms,
            });

            accScene.add(new THREE.Mesh(accPlane, accMaterial));

        }




        //Build Combine Scene
        //=============================================


        async function createCombineShaderMat() {
            const combineText = await fetch('../glsl/combine/combine.glsl');
            combineShader = await combineText.text();
        }



        function createCombineScene(combineShader) {


            //make the actual scene, and the buffer Scene
            combineScene = new THREE.Scene();


            //make the plane we will add to both scenes
            const combinePlane = new THREE.PlaneBufferGeometry(2, 2);


            combineMaterial = new THREE.ShaderMaterial({
                fragmentShader: combineShader,
                uniforms: combineUniforms,
            });


            combineScene.add(new THREE.Mesh(combinePlane, combineMaterial));


        }



        //Build Display Scene
        //=============================================


        async function createDispShaderMat() {
            const dispText = await fetch('../glsl/dispShader.glsl');
            dispShader = await dispText.text();
        }


        function createDispScene(dispShader) {

            //make the actual scene, and the buffer Scene
            dispScene = new THREE.Scene();


            //make the plane we will add to both scenes
            const dispPlane = new THREE.PlaneBufferGeometry(2, 2);


            dispMaterial = new THREE.ShaderMaterial({
                fragmentShader: dispShader,
                uniforms: displayUniforms,
            });

            dispScene.add(new THREE.Mesh(dispPlane, dispMaterial));

        }



        //Functions to Export
        //=============================================


        //run one time to set things up
        async function buildScenes() {

            await createAccShaderMat();

            createAccScene(accShader);

            await createCombineShaderMat();

            createCombineScene(combineShader);

            await createDispShaderMat();

            createDispScene(dispShader);


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
