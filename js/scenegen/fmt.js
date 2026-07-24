//-------------------------------------------------
// FORMATTING — JS values -> GLSL source text
//
// The one number rule (docs/generator.md §2.7): integer-valued floats are
// written `X.0`, everything else plain (`0.25`, `14.25`). Anything that can't
// be formatted losslessly is a loud error, never a silent approximation.
//-------------------------------------------------


export function fnum(x){
    if(typeof x !== 'number' || !Number.isFinite(x)){
        throw new Error(`scenegen: expected a finite number, got ${JSON.stringify(x)}`);
    }
    if(Number.isInteger(x)) return `${x}.0`;
    let s = String(x);
    if(s.includes('e')){
        throw new Error(`scenegen: ${x} formats to exponent notation — write it as a glsl\`\` fragment instead`);
    }
    return s;
}

//vec3 literal; equal components collapse to the one-argument form (vec3(0.9))
export function fvec3(v){
    if(!Array.isArray(v) || v.length !== 3){
        throw new Error(`scenegen: expected [x, y, z], got ${JSON.stringify(v)}`);
    }
    if(v[0] === v[1] && v[1] === v[2]) return `vec3(${fnum(v[0])})`;
    return `vec3(${fnum(v[0])}, ${fnum(v[1])}, ${fnum(v[2])})`;
}

export function fvec2(v){
    if(!Array.isArray(v) || v.length !== 2){
        throw new Error(`scenegen: expected [x, y], got ${JSON.stringify(v)}`);
    }
    return `vec2(${fnum(v[0])}, ${fnum(v[1])})`;
}


//strip the common indentation of a template-literal block and trim blank
//first/last lines, so authored GLSL bodies can be indented naturally in JS
export function dedent(text){
    let lines = text.split('\n');
    while(lines.length && lines[0].trim() === '') lines.shift();
    while(lines.length && lines[lines.length - 1].trim() === '') lines.pop();
    let indents = lines.filter(l => l.trim() !== '').map(l => l.match(/^\s*/)[0].length);
    let cut = indents.length ? Math.min(...indents) : 0;
    return lines.map(l => l.slice(cut)).join('\n');
}

//indent every non-blank line by `pad` spaces
export function indent(text, pad){
    let sp = ' '.repeat(pad);
    return text.split('\n').map(l => (l.trim() === '' ? '' : sp + l)).join('\n');
}
