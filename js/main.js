        //Import Stuff
        //=============================================
        import * as THREE from './libs/three.module.js';


        import Stats from './libs/stats.module.js';



        //Import My Own Stuff
        //=============================================
        import {
            accMaterial,
            dispMaterial,
            accScene,
            dispScene,
            buildScenes,
            updateUniforms
        } from './scene.js'




        //Global Variables
        //=============================================

        let camera, renderer, controls;
        let container, canvas;
        let stats;

        //textures for accumulating frames
        let readTex, writeTex, tempTex;









        //Creating Basic Components
        //=============================================


        function createStats(type) {

            var panelType = (typeof type !== 'undefined' && type) && (!isNaN(type)) ? parseInt(type) : 0;
            var stats = new Stats();

            stats.showPanel(panelType); // 0: fps, 1: ms, 2: mb, 3+: custom
            document.body.appendChild(stats.dom);

            return stats;
        }





        function createRenderer() {
            renderer = new THREE.WebGLRenderer({
                canvas
            });
            renderer.autoClearColor = false;


            // set the gamma correction so that output colors look
            // correct on our screens
            //            renderer.gammaFactor = 2.2;
            //            renderer.gammaOutput = true;
            //            renderer.physicallyCorrectLights = true;
            //            //            // tone mapping
            //                        renderer.toneMapping = THREE.NoToneMapping;
            //                        renderer.outputEncoding = THREE.sRGBEncoding;
            //
            //            renderer.setPixelRatio(window.devicePixelRatio);

            //renderer.setPixelRatio(window.devicePixelRatio);
            renderer.setSize(window.innerWidth, window.innerHeight);
        }


        function createCamera() {

            //make the one camera we will use for both renders
            camera = new THREE.OrthographicCamera(
                -1, // left
                1, // right
                1, // top
                -1, // bottom
                -1, // near,
                1, // far
            );

        }




        function createFrameBuffers(canvas) {
            //make the two textures we will render to\
            //make it canvas sized
            readTex = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight);

            writeTex = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight);

        }



        function resizeToDisplay() {
            //            canvas = renderer.domElement;
            //            const width = canvas.clientWidth;
            //            const height = canvas.clientHeight;
            //            const needResize = canvas.width !== width || canvas.height !== height;
            //            if (needResize) {
            //                // renderer.setPixelRatio(window.devicePixelRatio);
            //                renderer.setSize(window.innerWidth, window.innerHeight);
            //
            //                //make rendrr targets same size as screen
            //                readTex.setSize(window.innerWidth, window.innerHeight);
            //                writeTex.setSize(window.innerWidth, window.innerHeight);
            //                //reset the count so that the new size begins new render
            //                accMaterial.uniforms.iFrame.value = 0.;
            //            }
            // return needResize;
        }









        //The Main Functions
        //=============================================




        function render() {

            //render to the texture B
            renderer.setRenderTarget(writeTex);
            renderer.render(accScene, camera);

            // swap the read and write buffers
            tempTex = readTex;
            readTex = writeTex;
            writeTex = tempTex;

            //read off the new frame from readTex
            //set this as the acc uniform for the displayMaterial
            accMaterial.uniforms.acc.value = readTex.texture;
            dispMaterial.uniforms.acc.value = readTex.texture;


            //make the next move render to canvas
            renderer.setRenderTarget(null);

            //render the actual scene to the camera using this
            renderer.render(dispScene, camera);

        }




        function animate() {

            requestAnimationFrame(animate);

            stats.begin();

            //resizeToDisplay();
            updateUniforms(canvas);
            console.log(accMaterial.uniforms.iFrame.value);
            render();

            stats.end();

        }





        async function main() {

            //set the canvas
            canvas = document.querySelector('#c');

            stats = createStats();

            createRenderer();

            createCamera();

            await buildScenes();

            createFrameBuffers(canvas);

            animate();

        }






        //Actually Running Things
        //=============================================

        main();
