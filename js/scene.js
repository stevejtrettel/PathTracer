        //Import Stuff
        //=============================================
        import * as THREE from './libs/three.module.js';



        //Scene Variables
        //=============================================


        //background sky texture
        const skyTex = new THREE.TextureLoader().load('/js/tex/bk.jpg');

        // things for building display and accumulation scenes
        let accScene, dispScene;
        let accMaterial, dispMaterial;
        let accUniforms, dispUniforms;
        let accShader, dispShader;









        //Build Accumulation Scene
        //=============================================


        async function createAccShaderMat() {
            const accText = await fetch('../glsl/accShader.glsl');
            accShader = await accText.text();


            accUniforms = {
                iTime: {
                    value: 0
                },
                iResolution: {
                    value: new THREE.Vector3()
                },
                //frame number we are on
                iFrame: {
                    value: 0
                },
                sky: {
                    value: skyTex
                },
                //accumulated texture
                acc: {
                    value: null
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



        function updateAccUniforms(canvas) {

            accMaterial.uniforms.iResolution.value.set(canvas.width, canvas.height, 1);
            accMaterial.uniforms.iTime.value = 0;
            accMaterial.uniforms.iFrame.value += 1.;

        }







        //Build Display Scene
        //=============================================


        async function createDispShaderMat() {

            const dispText = await fetch('../glsl/dispShader.glsl');
            dispShader = await dispText.text();


            dispUniforms = {
                iTime: {
                    value: 0
                },
                iResolution: {
                    value: new THREE.Vector3()
                },
                //frame number we are on
                iFrame: {
                    value: 0
                },

                sky: {
                    value: skyTex
                },

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



        function updateDispUniforms(canvas) {

            dispMaterial.uniforms.iResolution.value.set(canvas.width, canvas.height, 1);
            dispMaterial.uniforms.iFrame.value += 1.;
            dispMaterial.uniforms.iTime.value = 0;

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
        function updateUniforms(canvas) {

            updateAccUniforms(canvas);
            updateDispUniforms(canvas);
        }



        export {
            accMaterial,
            dispMaterial,
            accScene,
            dispScene,
            buildScenes,
            updateUniforms
        }
