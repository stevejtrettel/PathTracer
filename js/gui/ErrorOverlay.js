//-------------------------------------------------
// ERROR OVERLAY
//-------------------------------------------------
// A failed shader or a scene the generator rejects would otherwise be a silent
// black canvas with the message only in the console; this puts it on-screen.
//   showShaderError  from ComputeShader._buildProgram when a program fails to
//                    link: the GLSL error plus the offending lines of the
//                    COMPILED fragment source (every #include is concatenated
//                    and shimFragment prepends a header, so a bare line number
//                    is useless without the source)
//   watchErrors      from createScene: any other uncaught error (scenegen throws
//                    while main.js runs emit(), a JS bug)
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
    let close = document.createElement('button');
    close.className = 'shader-error-close';
    close.textContent = '✕';
    close.addEventListener('click', () => { box.style.display = 'none'; });
    bar.append(title, close);

    let body = document.createElement('pre');
    body.className = 'shader-error-body';

    box.append(bar, body);
    box.body = body;
    box.titleEl = title;
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


// the link-failure handler: (gl, program, vertexShader, fragmentShader)
export function showShaderError(gl, program, vs, fs){
    let fragLog = (gl.getShaderInfoLog(fs) || '').trim();
    let vertLog = (gl.getShaderInfoLog(vs) || '').trim();
    let progLog = (gl.getProgramInfoLog(program) || '').trim();
    let log = fragLog || vertLog || progLog || 'Unknown shader link error.';

    //the failing shader is (almost always) the fragment shader here
    let source  = gl.getShaderSource(fs) || '';
    let snippet = fragLog ? sourceSnippet(source, errorLines(fragLog)) : '';

    //keep the console output too
    console.error('Shader error:\n' + log + (snippet ? '\n\n' + snippet : ''));

    showError('Shader compile error', log + (snippet ? '\n\n' + snippet : ''));
}


// put any message up in the overlay (a title bar and a monospace body)
export function showError(title, text){
    let el = ensureBox();
    el.titleEl.textContent = title;
    el.style.display = 'flex';
    el.body.textContent = text;
}


// route uncaught errors and rejections into the overlay. Installed once, when
// createScene is imported — before the scene's main.js runs emit().
let watching = false;
export function watchErrors(){
    if(watching) return;
    watching = true;
    window.addEventListener('error', (e) => showError('Scene error', e.error?.stack ?? e.message));
    window.addEventListener('unhandledrejection', (e) => showError('Scene error', e.reason?.stack ?? String(e.reason)));
}
