//-------------------------------------------------
// PANEL
//-------------------------------------------------
// The tabbed GUI shell: the one stateful piece (which tab is showing, and
// whether the panel is open). Collapsed by default to a hamburger in the upper
// right; clicking it reveals the dark translucent tabbed panel. Widgets are
// pure functions (see widgets.js); Panel just holds and switches them.

import './gui.css';
import {el} from './widgets.js';


// persisted panel state (open + active tab index) across reloads
const STORE = 'pt-gui';
function loadState(){
    try { return JSON.parse(localStorage.getItem(STORE)) || {}; }
    catch { return {}; }
}


class Panel{
    constructor(){
        this.el     = el('div', 'gui');
        this.toggle = el('button', 'gui-hamburger', '☰');   // ☰
        this.panel  = el('div', 'gui-panel');
        this.strip  = el('div', 'gui-tabs');

        this.panel.append(this.strip);
        this.el.append(this.toggle, this.panel);
        document.body.append(this.el);

        this.tabs = [];

        //restore persisted state (open + which tab); tabs apply savedTab as they
        //register (see tab()), open is applied now
        let saved = loadState();
        this.savedTab = saved.tab ?? 0;
        this.activeTab = this.savedTab;
        this.open = false;
        this.setOpen(saved.open ?? false);

        this.toggle.addEventListener('click', () => this.setOpen(!this.open));
    }

    //write the current open/active-tab state to localStorage
    save(){
        try { localStorage.setItem(STORE, JSON.stringify({open: this.open, tab: this.activeTab})); }
        catch { /* storage unavailable — persistence is best-effort */ }
    }

    setOpen(open){
        this.open = open;
        this.el.classList.toggle('open', open);
        this.save();
    }

    // register a tab; returns its (empty) body <div> for the caller to fill
    tab(title){
        let btn  = el('button', 'gui-tab', title);
        let body = el('div', 'gui-body');

        btn.addEventListener('click', () => this.show(body, btn));
        this.strip.append(btn);
        this.panel.append(body);
        this.tabs.push({body, btn});

        //default the first tab active, then let the persisted tab win once it registers
        let index = this.tabs.length - 1;
        if(index === 0) this.show(body, btn);
        if(index === this.savedTab) this.show(body, btn);
        return body;
    }

    show(body, btn){
        for(let t of this.tabs){
            let active = (t.body === body);
            t.body.classList.toggle('active', active);
            t.btn.classList.toggle('active', active);
        }
        this.activeTab = this.tabs.findIndex(t => t.body === body);
        this.save();
    }
}


export default Panel;
