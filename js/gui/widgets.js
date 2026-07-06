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


// float/int knob:  [ label · track+dot · value ]
function slider(knob, onChange){
    let row = el('div', 'knob');
    row.append(el('label', 'knob-label', knob.label ?? knob.name));

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

// a dropdown of numeric options
function select(label, options, value, onChange){
    let row = el('div', 'knob');
    row.append(el('label', 'knob-label', label));

    let sel = el('select', 'knob-select');
    for(let opt of options){
        let o = el('option', null, String(opt));
        o.value = opt;
        if(opt === value) o.selected = true;
        sel.append(o);
    }
    sel.addEventListener('change', () => onChange(parseFloat(sel.value)));

    row.append(sel);
    return row;
}

// a small section heading inside a tab body
function section(title){
    return el('div', 'gui-section', title);
}


export {el, control, slider, toggle, button, numberField, select, section};
