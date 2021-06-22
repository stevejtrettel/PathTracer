//Import Stuff
//=============================================
import * as THREE from './libs/three.module.js';

var rightPressed = false;
var leftPressed = false;
var upPressed = false;
var downPressed = false;
var fwdPressed = false;
var bkPressed = false;


var rotRightPressed = false;
var rotLeftPressed = false;
var rotUpPressed = false;
var rotDownPressed = false;
var CWPressed = false;
var CCWPressed = false;


var KeyboardHelper = {
    right: 39,
    left: 37,
    up: 222,
    down: 191,
    fwd: 38,
    bk: 40,
    rotLeft: 65,
    rotUp: 87,
    rotRight: 68,
    rotDown: 83,
    CW: 69,
    CCW: 81,

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
    if (event.keyCode == KeyboardHelper.bk) {
        bkPressed = true;
    } else if (event.keyCode == KeyboardHelper.fwd) {
        fwdPressed = true;
    }
    if (event.keyCode == KeyboardHelper.rotRight) {
        rotRightPressed = true;
    } else if (event.keyCode == KeyboardHelper.rotLeft) {
        rotLeftPressed = true;
    }
    if (event.keyCode == KeyboardHelper.rotDown) {
        rotDownPressed = true;
    } else if (event.keyCode == KeyboardHelper.rotUp) {
        rotUpPressed = true;
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

    if (event.keyCode == KeyboardHelper.bk) {
        bkPressed = false;
    } else if (event.keyCode == KeyboardHelper.fwd) {
        fwdPressed = false;
    }

    if (event.keyCode == KeyboardHelper.rotRight) {
        rotRightPressed = false;
    } else if (event.keyCode == KeyboardHelper.rotLeft) {
        rotLeftPressed = false;
    }
    if (event.keyCode == KeyboardHelper.rotDown) {
        rotDownPressed = false;
    } else if (event.keyCode == KeyboardHelper.rotUp) {
        rotUpPressed = false;
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

let rotAmt = 0.01;

function rotControls() {

    let rot = new THREE.Matrix4().identity();
    let mat = new THREE.Matrix4().identity();

    // KEYBOARD
    if (rotRightPressed) {
        rot = new THREE.Matrix4().makeRotationAxis(vLR, -rotAmt);
        mat.multiply(rot);

    }

    if (rotLeftPressed) {
        rot = new THREE.Matrix4().makeRotationAxis(vLR, rotAmt);
        mat.multiply(rot);
    }

    if (rotDownPressed) {
        rot.makeRotationAxis(vUD, -rotAmt);
        mat.multiply(rot);

    }

    if (rotUpPressed) {
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


    let reportChange = rotRightPressed || rotLeftPressed || rotDownPressed || rotUpPressed || CWPressed || CCWPressed;

    let totalRot = new THREE.Matrix3().setFromMatrix4(mat);
    return [totalRot, reportChange];
}





let transAmt = 0.03;
let transFwd = new THREE.Vector3(0, 0, -1);
let transSide = new THREE.Vector3(1, 0, 0);
let transUp = new THREE.Vector3(0, 1, 0);


function translControls(facing) {

    let totalTrans = new THREE.Vector3(0, 0, 0);
    let newTrans = new THREE.Vector3(0, 0, 0);

    // KEYBOARD
    if (rightPressed) {
        newTrans = transSide.clone().applyMatrix3(facing).multiplyScalar(transAmt);
        totalTrans.add(newTrans);

    }

    if (leftPressed) {
        newTrans = transSide.clone().applyMatrix3(facing).multiplyScalar(-transAmt);
        totalTrans.add(newTrans);
    }

    if (downPressed) {
        newTrans = transUp.clone().applyMatrix3(facing).multiplyScalar(-transAmt);
        totalTrans.add(newTrans);

    }

    if (upPressed) {
        newTrans = transUp.clone().applyMatrix3(facing).multiplyScalar(transAmt);
        totalTrans.add(newTrans);
    }

    if (fwdPressed) {
        newTrans = transFwd.clone().applyMatrix3(facing).multiplyScalar(transAmt);
        totalTrans.add(newTrans);

    }

    if (bkPressed) {
        newTrans = transFwd.clone().applyMatrix3(facing).multiplyScalar(-transAmt);
        totalTrans.add(newTrans);
    }


    let reportChange = rightPressed || leftPressed || downPressed || upPressed || bkPressed || fwdPressed;

    return [totalTrans, reportChange];

}



export {
    keyDownHandler,
    keyUpHandler,
    rotControls,
    translControls
}
