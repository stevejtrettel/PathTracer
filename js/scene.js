        //Import Stuff
        //=============================================
        import * as THREE from './libs/three.module.js';

        import {
            rotControls,
            translControls
        } from './controls.js';


        //Scene Variables
        //=============================================


        //background sky texture
        const skyTex = new THREE.TextureLoader().load('/js/tex/bk.jpg');


        //background sky texture
        const skyTexSmall = new THREE.TextureLoader().load('/js/tex/bk_sm.jpg');



        // things for building display and accumulation scenes
        let accScene, dispScene;
        let accMaterial, dispMaterial;
        let accUniforms, dispUniforms;
        let accShader, dispShader;









        //Build Accumulation Scene
        //=============================================





        async function buildAccShader() {

            let newShader = '';


            const shaders = [] = [
                {
                    file: '../glsl/accShader/01setup.glsl'
                },
                {
                    file: '../glsl/accShader/02structs.glsl'
                },
                {
                    file: '../glsl/accShader/03sdfs.glsl'
                },
                {
                    file: '../glsl/accShader/04scene.glsl'
                },
                {
                    file: '../glsl/accShader/05trace.glsl'
                },
                {
                    file: '../glsl/accShader/06render.glsl'
                },
                {
                    file: '../glsl/accShader/07accumulate.glsl'
                }
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

            accUniforms = {
                iTime: {
                    value: 0
                },
                iResolution: {
                    value: new THREE.Vector3(window.innerWidth, window.innerHeight, 0.)
                },
                //frame number we are on
                iFrame: {
                    value: 0
                },
                sky: {
                    value: skyTex
                },
                skySM: {
                    value: skyTexSmall
                },
                //accumulated texture
                acc: {
                    value: null
                },
                facing: {
                    value: new THREE.Matrix3().identity()
                },
                location: {
                    value: new THREE.Vector3(0, 0, 0)
                },
                seed: {
                    value: 0
                }
            };

        }


        function createAccScene(accShader, accUniforms) {



            //make the actual scene, and the buffer Scene
            accScene = new THREE.Scene();

            //make the plane we will add to both scenes
            const accPlane = new THREE.PlaneBufferGeometry(2, 2);

            accMaterial = new THREE.ShaderMaterial({
                fragmentShader: accShader,
                uniforms: accUniforms,
            });

            accScene.add(new THREE.Mesh(accPlane, accMaterial));

        }



        function updateAccUniforms() {



            //  accMaterial.uniforms.iResolution.value.set(canvas.width, canvas.height, 1);
            //  accMaterial.uniforms.iResolution.value.set(window.innerWidth, window.innerHeight);
            accMaterial.uniforms.iTime.value = 0;
            accMaterial.uniforms.iFrame.value += 1.;
            accMaterial.uniforms.seed.value += 1.;

            let rotData = rotControls();
            let mat = rotData[0];
            let detectRot = rotData[1];

            let translData = translControls();
            let vec = translData[0];
            let detectTransl = translData[1];

            if (detectRot || detectTransl) {

                accMaterial.uniforms.facing.value.multiply(mat);

                accMaterial.uniforms.location.value.add(vec);

                accMaterial.uniforms.iFrame.value = 0.;
            }


        }







        //Build Display Scene
        //=============================================


        async function createDispShaderMat() {

            const dispText = await fetch('../glsl/dispShader.glsl');
            dispShader = await dispText.text();


            dispUniforms = {
                //                iTime: {
                //                    value: 0
                //                },
                iResolution: {
                    value: new THREE.Vector3(window.innerWidth, window.innerHeight, 0.)
                },
                //                //frame number we are on
                //                iFrame: {
                //                    value: 0
                //                },
                //raw display texture
                acc: {
                    value: null
                }
            };


        }



        function createDispScene(dispShader, dispUniforms) {


            //make the actual scene, and the buffer Scene
            dispScene = new THREE.Scene();


            //make the plane we will add to both scenes
            const dispPlane = new THREE.PlaneBufferGeometry(2, 2);


            dispMaterial = new THREE.ShaderMaterial({
                fragmentShader: dispShader,
                uniforms: dispUniforms,
            });


            dispScene.add(new THREE.Mesh(dispPlane, dispMaterial));


        }



        function updateDispUniforms() {

            //dispMaterial.uniforms.iResolution.value.set(canvas.width, canvas.height, 1);
            // dispMaterial.uniforms.iResolution.value.set(window.innerWidth, window.innerHeight);
            //dispMaterial.uniforms.iFrame.value += 1.;
            //dispMaterial.uniforms.iTime.value = 0;

        }




        //Functions to Export
        //=============================================


        //run one time to set things up
        async function buildScenes() {

            await createAccShaderMat();

            createAccScene(accShader, accUniforms);

            await createDispShaderMat();

            createDispScene(dispShader, dispUniforms);

        }


        //updates materials each time a frame runs: resizing canvas if necessary
        function updateUniforms() {
            updateAccUniforms();
            updateDispUniforms();
        }



        export {
            accMaterial,
            dispMaterial,
            accScene,
            dispScene,
            buildScenes,
            updateUniforms
        }
