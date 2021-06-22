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
    accMaterial
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
    let focalLengthController=mainMenu.add(ui,'focalLength',0,10,0.1).name('FocalLength');
    let focusHelpController=mainMenu.add(ui,'focusHelp').name('FocusHelp');
    let fovController=mainMenu.add(ui,'fov',40,140,1).name('FOV');


    brightnessController.onChange(function(value){
        accMaterial.uniforms.brightness.value=value;
        accMaterial.uniforms.iFrame.value=0;
    });

    apertureController.onChange(function(value){
        accMaterial.uniforms.aperture.value=value;
        accMaterial.uniforms.iFrame.value=0;
    });

    focalLengthController.onChange(function(value){
        accMaterial.uniforms.focalLength.value=value;
        accMaterial.uniforms.iFrame.value=0;
    });

    focusHelpController.onChange(function(value){
        accMaterial.uniforms.focusHelp.value=value;
        accMaterial.uniforms.iFrame.value=0;
    });

    fovController.onChange(function(value){
        accMaterial.uniforms.fov.value=value;
        accMaterial.uniforms.iFrame.value=0;
    });
}



//=============================================
//Exports from this file
//=============================================


export {
    ui,
    createUI
};
