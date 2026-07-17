//-------------------------------------------------
// FPS METER
//-------------------------------------------------
// Tiny frame-rate readout: createScene calls end() once per frame (the meter
// measures the frame-to-frame interval, so that's all it needs); the UI hosts
// `.dom` in the Help tab. Averages frames over ~500 ms.

class FpsMeter {
    constructor(){
        this.dom = document.createElement('div');
        this.dom.className = 'fps-meter';
        this.dom.textContent = '— fps';

        this._prev   = performance.now();
        this._frames = 0;
        this._acc    = 0;
    }

    end(){
        let now = performance.now();
        this._acc += now - this._prev;
        this._prev = now;
        this._frames++;
        if(this._acc >= 500){
            this.dom.textContent = `${(this._frames * 1000 / this._acc).toFixed(0)} fps`;
            this._frames = 0;
            this._acc = 0;
        }
    }
}

export default FpsMeter;
