//-------------------------------------------------
// FPS METER
//-------------------------------------------------
// Tiny replacement for three's Stats addon (the only reason we still imported
// three/addons). Same interface the app used: `.dom`, `.showPanel()`, `.begin()`,
// `.end()`. createScene wraps newFrame in begin()/end(); the UI hosts `.dom` in
// the Help tab. Averages frames over ~500 ms.

class FpsMeter {
    constructor(){
        this.dom = document.createElement('div');
        this.dom.className = 'fps-meter';
        this.dom.textContent = '— fps';

        this._prev   = performance.now();
        this._frames = 0;
        this._acc    = 0;
    }

    showPanel(){}   // three-Stats API compatibility (no-op)
    begin(){}

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
