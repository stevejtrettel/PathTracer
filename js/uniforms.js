//Import Stuff
//=============================================
import * as THREE from './libs/three.module.js';

import {
    rotControls,
    translControls
} from './controls.js';


import{ui} from "./ui.js";
import {newFrameMaterial, combineMaterial} from "./scene.js";


//Scene Variables
//=============================================


//background sky texture
const skyTex = new THREE.TextureLoader().load('/js/tex/office.jpg');


//background sky texture
const skyTexSmall = new THREE.TextureLoader().load('/js/tex/bk_sm.jpg');




let newFrameUniforms={
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
};





let combineUniforms={
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
};






let displayUniforms={
    iResolution: {
        value: new THREE.Vector3(window.innerWidth, window.innerHeight, 0.)
    },
    acc: {
        value: null
    }
};



//Making Updates
//=============================================

function updateNewFrameUniforms(){

    newFrameMaterial.uniforms.frameSeed.value += 1.;

    let rotData = rotControls();
    let mat = rotData[0];
    let detectRot = rotData[1];

    let translData = translControls(newFrameMaterial.uniforms.facing.value);
    let vec = translData[0];
    let detectTransl = translData[1];

    if (detectRot || detectTransl) {

        newFrameMaterial.uniforms.facing.value.multiply(mat);

        newFrameMaterial.uniforms.location.value.add(vec);

        //reset the frame number to start again
        newFrameMaterial.uniforms.frameSeed.value=0;
        combineMaterial.uniforms.frameNumber.value = 0.;
    }
}

function updateCombineUniforms() {
    combineMaterial.uniforms.frameNumber.value += 1.;
}


function updateDisplayUniforms(){
  //nothing to update
}


function updateUniforms(){
    updateNewFrameUniforms();
    updateCombineUniforms();
    updateDisplayUniforms();
};





//Things to Export
//=============================================

export{
    newFrameUniforms,
    combineUniforms,
    displayUniforms,
    updateUniforms,
}