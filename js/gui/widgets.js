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


// true when focus is in a text-entry field, so global single-key shortcuts
// (X to save, H to hide the panel) should not fire
function isTypingTarget(a){
    let tag = a && a.tagName;
    return tag === 'TEXTAREA' || tag === 'SELECT' ||
           (tag === 'INPUT' && (a.type === 'number' || a.type === 'text'));
}


// largest {x,y} box of the given width/height ratio that fits the window
// (null aspect = fill the window). Used by createScene (initial size) and the
// UI's Aspect selector.
function fitAspect(aspect){
    let w = window.innerWidth, h = window.innerHeight;
    if(aspect){
        if(w / h > aspect) w = Math.round(h * aspect);
        else               h = Math.round(w / aspect);
    }
    return {x: w, y: h};
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
    input.addEventListener('focus', () => { selectedSlider = input; row.classList.add('knob-selected'); });
    input.addEventListener('blur',  () => { if(selectedSlider === input) selectedSlider = null; row.classList.remove('knob-selected'); });
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


// color knob (vec3 in 0..1):  [ label · native color swatch ]
function rgbToHex([r, g, b]){
    let h = (n) => Math.round(Math.max(0, Math.min(1, n)) * 255).toString(16).padStart(2, '0');
    return `#${h(r)}${h(g)}${h(b)}`;
}
function hexToRgb(hex){
    return [parseInt(hex.slice(1, 3), 16) / 255,
            parseInt(hex.slice(3, 5), 16) / 255,
            parseInt(hex.slice(5, 7), 16) / 255];
}
function colorPicker(knob, onChange){
    let row = el('div', 'knob');
    row.append(el('label', 'knob-label', knob.label ?? knob.name));

    let input = el('input', 'knob-color');
    input.type  = 'color';
    input.value = rgbToHex(knob.value);
    input.addEventListener('input', () => onChange(hexToRgb(input.value)));

    row.append(input);
    return row;
}


// vec2 knob:  [ label · draggable 2D pad · value ]. Both axes share the knob's
// min/max; the pad's y runs bottom(min)->top(max).
function xyPad(knob, onChange){
    let row = el('div', 'knob knob-xy');
    row.append(el('label', 'knob-label', knob.label ?? knob.name));

    let pad = el('div', 'knob-pad');
    let dot = el('div', 'knob-pad-dot');
    pad.append(dot);
    let readout = el('span', 'knob-value');

    let min = knob.min ?? 0, max = knob.max ?? 1, span = (max - min) || 1;
    let val = [knob.value[0], knob.value[1]];

    let place = () => {
        dot.style.left = `${((val[0] - min) / span) * 100}%`;
        dot.style.top  = `${(1 - (val[1] - min) / span) * 100}%`;
        readout.textContent = `${fmt(val[0])}, ${fmt(val[1])}`;
    };
    let setFromEvent = (e) => {
        let r = pad.getBoundingClientRect();
        let fx = Math.min(1, Math.max(0, (e.clientX - r.left) / r.width));
        let fy = Math.min(1, Math.max(0, (e.clientY - r.top)  / r.height));
        val = [min + fx * span, min + (1 - fy) * span];
        place();
        onChange([val[0], val[1]]);
    };

    let dragging = false;
    pad.addEventListener('mousedown', (e) => { dragging = true; setFromEvent(e); });
    window.addEventListener('mousemove', (e) => { if(dragging) setFromEvent(e); });
    window.addEventListener('mouseup',   ()  => { dragging = false; });

    place();
    row.append(pad, readout);
    return row;
}


// the router: a knob's type -> its widget, mirroring the switch in knobs.js.
function control(knob, onChange){
    switch(knob.type){
        case 'bool':  return toggle(knob, onChange);
        case 'color': return colorPicker(knob, onChange);
        case 'vec2':  return xyPad(knob, onChange);
        default:      return slider(knob, onChange);   // float, int
    }
}


//--- furniture: hand-written action widgets that aren't knobs ---

// a labelled action button
function button(label, action){
    let b = el('button', 'gui-btn', label);
    b.addEventListener('click', action);
    return b;
}

// a free-entry number field, fires onChange on commit (blur / enter).
// a cleared or non-numeric field restores the last good value instead of
// committing NaN.
function numberField(label, value, onChange){
    let row = el('div', 'knob');
    row.append(el('label', 'knob-label', label));

    let input = el('input', 'knob-num');
    input.type  = 'number';
    input.value = value;
    let lastGood = value;
    input.addEventListener('change', () => {
        let v = parseFloat(input.value);
        if(!Number.isFinite(v)){ input.value = lastGood; return; }
        lastGood = v;
        onChange(v);
    });

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


//(slider/colorPicker/xyPad are exported as public widget surface even though
//UI.js reaches them only through control())
export {el, control, slider, toggle, colorPicker, xyPad, button, numberField, select, section, collapsible, isTypingTarget, fitAspect};
