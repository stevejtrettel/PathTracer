        //Import Stuff
        //=============================================
        import * as THREE from './libs/three.module.js';


        import Stats from './libs/stats.module.js';



        //Import My Own Stuff
        //=============================================
        import {
            accMaterial,
            combineMaterial,
            dispMaterial,
            accScene,
            combineScene,
            dispScene,
            buildScenes,
        } from './scene.js';

        import{
            updateUniforms
        } from "./uniforms.js";

        import {
            keyDownHandler,
            keyUpHandler
        } from './controls.js';

        import {
            ui,
            createUI
        } from './ui.js';




        //Global Variables
        //=============================================

        let camera, renderer, controls;
        let container, canvas;
        let stats;

        //textures for accumulating frames
        let readTex, writeTex, tempTex;
        let texA,texB;






        //Keyboard Controls
        //=============================================







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
                canvas,
                alpha: true,
                //  premultipliedAlpha: true,
                //  preserveDrawingBuffer: true,
                depth: false,
                stencil: false
            });

            // set the gamma correction so that output colors look
            // correct on our screens
            //renderer.gammaFactor = 1.;
            renderer.outputEncoding = THREE.LinearEncoding;
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




        function createFrameBuffers() {
            //make the two textures we will render to\
            //make it canvas sized
            readTex = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight, {
                //IMPORTANT! MAKE SURE IT READS OUT FLOATS
                type: THREE.FloatType,
                format: THREE.RGBAFormat,
            });

            writeTex = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight, {
                //IMPORTANT! MAKE SURE IT READS OUT FLOATS
                type: THREE.FloatType,
                format: THREE.RGBAFormat,
            });

            texA = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight, {
                //IMPORTANT! MAKE SURE IT READS OUT FLOATS
                type: THREE.FloatType,
                format: THREE.RGBAFormat,
            });

            texB = new THREE.WebGLRenderTarget(window.innerWidth, window.innerHeight, {
                //IMPORTANT! MAKE SURE IT READS OUT FLOATS
                type: THREE.FloatType,
                format: THREE.RGBAFormat,
            });

            // writeTex.texture.encoding = THREE.LinearEncoding;
            // readTex.texture.encoding = THREE.LinearEncoding;

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

            //render to the texture
            renderer.setRenderTarget(writeTex);
            renderer.render(accScene, camera);

            // swap the read and write buffers
            tempTex = readTex;
            readTex = writeTex;
            writeTex = tempTex;

            //read off the new frame from readTex
            combineMaterial.uniforms.new.value = readTex.texture;

            //run the accumulation shader
            renderer.setRenderTarget(texA);
            renderer.render(combineScene, camera);

            // //swap read and write
            tempTex = texB;
            texB = texA;
            texA = tempTex;

            //set the accumulated frame to acc
            combineMaterial.uniforms.acc.value=texB.texture;

            //also send this off to the display
            dispMaterial.uniforms.acc.value = texB.texture;

            //make the next move render to canvas
            renderer.setRenderTarget(null);

            //render the actual scene to the camera using this
            renderer.render(dispScene, camera);

        }




        function animate() {

            requestAnimationFrame(animate);

            stats.begin();

            //resizeToDisplay();

            updateUniforms();

            render();

            stats.end();

        }





        async function main() {




            //set the canvas
            canvas = document.querySelector('#c');

            stats = createStats();

            createUI();

            createRenderer();

            createCamera();

            await buildScenes();

            createFrameBuffers();

            animate();

        }






        //Actually Running Things
        //=============================================

        document.addEventListener('keydown', keyDownHandler);

        document.addEventListener('keyup', keyUpHandler);


        // run the main function
        main();
