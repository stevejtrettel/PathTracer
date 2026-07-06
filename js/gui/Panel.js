//-------------------------------------------------
// PANEL
//-------------------------------------------------
// The tabbed GUI shell: the one stateful piece (which tab is showing, and
// whether the panel is open). Collapsed by default to a hamburger in the upper
// right; clicking it reveals the dark translucent tabbed panel. Widgets are
// pure functions (see widgets.js); Panel just holds and switches them.

import './gui.css';
import {el} from './widgets.js';


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
        this.open = false;

        this.toggle.addEventListener('click', () => this.setOpen(!this.open));
    }

    setOpen(open){
        this.open = open;
        this.el.classList.toggle('open', open);
    }

    // register a tab; returns its (empty) body <div> for the caller to fill
    tab(title){
        let btn  = el('button', 'gui-tab', title);
        let body = el('div', 'gui-body');

        btn.addEventListener('click', () => this.show(body, btn));
        this.strip.append(btn);
        this.panel.append(body);
        this.tabs.push({body, btn});

        if(this.tabs.length === 1) this.show(body, btn);   // first tab active
        return body;
    }

    show(body, btn){
        for(let t of this.tabs){
            let active = (t.body === body);
            t.body.classList.toggle('active', active);
            t.btn.classList.toggle('active', active);
        }
    }
}


export default Panel;
