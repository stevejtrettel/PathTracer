//Import Stuff
//=============================================
import * as THREE from './libs/three.module.js';

import {
    rotControls,
    translControls
} from './controls.js';


import{ui} from "./ui.js";
import {accMaterial, combineMaterial} from "./scene.js";


//Scene Variables
//=============================================


//background sky texture
const skyTex = new THREE.TextureLoader().load('/js/tex/bk.jpg');


//background sky texture
const skyTexSmall = new THREE.TextureLoader().load('/js/tex/bk_sm.jpg');




let newFrameUniforms={
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
    },
    aperture: {
        value: ui.aperture.value
    },
    focalLength: {
        value: ui.focalLength.value
    },
    brightness: {
        value: ui.brightness.value
    },
    focusHelp: {
        value: ui.focusHelp.value
    },
    fov: {
        value: ui.fov.value
    },
};





let combineUniforms={
    iFrame: {
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
    accMaterial.uniforms.iFrame.value += 1.;
    accMaterial.uniforms.seed.value += 1.;

    let rotData = rotControls();
    let mat = rotData[0];
    let detectRot = rotData[1];

    let translData = translControls(accMaterial.uniforms.facing.value);
    let vec = translData[0];
    let detectTransl = translData[1];

    if (detectRot || detectTransl) {

        accMaterial.uniforms.facing.value.multiply(mat);

        accMaterial.uniforms.location.value.add(vec);

        //stop updating the random seed:
        accMaterial.uniforms.seed.value=0;

        //reset the combination of frames
        combineMaterial.uniforms.iFrame.value = 0.;
    }
}

function updateCombineUniforms() {
    combineMaterial.uniforms.iFrame.value += 1.;
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