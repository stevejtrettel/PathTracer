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



//=============================================
//Variables Defined in this File
//=============================================



let wCoordText = "a*z^5+sin(t)*b*z^3+cos(t)*c*z";


let ui = {
    a:1.,
    b:1.,
    c:1.,
    wCoordText: wCoordText,

    xMin:-1,
    xMax:1,
    yMin:-1,
    yMax:1,

    rotx:0,
    roty:1,
    rotu:0,
    tumble: 0.2,

    complexTex:1,
    color: 0x1e43,
    curveColor: 0xFAD73F,
    res: 0.6,
    opacity:0.6,
    width: 0.5,
    background:25,

    proj:1,
    offset:0,

};






//=============================================
//Functions to Export
//=============================================


function createUI() {
    let mainMenu = new GUI();

    mainMenu.width = 400;

    mainMenu.domElement.style.userSelect = 'none';


    let domain = mainMenu.addFolder('Domain');

    domain.add(ui, 'xMin', -5, 5, 0.01).name('xMin');
    domain.add(ui, 'xMax', -5, 5, 0.01).name('xMax');

    domain.add(ui, 'yMin', -10, 10, 0.01).name('yMin');
    domain.add(ui, 'yMax', -10, 10, 0.01).name('yMax');
//
    mainMenu.add(ui, 'a', -2,2, 0.01).name('a');
    mainMenu.add(ui, 'b', -2,2, 0.01).name('b');
    mainMenu.add(ui, 'c', -2,2, 0.01).name('c');

    mainMenu.add(ui, 'wCoordText').name('f'
        .concat('a,b,c'.sub().concat('(z;t)=')));

    // mainMenu.add(ui,'phi',0,3.14,0.01).name('Phi');
    mainMenu.add(ui,'rotx',0,1,0.01).name('rotx');
    mainMenu.add(ui,'roty',0,1,0.01).name('roty');
    mainMenu.add(ui,'rotu',0,1,0.01).name('rotu');
    mainMenu.add(ui,'tumble',0,1,0.01).name('tumble');

    mainMenu.add(ui, 'complexTex', {
        'Domain (Grid)': 0,
        'Codomain (Hue)': 1
    }).name('Shading');
//
//       let view = mainMenu.addFolder('Viewpoint');
//
//       // view.add(ui, 'tumble', 0, 6.28, 0.05).name('Rotate');
//        view.add(ui, 'offset', 0., 10, 0.01).name('Offset');
//
//        view.add(ui, 'proj', 0.01, 5, 0.01).name('Projection');


    let graphics = mainMenu.addFolder('Graphics');



//        graphics.addColor(ui, 'color')
//            .name('Surface Color');


//        graphics.addColor(ui, 'curveColor')
//            .name('Curve Color');

    graphics.add(ui,'opacity',0,1,0.01);

    graphics.add(ui, 'res', 0,2, 0.01);

    graphics.add(ui, 'width', 0.01, 1, 0.01).name('Curve Radius');

    // graphics.add(ui,'background',0,50,0.1).name('Background Brightness');

    //view.close()
    domain.close();
    graphics.close();

}



//=============================================
//Exports from this file
//=============================================


export {
    ui,
    createUI
};
