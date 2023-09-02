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
    focusHelp:false,
    extra:0.5,
    extra2:0.5,
    extra3:0.5,
    extra4:0.5,
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
    let focalLengthController=mainMenu.add(ui,'focalLength',0,40,0.01).name('FocalLength');
    let focusHelpController=mainMenu.add(ui,'focusHelp').name('FocusHelp');
    let fovController=mainMenu.add(ui,'fov',40,140,1).name('FOV');
    let extraController=mainMenu.add(ui,'extra',0,1,0.01).name('extra');
    let extra2Controller=mainMenu.add(ui,'extra2',0,1,0.01).name('extra2');
    let extra3Controller=mainMenu.add(ui,'extra3',0,1,0.01).name('extra3');
    let extra4Controller=mainMenu.add(ui,'extra4',0,1,0.01).name('extra4');

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


    extraController.onChange(function(value){
        newFrameMaterial.uniforms.extra.value=value;
        combineMaterial.uniforms.frameNumber.value=0;
    });


    extra2Controller.onChange(function(value){
        newFrameMaterial.uniforms.extra2.value=value;
        combineMaterial.uniforms.frameNumber.value=0;
    });

    extra3Controller.onChange(function(value){
        newFrameMaterial.uniforms.extra3.value=value;
        combineMaterial.uniforms.frameNumber.value=0;
    });


    extra4Controller.onChange(function(value){
        newFrameMaterial.uniforms.extra4.value=value;
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
