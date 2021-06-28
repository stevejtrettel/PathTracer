//=============================================
//Imports from lib/
//=============================================

import {
    GUI
} from './libs/dat.gui.module.js';

//=============================================
//Imports from My Code
//=============================================

//NONE HERE
import{
    newFrameMaterial,
    combineMaterial
} from "./scene.js";


//=============================================
//Variables Defined in this File
//=============================================


let ui = {
    brightness:1,
    aperture:0.05,
    focalLength:4.,
    fov:60,
    focusHelp:true,
};






//=============================================
//Functions to Export
//=============================================


function createUI() {
    let mainMenu = new GUI();

    mainMenu.width = 200;
    mainMenu.domElement.style.userSelect = 'none';
    mainMenu.close();

    let brightnessController=mainMenu.add(ui,'brightness',0,2,0.01).name('Brightness');
    let apertureController=mainMenu.add(ui,'aperture',0,0.2,0.001).name('Aperture');
    let focalLengthController=mainMenu.add(ui,'focalLength',0,20,0.1).name('FocalLength');
    let focusHelpController=mainMenu.add(ui,'focusHelp').name('FocusHelp');
    let fovController=mainMenu.add(ui,'fov',40,140,1).name('FOV');


    brightnessController.onChange(function(value){
        newFrameMaterial.uniforms.brightness.value=value;
        combineMaterial.uniforms.frameNumber.value=0;
    });

    apertureController.onChange(function(value){
        newFrameMaterial.uniforms.aperture.value=value;
        combineMaterial.uniforms.frameNumber.value=0;
    });

    focalLengthController.onChange(function(value){
        newFrameMaterial.uniforms.focalLength.value=value;
        combineMaterial.uniforms.frameNumber.value=0;
    });

    focusHelpController.onChange(function(value){
        newFrameMaterial.uniforms.focusHelp.value=value;
        combineMaterial.uniforms.frameNumber.value=0;
    });

    fovController.onChange(function(value){
        newFrameMaterial.uniforms.fov.value=value;
        combineMaterial.uniforms.frameNumber.value=0;
    });
}



//=============================================
//Exports from this file
//=============================================


export {
    ui,
    createUI
};
