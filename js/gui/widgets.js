//-------------------------------------------------
// WIDGETS
//-------------------------------------------------
// Pure DOM builders for the custom GUI. A widget knows nothing about the path
// tracer: it renders an element and calls onChange(newValue) when the user
// touches it. The engine coupling (updateUniforms + reset) is injected as that
// onChange from UI.js (see `wire`).
//
//   control(knob, onChange)  routes a knob to the right widget by type
//   slider / toggle          the real per-type widgets
//   button/numberField/select   hand-written "furniture" (non-knob actions)
//   el(tag, cls, text)       createElement shorthand


// createElement shorthand: el('div', 'gui-body', 'text')
function el(tag, cls, text){
    let node = document.createElement(tag);
    if(cls)  node.className = cls;
    if(text != null) node.textContent = text;
    return node;
}


// pretty-print a slider value: ints bare, floats trimmed to 3 decimals
function fmt(v){
    if(Number.isInteger(v)) return String(v);
    return String(Math.round(v * 1000) / 1000);
}


// keyboard nudge: click a slider to select it (focus), then =/+ and -/_ step it
// by one step. Installed once; a no-op unless a slider is focused, so it never
// interferes with the camera keys (which are all other keys).
let selectedSlider = null;
let nudgeInstalled = false;
function installNudge(){
    if(nudgeInstalled) return;
    nudgeInstalled = true;
    window.addEventListener('keydown', (e) => {
        if(!selectedSlider) return;
        let dir = (e.key === '=' || e.key === '+') ? 1
                : (e.key === '-' || e.key === '_') ? -1 : 0;
        if(!dir) return;
        e.preventDefault();
        let s = selectedSlider;
        let step = parseFloat(s.step) || 1;
        let v = parseFloat(s.value) + dir * step;
        v = Math.min(parseFloat(s.max), Math.max(parseFloat(s.min), v));
        s.value = v;
        s.dispatchEvent(new Event('input'));   // reuse the slider's own handler
    });
}


// float/int knob:  [ label · track+dot · value ]
function slider(knob, onChange){
    let row = el('div', 'knob');
    let label = el('label', 'knob-label', knob.label ?? knob.name);
    row.append(label);

    let input = el('input', 'knob-range');
    input.type  = 'range';
    input.min   = knob.min  ?? 0;
    input.max   = knob.max  ?? 1;
    input.step  = knob.step ?? 0.001;
    input.value = knob.value;

    let readout = el('span', 'knob-value', fmt(knob.value));

    input.addEventListener('input', () => {
        let v = knob.type === 'int' ? parseInt(input.value) : parseFloat(input.value);
        readout.textContent = fmt(v);
        onChange(v);
    });

    //select this slider for =/- nudging by clicking its NAME or VALUE (not the
    //track — that would move the value). Focusing selects without changing
    //anything; blur (clicking away) deselects.
    installNudge();
    input.addEventListener('focus', () => { selectedSlider = input; });
    input.addEventListener('blur',  () => { if(selectedSlider === input) selectedSlider = null; });
    for(let target of [label, readout]){
        target.style.cursor = 'pointer';
        target.addEventListener('mousedown', (e) => { e.preventDefault(); input.focus(); });
    }

    row.append(input, readout);
    return row;
}


// bool knob:  [ label · checkbox ]
function toggle(knob, onChange){
    let row = el('div', 'knob');
    row.append(el('label', 'knob-label', knob.label ?? knob.name));

    let input = el('input', 'knob-check');
    input.type    = 'checkbox';
    input.checked = !!knob.value;
    input.addEventListener('change', () => onChange(input.checked));

    row.append(input);
    return row;
}


// the router: a knob's type -> its widget. Grows a case at a time
// (colorPicker / xyPad arrive with C2), mirroring the switch in knobs.js.
function control(knob, onChange){
    switch(knob.type){
        case 'bool': return toggle(knob, onChange);
        default:     return slider(knob, onChange);   // float, int
    }
}


//--- furniture: hand-written action widgets that aren't knobs ---

// a labelled action button
function button(label, action){
    let b = el('button', 'gui-btn', label);
    b.addEventListener('click', action);
    return b;
}

// a free-entry number field, fires onChange on commit (blur / enter)
function numberField(label, value, onChange){
    let row = el('div', 'knob');
    row.append(el('label', 'knob-label', label));

    let input = el('input', 'knob-num');
    input.type  = 'number';
    input.value = value;
    input.addEventListener('change', () => onChange(parseFloat(input.value)));

    row.append(input);
    return row;
}

// a dropdown. options is an array of [label, value] pairs; onChange receives
// the selected value (any type — the option's DOM value is its index, so null
// and floats survive). `value` preselects the matching option.
function select(label, options, value, onChange){
    let row = el('div', 'knob');
    row.append(el('label', 'knob-label', label));

    let sel = el('select', 'knob-select');
    options.forEach(([lab, val], i) => {
        let o = el('option', null, lab);
        o.value = String(i);
        if(val === value) o.selected = true;
        sel.append(o);
    });
    sel.addEventListener('change', () => onChange(options[parseInt(sel.value)][1]));

    row.append(sel);
    return row;
}

// a small section heading inside a tab body
function section(title){
    return el('div', 'gui-section', title);
}

// a collapsible section: a clickable heading that shows/hides its body (closed
// by default). Returns the wrapper element; append children to its `.body`.
function collapsible(title){
    let wrap = el('div', 'gui-collapse');
    let head = el('div', 'gui-collapse-head');
    head.append(el('span', 'gui-collapse-arrow', '▸'), el('span', null, title));
    let body = el('div', 'gui-collapse-body');
    head.addEventListener('click', () => wrap.classList.toggle('open'));
    wrap.append(head, body);
    wrap.body = body;
    return wrap;
}


export {el, control, slider, toggle, button, numberField, select, section, collapsible};
