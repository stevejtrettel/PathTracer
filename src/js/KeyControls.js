import {Vector3,Matrix3,Matrix4} from "three";
import {location} from "./settings.js";

class KeyControls{
    constructor() {

        //execute update when a key is pressed automatically!
        document.addEventListener('keydown', e => this.down(e));
        document.addEventListener('keyup', e => this.up(e));
        //keep track of if there was a change or not
        this.needsUpdate = false;

        this.translateSpeed = 0.03;
        this.rotateSpeed = 0.01;

        this.translate = {
             right: {
                 key: 39,
                 pressed: false,
                 action: new Vector3(1,0,0).multiplyScalar(this.translateSpeed)
             },
             left: {
                 key: 37,
                 pressed: false,
                 action: new Vector3(-1,0,0).multiplyScalar(this.translateSpeed),
             },
             up: {
                 key:222,
                 pressed: false,
                 action: new Vector3(0,1,0).multiplyScalar(this.translateSpeed)
             },
             down: {
                 key: 191,
                 pressed: false,
                 action: new Vector3(0,-1,0).multiplyScalar(this.translateSpeed)
             },
             forward: {
                 key: 38,
                 pressed: false,
                 action: new Vector3(0,0,-1).multiplyScalar(this.translateSpeed)
             },
             backward: {
                 key:40,
                 pressed: false,
                 action: new Vector3(0,0,1).multiplyScalar(this.translateSpeed)
             }
        };

        this.rotate = {
            right: {
                key: 68,
                pressed: false,
                action: new Matrix4().makeRotationAxis(new Vector3(0,-1,0), this.rotateSpeed)
            },
            left: {
                key:65,
                pressed: false,
                action: new Matrix4().makeRotationAxis(new Vector3(0,1,0), this.rotateSpeed)
            },
            up: {
                key: 87,
                pressed: false,
                action: new Matrix4().makeRotationAxis(new Vector3(1,0,0), this.rotateSpeed)
            },
            down: {
                key: 83,
                pressed: false,
                action: new Matrix4().makeRotationAxis(new Vector3(-1,0,0), this.rotateSpeed)
            },
            clockwise: {
                key:69,
                pressed: false,
                action: new Matrix4().makeRotationAxis(new Vector3(0,0,1), this.rotateSpeed)
            },
            counterlockwise: {
                key: 81,
                pressed: false,
                action: new Matrix4().makeRotationAxis(new Vector3(0,0,-1), this.rotateSpeed)
            },
        }

        //set the original position and facing from the settings file
        this.position = new Vector3(location.position[0], location.position[1], location.position[2]);
        this.facing = new Matrix3().set(
            location.facing[0],location.facing[1],location.facing[2],
            location.facing[3],location.facing[4],location.facing[5],
            location.facing[6],location.facing[7],location.facing[8]
        );

    }

    down(event){

        for(const dir in this.translate){
            if(this.translate[dir].key == event.keyCode){
                this.translate[dir].pressed = true;
                this.needsUpdate=true;
            }
        }
        for(const dir in this.rotate){
            if(this.rotate[dir].key == event.keyCode){
                this.rotate[dir].pressed = true;
                this.needsUpdate=true;
            }
        }
    }

    up(event){

        for(const dir in this.translate){
            if(this.translate[dir].key == event.keyCode){
                this.translate[dir].pressed = false;
            }
        }
        for(const dir in this.rotate){
            if(this.rotate[dir].key == event.keyCode){
                this.rotate[dir].pressed = false;
            }
        }
    }

    isPressed(){
        let pressed = false;
        for(const dir in this.translate){
            pressed = pressed || this.translate[dir].pressed;
            }
        for(const dir in this.rotate){
            pressed = pressed || this.rotate[dir].pressed;
        }
        return pressed;
    }

    update(){

        for(const dir in this.translate){
            if(this.translate[dir].pressed){
                let newTrans = this.translate[dir].action.clone();
                newTrans.applyMatrix3(this.facing)
                this.position.add(newTrans);
            }
        }

        for(const dir in this.rotate){
            if(this.rotate[dir].pressed){
                this.facing.multiply(new Matrix3().setFromMatrix4(this.rotate[dir].action));
            }
        }

    }


    printLocation(){

        //internally things are stored column-major, but are entered row-major
        //so, to save the correct matrix as output, we transpose it
        let origFacing = this.facing.transpose();

        let str = ``;
        str += `let position = [${this.position.x},${this.position.y},${this.position.z}];\n\n`;
        str += `let facing = [${origFacing.elements}]; \n\n`;
        str += `let location = {
position: position,
facing: facing
};\n\n`;
        str += `export {location};`;
        return str;
    }

}


export default KeyControls;