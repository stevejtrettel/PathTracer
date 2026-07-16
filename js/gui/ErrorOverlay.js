//-------------------------------------------------
// SHADER ERROR OVERLAY
//-------------------------------------------------
// Wired to renderer.debug.onShaderError (see createScene.js). When a scene's
// shader fails to compile/link, three would otherwise leave a silent black
// canvas; this surfaces the GLSL error on-screen — the message plus the offending
// lines from the COMPILED fragment source (three concatenates every include and
// prepends a prefix, so a bare line number is useless without the source).
//
// Note: the line is in the compiled shader, not mapped back to the original
// .glsl include file — that (a full source map across vite-plugin-glsl) is a
// separate, much larger job.

import './gui.css';


let box = null;   // the overlay element, created on first error

function ensureBox(){
    if(box) return box;
    box = document.createElement('div');
    box.className = 'shader-error';

    let bar = document.createElement('div');
    bar.className = 'shader-error-bar';
    let title = document.createElement('span');
    title.textContent = 'Shader compile error';
    let close = document.createElement('button');
    close.className = 'shader-error-close';
    close.textContent = '✕';
    close.addEventListener('click', () => { box.style.display = 'none'; });
    bar.append(title, close);

    let body = document.createElement('pre');
    body.className = 'shader-error-body';

    box.append(bar, body);
    box.body = body;
    document.body.append(box);
    return box;
}


// pull the offending line numbers out of a WebGL info log
// ("ERROR: 0:1837: 'x' : undeclared identifier" -> [1837, ...])
function errorLines(log){
    let out = [];
    let re = /ERROR:\s*\d+:(\d+):/g, m;
    while((m = re.exec(log)) !== null) out.push(parseInt(m[1], 10));
    return out;
}


// a few compiled-source lines around each reported error line, marked
function sourceSnippet(source, lines){
    let src = source.split('\n');
    let seen = new Set();
    let chunks = [];
    for(let ln of lines){
        let lo = Math.max(1, ln - 3), hi = Math.min(src.length, ln + 3);
        let rows = [];
        for(let i = lo; i <= hi; i++){
            if(seen.has(i)) continue;
            seen.add(i);
            let mark = (i === ln) ? '>' : ' ';
            rows.push(`${mark} ${String(i).padStart(5)} | ${src[i - 1] ?? ''}`);
        }
        if(rows.length) chunks.push(rows.join('\n'));
    }
    return chunks.join('\n  …\n');
}


// the onShaderError handler: (gl, program, vertexShader, fragmentShader)
export function showShaderError(gl, program, vs, fs){
    let fragLog = gl.getShaderInfoLog(fs).trim();
    let vertLog = gl.getShaderInfoLog(vs).trim();
    let progLog = gl.getProgramInfoLog(program).trim();
    let log = fragLog || vertLog || progLog || 'Unknown shader link error.';

    //the failing shader is (almost always) the fragment shader here
    let source  = gl.getShaderSource(fs) || '';
    let snippet = fragLog ? sourceSnippet(source, errorLines(fragLog)) : '';

    //keep the console output too (the hook replaces three's default logging)
    console.error('THREE shader error:\n' + log + (snippet ? '\n\n' + snippet : ''));

    let el = ensureBox();
    el.style.display = 'flex';
    el.body.textContent = log + (snippet ? '\n\n' + snippet : '');
}


export default showShaderError;
