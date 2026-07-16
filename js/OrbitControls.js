import {Vector3, Matrix3, Matrix4} from "./math/index.js";


//-------------------------------------------------
// ORBIT CONTROLS
//-------------------------------------------------
// Mouse orbit for the free-fly camera, adapted from the PathTracerGLSL repo's
// OrbitControls.ts. That version stores the camera as spherical coords about a
// target and rebuilds it with a look-at; here we instead rotate the existing
// camera rig (KeyControls' `position` + `facing`) RIGIDLY about a pivot — same
// orbit feel (subject stays centered, stays upright), but no look-at matrix and
// no spherical bookkeeping, so it shares state with the keyboard and the two
// compose ("mouse for big swings, keyboard to refine").
//
//   drag           orbit about the target point (the origin, where scenes sit)
//   pinch (trackpad) dolly along forward (ctrl+wheel; no scroll wheel needed)
//
// Signs (drag direction) are a by-eye call — flip the marked lines to invert.

class OrbitControls{
    constructor(canvas, controls, opts){
        this.canvas   = canvas;
        this.controls = controls;              // KeyControls: owns .position, .facing
        this.onChange = opts.onChange;         // push uniforms + reset accumulation
        this.enabled  = opts.enabled;          // () => bool (toggle + render lock)

        //orbit pivot: a fixed target point (default origin). Scenes are built
        //around the origin, so orbiting there keeps the subject centered. A
        //per-scene settings.target can override it.
        this.pivot = new Vector3().fromArray(opts.target ?? [0, 0, 0]);

        //mirrors the OrbitControls.ts settings
        this.orbitSpeed = 0.003;               // rad per pixel  (their repo: 0.01)
        this.zoomSpeed  = 0.01;                // world units per wheel delta
        this.minElev = -Math.PI/2 + 0.1;       // pole clamp (their repo)
        this.maxElev =  Math.PI/2 - 0.1;

        this.dragging = false;
        this.lastX = 0;
        this.lastY = 0;

        canvas.addEventListener('mousedown', (e) => this.onDown(e));
        window.addEventListener('mousemove', (e) => this.onMove(e));
        window.addEventListener('mouseup',   ()  => { this.dragging = false; });
        canvas.addEventListener('wheel', (e) => this.onWheel(e), {passive: false});
    }

    //world-space forward of the camera (local -z through `facing`)
    forward(){
        return new Vector3(0, 0, -1).applyMatrix3(this.controls.facing);
    }

    onDown(e){
        if(e.button !== 0 || !this.enabled()) return;
        this.dragging = true;
        this.lastX = e.clientX;
        this.lastY = e.clientY;
        //fix the pivot at the look-point for the whole drag, so the subject you
        //grabbed stays centered even as position/forward change
        let d = Math.max(this.focalDist(), 1);
        this.pivot.copy(this.controls.position).addScaledVector(this.forward(), d);
    }

    onMove(e){
        if(!this.dragging) return;
        if(!this.enabled()){ this.dragging = false; return; }
        let dx = e.clientX - this.lastX;
        let dy = e.clientY - this.lastY;
        this.lastX = e.clientX;
        this.lastY = e.clientY;
        this.orbit(dx, dy);
        this.onChange();
    }

    onWheel(e){
        if(!e.ctrlKey || !this.enabled()) return;   // pinch only (ctrl+wheel = trackpad zoom)
        e.preventDefault();
        this.dolly(-e.deltaY * this.zoomSpeed);      // FLIP sign to invert pinch
        this.onChange();
    }

    //rotate the whole rig rigidly about `pivot` by a world rotation R3
    applyRig(R3){
        let pos = this.controls.position;
        let rel = pos.clone().sub(this.pivot).applyMatrix3(R3);
        pos.copy(this.pivot).add(rel);
        this.controls.facing.premultiply(R3);        // world rotation of orientation
    }

    //drag -> orbit. Yaw about world-up (azimuth), pitch about camera-right
    //(elevation), clamped near the poles. Mirrors handleOrbit() in the repo.
    orbit(dx, dy){
        //--- azimuth: yaw about world +Y, unclamped ---
        let yaw = new Matrix3().setFromMatrix4(
            new Matrix4().makeRotationAxis(new Vector3(0, 1, 0), dx * this.orbitSpeed)   // FLIP sign to invert
        );
        this.applyRig(yaw);

        //--- elevation: pitch about camera-right, clamped so it can't flip poles ---
        let fwd   = this.forward();
        let right = new Vector3().crossVectors(fwd, new Vector3(0, 1, 0)).normalize();
        let pitch = new Matrix3().setFromMatrix4(
            new Matrix4().makeRotationAxis(right, dy * this.orbitSpeed)                  // FLIP sign to invert
        );
        let newFwd = fwd.clone().applyMatrix3(pitch);
        let elev   = Math.asin(Math.max(-1, Math.min(1, newFwd.y)));
        if(elev > this.minElev && elev < this.maxElev) this.applyRig(pitch);
    }

    //pinch -> dolly along forward (toward/away from the look-point)
    dolly(amount){
        this.controls.position.addScaledVector(this.forward(), amount);
    }
}


export default OrbitControls;
