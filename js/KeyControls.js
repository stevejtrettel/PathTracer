import {Vector3,Matrix3,Matrix4} from "./math/index.js";


class KeyControls{
    constructor(location) {

        //execute update when a key is pressed automatically!
        document.addEventListener('keydown', e => this.down(e));
        document.addEventListener('keyup', e => this.up(e));

        this.translateSpeed = 0.03;
        this.rotateSpeed = 0.007;   //fixed turn rate; independent of fly speed

        //fly speed: a live multiplier on the TRANSLATE step only (set from the
        //Camera tab), plus a hold-Shift boost for coarse repositioning. Rotation
        //is deliberately left out — turning is scale-independent, so it stays a
        //fixed rate. speed=1 reproduces the original 0.03 move step.
        this.speed = 1;
        this.boostFactor = 5;
        this.boosted = false;

        //translate bindings: `action` is a unit direction (local camera frame)
        this.translate = {
             right:    { code: "ArrowRight", pressed: false, action: new Vector3( 1, 0, 0) },
             left:     { code: "ArrowLeft",  pressed: false, action: new Vector3(-1, 0, 0) },
             up:       { code: "Quote",      pressed: false, action: new Vector3( 0, 1, 0) },
             down:     { code: "Slash",      pressed: false, action: new Vector3( 0,-1, 0) },
             forward:  { code: "ArrowUp",    pressed: false, action: new Vector3( 0, 0,-1) },
             backward: { code: "ArrowDown",  pressed: false, action: new Vector3( 0, 0, 1) },
        };

        //rotate bindings: `axis` is the local rotation axis (angle applied in update)
        this.rotate = {
            right:           { code: "KeyD", pressed: false, axis: new Vector3(0,-1, 0) },
            left:            { code: "KeyA", pressed: false, axis: new Vector3(0, 1, 0) },
            up:              { code: "KeyW", pressed: false, axis: new Vector3(1, 0, 0) },
            down:            { code: "KeyS", pressed: false, axis: new Vector3(-1,0, 0) },
            clockwise:       { code: "KeyE", pressed: false, axis: new Vector3(0, 0, 1) },
            counterclockwise: { code: "KeyQ", pressed: false, axis: new Vector3(0, 0,-1) },
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

        if(event.code === "ShiftLeft" || event.code === "ShiftRight") this.boosted = true;

        for(const dir in this.translate){
            if(this.translate[dir].code === event.code){
                this.translate[dir].pressed = true;
            }
        }
        for(const dir in this.rotate){
            if(this.rotate[dir].code === event.code){
                this.rotate[dir].pressed = true;
            }
        }
    }

    up(event){

        if(event.code === "ShiftLeft" || event.code === "ShiftRight") this.boosted = false;

        for(const dir in this.translate){
            if(this.translate[dir].code === event.code){
                this.translate[dir].pressed = false;
            }
        }
        for(const dir in this.rotate){
            if(this.rotate[dir].code === event.code){
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

        //fly speed scales translation only (× slider × Shift boost); rotation
        //keeps its fixed rate so turning doesn't get faster with move speed
        let mult = this.speed * (this.boosted ? this.boostFactor : 1);

        for(const dir in this.translate){
            if(this.translate[dir].pressed){
                let newTrans = this.translate[dir].action.clone().multiplyScalar(this.translateSpeed * mult);
                newTrans.applyMatrix3(this.facing)
                this.position.add(newTrans);
            }
        }

        for(const dir in this.rotate){
            if(this.rotate[dir].pressed){
                let rot = new Matrix4().makeRotationAxis(this.rotate[dir].axis, this.rotateSpeed);
                this.facing.multiply(new Matrix3().setFromMatrix4(rot));
            }
        }

    }


    printLocation(){

        //internally things are stored column-major, but are entered row-major
        //so, to save the correct matrix as output, we transpose a copy
        //(transpose() mutates in place: do not transpose this.facing itself!)
        let origFacing = this.facing.clone().transpose();

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
