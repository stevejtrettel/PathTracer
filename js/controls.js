//Import Stuff
//=============================================
import * as THREE from './libs/three.module.js';


var rightPressed = false;
var leftPressed = false;
var upPressed = false;
var downPressed = false;
var CWPressed = false;
var CCWPressed = false;


var KeyboardHelper = {
    left: 65,
    up: 87,
    right: 68,
    down: 83,
    CW: 69,
    CCW: 81
};

function keyDownHandler(event) {
    if (event.keyCode == KeyboardHelper.right) {
        rightPressed = true;
    } else if (event.keyCode == KeyboardHelper.left) {
        leftPressed = true;
    }
    if (event.keyCode == KeyboardHelper.down) {
        downPressed = true;
    } else if (event.keyCode == KeyboardHelper.up) {
        upPressed = true;
    }
    if (event.keyCode == KeyboardHelper.CW) {
        CWPressed = true;
    } else if (event.keyCode == KeyboardHelper.CCW) {
        CCWPressed = true;
    }
}



function keyUpHandler(event) {
    if (event.keyCode == KeyboardHelper.right) {
        rightPressed = false;
    } else if (event.keyCode == KeyboardHelper.left) {
        leftPressed = false;
    }
    if (event.keyCode == KeyboardHelper.down) {
        downPressed = false;
    } else if (event.keyCode == KeyboardHelper.up) {
        upPressed = false;
    }
    if (event.keyCode == KeyboardHelper.CW) {
        CWPressed = false;
    } else if (event.keyCode == KeyboardHelper.CCW) {
        CCWPressed = false;
    }
}



let vLR = new THREE.Vector3(0, 1, 0); //left right
let vUD = new THREE.Vector3(1, 0, 0); //updown
let vRot = new THREE.Vector3(0, 0, 1); //rotate

let rotAmt = 0.005;

function rotControls() {

    let rot = new THREE.Matrix4().identity();
    let mat = new THREE.Matrix4().identity();

    // KEYBOARD
    if (rightPressed) {
        rot = new THREE.Matrix4().makeRotationAxis(vLR, -rotAmt);
        mat.multiply(rot);

    }

    if (leftPressed) {
        rot = new THREE.Matrix4().makeRotationAxis(vLR, rotAmt);
        mat.multiply(rot);
    }

    if (downPressed) {
        rot.makeRotationAxis(vUD, -rotAmt);
        mat.multiply(rot);

    }

    if (upPressed) {
        rot.makeRotationAxis(vUD, rotAmt);
        mat.multiply(rot);
    }

    if (CWPressed) {
        rot.makeRotationAxis(vRot, rotAmt);
        mat.multiply(rot);
    }

    if (CCWPressed) {
        rot.makeRotationAxis(vRot, -rotAmt);
        mat.multiply(rot);
    }


    let reportChange = rightPressed || leftPressed || downPressed || upPressed || CWPressed || CCWPressed;

    let totalRot = new THREE.Matrix3().setFromMatrix4(mat);
    return [totalRot, reportChange];
}





export {
    keyDownHandler,
    keyUpHandler,
    rotControls
}
