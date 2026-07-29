//-------------------------------------------------
// EQUATIONS — the variety equation transpiler, stage 1
// (docs/equation-transpiler.md; the parent design is docs/variety-builder.md)
//
// An equation is authored as the GLSL expression subset — a string that is
// simultaneously valid float GLSL and valid input here (`^` integer powers
// are the one piece of sugar). This module owns:
//
//   parse      the expression grammar -> AST (coords x y z w, free params,
//              the function vocabulary). `w` appearing = a 4-ary/projective
//              source; capability is the SIGNATURE, never the body (§4).
//   evaluate   the AST two ways in JS float64: FLOAT (plain arithmetic) and
//              DUAL — the exact vec4 forward-mode semantics the emitted GLSL
//              will compute: (value, dx, dy, dz), one pass, three tangents.
//   verify     the self-check gate (§5): dual value vs float value, dual
//              gradient vs central differences, and for 4-ary sources the
//              NUMERIC homogeneity check — the sole homogeneity authority.
//   emit       (stage 2) the same AST as GLSL vec4 forward-mode arithmetic:
//              the scalar/dual kind rule, hand-catalogue power locals, and
//              the affine data_ wrapper. Pinned by byte-exact fixtures in
//              render-tests/equations/emitted/ (--equations --write bakes).
//
// Statement bodies arrive at stage 5; the stereo/patch wrappers at stage 4.
// The dual arithmetic here is the REFERENCE for what dualNumbers.glsl's vec4
// overloads must compute — keep the two in lockstep, formula for formula.
//-------------------------------------------------

import {fnum} from './fmt.js';


//the function vocabulary (docs/equation-transpiler.md §3) — name -> arity.
//Adding one = a row here, a dual rule in D_FNS below, and (stage 3) the vec4
//overload in dualNumbers.glsl.
const FNS = {sin: 1, cos: 1, tan: 1, exp: 1, sqrt: 1};

const COORDS = new Set(['x', 'y', 'z', 'w']);


//-------------------------------------------------
// parsing — tokenizer + a small Pratt parser
// precedence: ^ (integer literal only) > unary - > * / > + -
//-------------------------------------------------

function eqError(msg, src, pos){
    const ctx = src.slice(Math.max(0, pos - 20), pos) + '‸' + src.slice(pos, pos + 20);
    return new Error(`scenegen: equations: ${msg} at position ${pos}: ...${ctx}...`);
}

function tokenize(src){
    const toks = [];
    let i = 0;
    while(i < src.length){
        const c = src[i];
        if(/\s/.test(c)){ i++; continue; }
        if(/[0-9.]/.test(c)){
            const m = src.slice(i).match(/^(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?/);
            if(!m) throw eqError(`cannot read number`, src, i);
            toks.push({t: 'num', v: parseFloat(m[0]), pos: i});
            i += m[0].length;
            continue;
        }
        if(/[A-Za-z_]/.test(c)){
            const m = src.slice(i).match(/^[A-Za-z_]\w*/);
            toks.push({t: 'ident', name: m[0], pos: i});
            i += m[0].length;
            continue;
        }
        if('+-*/^(),'.includes(c)){
            toks.push({t: c, pos: i});
            i++;
            continue;
        }
        throw eqError(`unexpected character '${c}'`, src, i);
    }
    toks.push({t: 'end', pos: src.length});
    return toks;
}

const BINARY_BP = {'+': 10, '-': 10, '*': 20, '/': 20};
const UNARY_BP  = 25;      //^ (30) binds tighter: -x^2 = -(x^2)

export function parseEquation(src){
    if(typeof src !== 'string' || !src.trim()){
        throw new Error('scenegen: equations: expected a non-empty equation string');
    }
    const toks = tokenize(src);
    let at = 0;
    const peek = () => toks[at];
    const next = () => toks[at++];
    const expect = (t, what) => {
        if(peek().t !== t) throw eqError(`expected ${what}`, src, peek().pos);
        return next();
    };

    const params = new Set();
    let usesW = false;

    function nud(){
        const tok = next();
        if(tok.t === 'num'){ return {t: 'num', v: tok.v}; }
        if(tok.t === '('){
            const inner = expr(0);
            expect(')', `')'`);
            return inner;
        }
        if(tok.t === '-'){ return {t: 'neg', a: expr(UNARY_BP)}; }
        if(tok.t === '+'){ return expr(UNARY_BP); }
        if(tok.t === 'ident'){
            if(peek().t === '('){
                const arity = FNS[tok.name];
                if(arity === undefined){
                    throw eqError(`unknown function '${tok.name}' (have: ${Object.keys(FNS).join(', ')})`, src, tok.pos);
                }
                next();      //'('
                const args = [expr(0)];
                while(peek().t === ','){ next(); args.push(expr(0)); }
                expect(')', `')'`);
                if(args.length !== arity){
                    throw eqError(`${tok.name}() takes ${arity} argument${arity === 1 ? '' : 's'}, got ${args.length}`, src, tok.pos);
                }
                return {t: 'call', fn: tok.name, args};
            }
            if(COORDS.has(tok.name)){
                if(tok.name === 'w') usesW = true;
                return {t: 'var', name: tok.name};
            }
            params.add(tok.name);
            return {t: 'param', name: tok.name};
        }
        throw eqError(`expected a value`, src, tok.pos);
    }

    function expr(minBp){
        let left = nud();
        for(;;){
            const tok = peek();
            if(tok.t === '^'){
                if(30 <= minBp) break;
                next();
                const e = peek();
                if(e.t !== 'num' || !Number.isInteger(e.v) || e.v < 0){
                    throw eqError(`'^' needs a nonnegative integer literal exponent (use / for negative powers)`, src, e.pos);
                }
                next();
                left = {t: 'pow', a: left, n: e.v};
                continue;
            }
            const bp = BINARY_BP[tok.t];
            if(bp === undefined || bp <= minBp) break;
            next();
            left = {t: tok.t === '+' ? 'add' : tok.t === '-' ? 'sub' : tok.t === '*' ? 'mul' : 'div',
                    a: left, b: expr(bp)};
        }
        return left;
    }

    const ast = expr(0);
    expect('end', 'end of equation');

    if(!/\b[xyz]\b/.test(src) && !usesW){
        throw new Error(`scenegen: equations: the equation uses no coordinate (x, y, z, w) — a constant has no zero set`);
    }
    for(const p of params){
        if(p === 'p' || p === 'v' || /^[xyzw]\d+$/.test(p)){
            throw new Error(`scenegen: equations: parameter '${p}' collides with the emitted wrapper's `
                + `locals (p, v, and power locals like x2) — rename it`);
        }
        if(p in FNS){
            throw new Error(`scenegen: equations: '${p}' is a function — call it with an argument`);
        }
    }

    return {src, ast, params: [...params].sort(), arity: usesW ? 4 : 3};
}


//-------------------------------------------------
// float evaluation — plain arithmetic, the value the author wrote
//-------------------------------------------------

const F_FNS = {sin: Math.sin, cos: Math.cos, tan: Math.tan, exp: Math.exp, sqrt: Math.sqrt};

export function evalFloat(node, env){
    switch(node.t){
        case 'num':   return node.v;
        case 'var':   return env[node.name];
        case 'param': return env[node.name];
        case 'neg':   return -evalFloat(node.a, env);
        case 'add':   return evalFloat(node.a, env) + evalFloat(node.b, env);
        case 'sub':   return evalFloat(node.a, env) - evalFloat(node.b, env);
        case 'mul':   return evalFloat(node.a, env) * evalFloat(node.b, env);
        case 'div':   return evalFloat(node.a, env) / evalFloat(node.b, env);
        case 'pow':   return Math.pow(evalFloat(node.a, env), node.n);
        case 'call':  return F_FNS[node.fn](evalFloat(node.args[0], env));
    }
    throw new Error(`scenegen: equations: unknown AST node '${node.t}'`);
}


//-------------------------------------------------
// dual evaluation — the vec4 forward-mode semantics, in float64
//
// A dual is [value, dx, dy, dz]. These formulas ARE the contract for the
// vec4 overloads in dualNumbers.glsl (stage 3): tmul/tsqr/tdiv/... must
// compute exactly these, lane for lane.
//-------------------------------------------------

const dnum = (v) => [v, 0, 0, 0];

const dadd = (a, b) => [a[0] + b[0], a[1] + b[1], a[2] + b[2], a[3] + b[3]];
const dsub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2], a[3] - b[3]];
const dneg = (a)    => [-a[0], -a[1], -a[2], -a[3]];

const dmul = (a, b) => [a[0]*b[0],
                        a[0]*b[1] + b[0]*a[1],
                        a[0]*b[2] + b[0]*a[2],
                        a[0]*b[3] + b[0]*a[3]];

const dsqr = (a) => [a[0]*a[0], 2*a[0]*a[1], 2*a[0]*a[2], 2*a[0]*a[3]];

const ddiv = (a, b) => {
    const s = b[0]*b[0];
    return [a[0]/b[0],
            (b[0]*a[1] - a[0]*b[1])/s,
            (b[0]*a[2] - a[0]*b[2])/s,
            (b[0]*a[3] - a[0]*b[3])/s];
};

//integer power by binary exponentiation over dsqr/dmul — the same op chain
//the emitter will write (stage 2), so the numerics line up exactly
function dpow(a, n){
    if(n === 0) return dnum(1);
    if(n === 1) return a;
    return (n % 2 === 0) ? dsqr(dpow(a, n/2)) : dmul(a, dpow(a, n - 1));
}

const chain = (v, dv, a) => [v, dv*a[1], dv*a[2], dv*a[3]];

const D_FNS = {
    sin:  (a) => chain(Math.sin(a[0]),  Math.cos(a[0]), a),
    cos:  (a) => chain(Math.cos(a[0]), -Math.sin(a[0]), a),
    tan:  (a) => chain(Math.tan(a[0]), 1/(Math.cos(a[0])*Math.cos(a[0])), a),
    exp:  (a) => chain(Math.exp(a[0]),  Math.exp(a[0]), a),
    sqrt: (a) => { const r = Math.sqrt(a[0]); return chain(r, 0.5/r, a); },
};

export function evalDual(node, env){
    switch(node.t){
        case 'num':   return dnum(node.v);
        case 'var':   return env[node.name];
        case 'param': return env[node.name];
        case 'neg':   return dneg(evalDual(node.a, env));
        case 'add':   return dadd(evalDual(node.a, env), evalDual(node.b, env));
        case 'sub':   return dsub(evalDual(node.a, env), evalDual(node.b, env));
        case 'mul':   return dmul(evalDual(node.a, env), evalDual(node.b, env));
        case 'div':   return ddiv(evalDual(node.a, env), evalDual(node.b, env));
        case 'pow':   return dpow(evalDual(node.a, env), node.n);
        case 'call':  return D_FNS[node.fn](evalDual(node.args[0], env));
    }
    throw new Error(`scenegen: equations: unknown AST node '${node.t}'`);
}

const dscale = (s, a) => [s*a[0], s*a[1], s*a[2], s*a[3]];

//the inverse stereographic lift, float and dual — the dual form mirrors the
//vec4 invStereo overload in dualNumbers.glsl op for op
function liftStereo(pt){
    const d = 1 + pt.x*pt.x + pt.y*pt.y + pt.z*pt.z;
    return {x: 2*pt.x/d, y: 2*pt.y/d, z: 2*pt.z/d, w: (d - 2)/d};
}

function liftStereoDual(pt){
    const x = [pt.x, 1, 0, 0], y = [pt.y, 0, 1, 0], z = [pt.z, 0, 0, 1];
    const denom = dadd(dadd(dadd(dnum(1), dsqr(x)), dsqr(y)), dsqr(z));
    const wNum  = dsub(denom, dnum(2));
    return {x: dscale(2, ddiv(x, denom)),
            y: dscale(2, ddiv(y, denom)),
            z: dscale(2, ddiv(z, denom)),
            w: ddiv(wNum, denom)};
}

//the standard seeding: x/y/z carry the three tangents, w (4-ary) rides as a
//scalar. `seedW` instead puts THE tangent on w (x/y/z scalar) — how the
//verify pass reaches the fourth partial with a three-lane dual.
function dualEnv(eq, pt, params, seedW = false){
    const env = {};
    if(seedW){
        env.x = dnum(pt.x); env.y = dnum(pt.y); env.z = dnum(pt.z);
        env.w = [pt.w, 1, 0, 0];
    }
    else{
        env.x = [pt.x, 1, 0, 0];
        env.y = [pt.y, 0, 1, 0];
        env.z = [pt.z, 0, 0, 1];
        if(eq.arity === 4) env.w = dnum(pt.w);
    }
    for(const p of eq.params) env[p] = dnum(params[p]);
    return env;
}

function floatEnv(eq, pt, params){
    const env = {x: pt.x, y: pt.y, z: pt.z};
    if(eq.arity === 4) env.w = pt.w;
    for(const p of eq.params) env[p] = params[p];
    return env;
}


//-------------------------------------------------
// the verification gate (docs/equation-transpiler.md §5)
//-------------------------------------------------

//deterministic RNG (mulberry32) — Date/Math.random stay out of the gate so a
//failure reproduces exactly
function makeRng(seed){
    let s = seed >>> 0;
    return () => {
        s = (s + 0x6D2B79F5) >>> 0;
        let t = s;
        t = Math.imul(t ^ (t >>> 15), t | 1);
        t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
        return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
}

const relClose = (a, b, rtol) => Math.abs(a - b) <= rtol*Math.max(1, Math.abs(a), Math.abs(b));

//`params` must cover the equation's free identifiers exactly — the same
//loud-cover rule the scene schema will enforce
export function checkParams(eq, params = {}){
    const given = Object.keys(params).sort();
    const need  = eq.params;
    const missing = need.filter(n => !(n in params));
    const extra   = given.filter(n => !need.includes(n));
    if(missing.length || extra.length){
        throw new Error(`scenegen: equations: params must cover the equation's free identifiers exactly — `
            + (missing.length ? `missing: ${missing.join(', ')}` : '')
            + (missing.length && extra.length ? '; ' : '')
            + (extra.length ? `unused: ${extra.join(', ')}` : ''));
    }
}

export function verifyEquation({name = '(unnamed)', src, params = {}},
                               {points = 2000, seed = 12345} = {}){
    const eq = parseEquation(src);
    checkParams(eq, params);

    const rng  = makeRng(seed);
    const coord = () => rng()*4 - 2;                //uniform in [-2, 2]
    const F = (pt) => evalFloat(eq.ast, floatEnv(eq, pt, params));

    const failures = [];
    const usable = (v) => Number.isFinite(v) && Math.abs(v) < 1e12;

    //--- value + gradient, dual vs float --------------------------------
    let checked = 0, attempts = 0;
    while(checked < points && attempts < points*20){
        attempts++;
        const pt = {x: coord(), y: coord(), z: coord(), w: eq.arity === 4 ? coord() : 0};
        const f = F(pt);
        if(!usable(f)) continue;                     //poles, overflow: resample

        const d = evalDual(eq.ast, dualEnv(eq, pt, params));
        if(!relClose(d[0], f, 1e-9)){
            failures.push({kind: 'value', pt, float: f, dual: d[0]});
            if(failures.length >= 5) break;
        }

        //central differences per coordinate, scale-aware step
        const names = eq.arity === 4 ? ['x', 'y', 'z', 'w'] : ['x', 'y', 'z'];
        const dw = eq.arity === 4 ? evalDual(eq.ast, dualEnv(eq, pt, params, true)) : null;
        const analytic = (i) => (i < 3) ? d[i + 1] : dw[1];
        let ok = true;
        for(let i = 0; i < names.length && ok; i++){
            const h  = 1e-5*Math.max(1, Math.abs(pt[names[i]]));
            const pa = {...pt, [names[i]]: pt[names[i]] + h};
            const pb = {...pt, [names[i]]: pt[names[i]] - h};
            const fa = F(pa), fb = F(pb);
            if(!usable(fa) || !usable(fb)){ ok = false; continue; }     //kissed a pole: drop the point
            const num = (fa - fb)/(2*h);
            if(!relClose(analytic(i), num, 1e-4)){
                failures.push({kind: 'gradient', coord: names[i], pt, analytic: analytic(i), numeric: num});
                if(failures.length >= 5){ ok = false; }
            }
        }
        if(failures.length >= 5) break;
        checked++;
    }
    if(checked < points && failures.length === 0){
        failures.push({kind: 'sampling', note: `only ${checked}/${points} usable sample points in [-2,2]^${eq.arity === 4 ? 4 : 3}`});
    }

    //--- homogeneity, 4-ary only: fit one integer degree numerically ----
    //(the SOLE homogeneity authority — body-agnostic by design, §4/§5)
    let degree = null;
    if(eq.arity === 4 && failures.length === 0){
        const fits = [];
        let tries = 0;
        while(fits.length < 200 && tries < 4000){
            tries++;
            const pt = {x: coord(), y: coord(), z: coord(), w: coord()};
            const f = F(pt);
            if(!usable(f) || Math.abs(f) < 1e-6) continue;
            const lam = 1.7;
            const fl = F({x: lam*pt.x, y: lam*pt.y, z: lam*pt.z, w: lam*pt.w});
            if(!usable(fl) || Math.abs(fl) < 1e-12) continue;
            fits.push({pt, d: Math.log(Math.abs(fl/f))/Math.log(lam)});
        }
        const d0 = Math.round(fits[0].d);
        const off = fits.find(s => Math.abs(s.d - d0) > 1e-3);
        if(off){
            failures.push({kind: 'homogeneity', note: 'fitted degrees disagree — the source is not homogeneous',
                           a: {pt: fits[0].pt, degree: fits[0].d}, b: {pt: off.pt, degree: off.d}});
        }
        else{
            //confirm at a second scale, against the fitted integer
            const lam = 2.3;
            const bad = fits.slice(0, 50).find(({pt}) => {
                const f  = F(pt);
                const fl = F({x: lam*pt.x, y: lam*pt.y, z: lam*pt.z, w: lam*pt.w});
                return !relClose(fl, Math.pow(lam, d0)*f, 1e-6);
            });
            if(bad){
                failures.push({kind: 'homogeneity', note: `F(λp) != λ^${d0}·F(p) at the second scale`, pt: bad.pt});
            }
            else{ degree = d0; }
        }
    }

    //--- the two R³ views, composed — what actually marches (stage 4) ---
    //stereo: chain rule through the lift; patch: w pinned to 1. Both dual
    //composites vs central differences of the float composite.
    if(eq.arity === 4 && failures.length === 0){
        const pdual = Object.fromEntries(eq.params.map(p => [p, dnum(params[p])]));
        const views = [
            {kind: 'stereo-composite',
             F: (pt) => evalFloat(eq.ast, floatEnv(eq, liftStereo(pt), params)),
             D: (pt) => evalDual(eq.ast, {...liftStereoDual(pt), ...pdual})},
            {kind: 'patch-composite',
             F: (pt) => evalFloat(eq.ast, floatEnv(eq, {...pt, w: 1}, params)),
             D: (pt) => evalDual(eq.ast, {x: [pt.x, 1, 0, 0], y: [pt.y, 0, 1, 0],
                                          z: [pt.z, 0, 0, 1], w: dnum(1), ...pdual})},
        ];
        for(const {kind, F, D} of views){
            let done = 0, tries = 0;
            while(done < 400 && tries < 8000 && failures.length < 5){
                tries++;
                const pt = {x: coord(), y: coord(), z: coord()};
                const f = F(pt);
                if(!usable(f)) continue;
                const d = D(pt);
                if(!relClose(d[0], f, 1e-9)){
                    failures.push({kind, sub: 'value', pt, float: f, dual: d[0]});
                    continue;
                }
                for(const [i, n] of ['x', 'y', 'z'].entries()){
                    const h  = 1e-5*Math.max(1, Math.abs(pt[n]));
                    const fa = F({...pt, [n]: pt[n] + h});
                    const fb = F({...pt, [n]: pt[n] - h});
                    if(!usable(fa) || !usable(fb)) continue;
                    const num = (fa - fb)/(2*h);
                    if(!relClose(d[i + 1], num, 1e-4)){
                        failures.push({kind, sub: 'gradient', coord: n, pt, analytic: d[i + 1], numeric: num});
                        break;
                    }
                }
                done++;
            }
        }
    }

    return {name, src, arity: eq.arity, params: eq.params, checked, degree,
            ok: failures.length === 0, failures};
}


//-------------------------------------------------
// GLSL emission — stage 2 (docs/equation-transpiler.md §3)
//
// The kind rule: a node is SCALAR iff it contains no coordinate — scalars
// emit as plain float arithmetic (parameter soup stays cheap), duals as
// vec4 ops. Native vec4 +, -, unary -, scalar* and dual/scalar are correct
// dual arithmetic and emit as themselves; products of duals emit tmul
// (n-ary up to 4, the vec2 library's own idiom), powers of a bare
// coordinate become cached power locals in the hand-catalogue style
// (x2 = tsqr(x); x3 = tmul(x2, x); x4 = tsqr(x2)), other powers inline
// their tsqr/tmul chains.
//
// Sums are FLATTENED with signs and their scalar terms fold into one
// trailing constant dual — `- vec4(0.1, 0.0, 0.0, 0.0)`, the hand
// catalogue's `- T(0.1, 0)` idiom one lane wider. (So `a - (b + c)` emits
// as `a - b - c`: value-exact, one term per sum — the single sanctioned
// restructuring; there is no other simplification.)
//-------------------------------------------------

function isDualNode(node){
    switch(node.t){
        case 'var':   return true;
        case 'num':   return false;
        case 'param': return false;
        case 'neg':   return isDualNode(node.a);
        case 'pow':   return isDualNode(node.a);
        case 'call':  return isDualNode(node.args[0]);
        default:      return isDualNode(node.a) || isDualNode(node.b);
    }
}

//precedence levels for parenthesization: sum 10, product 20, unary 25
function emitScalar(node, refs, prec = 0){
    const wrap = (text, my) => (prec > my ? `(${text})` : text);
    switch(node.t){
        case 'num':   return fnum(node.v);
        case 'param': return refs[node.name];
        case 'neg':   return wrap(`-${emitScalar(node.a, refs, 25)}`, 12);
        case 'add':   return wrap(`${emitScalar(node.a, refs, 10)} + ${emitScalar(node.b, refs, 10)}`, 10);
        case 'sub':   return wrap(`${emitScalar(node.a, refs, 10)} - ${emitScalar(node.b, refs, 11)}`, 10);
        case 'mul':   return wrap(`${emitScalar(node.a, refs, 20)}*${emitScalar(node.b, refs, 20)}`, 20);
        case 'div':   return wrap(`${emitScalar(node.a, refs, 20)}/${emitScalar(node.b, refs, 21)}`, 20);
        case 'call':  return `${node.fn}(${emitScalar(node.args[0], refs, 0)})`;
        case 'pow': {
            if(node.n === 0) return '1.0';
            if(node.n === 1) return emitScalar(node.a, refs, prec);
            const simple = node.a.t === 'param' || node.a.t === 'num';
            if(simple && node.n <= 4){
                const b = emitScalar(node.a, refs, 20);
                return wrap(Array(node.n).fill(b).join('*'), 20);
            }
            return `pow(${emitScalar(node.a, refs, 0)}, ${fnum(node.n)})`;
        }
    }
    throw new Error(`scenegen: equations: cannot emit scalar '${node.t}'`);
}

const constDual = (text) => `vec4(${text}, 0.0, 0.0, 0.0)`;

//flatten a +/-/neg spine into signed terms — the one restructuring
function flattenSum(node, sign, out){
    if(node.t === 'add'){ flattenSum(node.a, sign, out); flattenSum(node.b, sign, out); return; }
    if(node.t === 'sub'){ flattenSum(node.a, sign, out); flattenSum(node.b, -sign, out); return; }
    if(node.t === 'neg'){ flattenSum(node.a, -sign, out); return; }
    out.push({sign, node});
}

function flattenMul(node, out){
    if(node.t === 'mul'){ flattenMul(node.a, out); flattenMul(node.b, out); return; }
    out.push(node);
}

function emitDual(node, ctx, prec = 0){
    const wrap = (text, my) => (prec > my ? `(${text})` : text);
    switch(node.t){
        case 'var': return node.name;
        case 'neg': return wrap(`-${emitDual(node.a, ctx, 25)}`, 12);

        case 'add':
        case 'sub': {
            const terms = [];
            flattenSum(node, 1, terms);
            const duals   = terms.filter(t => isDualNode(t.node));
            const scalars = terms.filter(t => !isDualNode(t.node));
            let text = '';
            for(const t of duals){
                const e = emitDual(t.node, ctx, 15);
                text = text === ''
                    ? (t.sign > 0 ? e : `-${e}`)
                    : `${text} ${t.sign > 0 ? '+' : '-'} ${e}`;
            }
            if(scalars.length){
                if(scalars.every(t => t.node.t === 'num')){
                    const v = scalars.reduce((s, t) => s + t.sign*t.node.v, 0);
                    if(v > 0)      text += ` + ${constDual(fnum(v))}`;
                    else if(v < 0) text += ` - ${constDual(fnum(-v))}`;
                    //exactly zero: the scalars cancelled — omit the term
                }
                else{
                    //sign-out when every scalar term is negative: - vec4(r*r, ...)
                    const flip = scalars.every(t => t.sign < 0);
                    let s = '';
                    for(const t of scalars){
                        const sign = flip ? -t.sign : t.sign;
                        const e = emitScalar(t.node, ctx.refs, 15);
                        s = s === ''
                            ? (sign > 0 ? e : `-${e}`)
                            : `${s} ${sign > 0 ? '+' : '-'} ${e}`;
                    }
                    text += ` ${flip ? '-' : '+'} ${constDual(s)}`;
                }
            }
            return wrap(text, 10);
        }

        case 'mul': {
            const factors = [];
            flattenMul(node, factors);
            const duals   = factors.filter(isDualNode);
            const scalars = factors.filter(f => !isDualNode(f));
            const sText   = scalars.map(f => emitScalar(f, ctx.refs, 20)).join('*');
            let dText;
            if(duals.length === 1){ dText = emitDual(duals[0], ctx, 20); }
            else{
                let args = duals.map(f => emitDual(f, ctx, 0));
                while(args.length > 4) args.splice(0, 4, `tmul(${args.slice(0, 4).join(', ')})`);
                dText = `tmul(${args.join(', ')})`;
            }
            return wrap(sText ? `${sText}*${dText}` : dText, 20);
        }

        case 'div': {
            const aDual = isDualNode(node.a);
            const bDual = isDualNode(node.b);
            if(aDual && bDual) return `tdiv(${emitDual(node.a, ctx, 0)}, ${emitDual(node.b, ctx, 0)})`;
            if(aDual)          return wrap(`${emitDual(node.a, ctx, 20)}/${emitScalar(node.b, ctx.refs, 21)}`, 20);
            return `tdiv(${constDual(emitScalar(node.a, ctx.refs, 0))}, ${emitDual(node.b, ctx, 0)})`;
        }

        case 'pow': {
            if(node.n === 0) return constDual('1.0');
            if(node.n === 1) return emitDual(node.a, ctx, prec);
            if(node.a.t === 'var'){
                //cached power locals, the hand-catalogue style
                const set = ctx.powers.get(node.a.name) ?? new Set();
                ctx.powers.set(node.a.name, set);
                const need = (n) => {
                    if(n <= 1) return;
                    set.add(n);
                    need(n % 2 === 0 ? n/2 : n - 1);
                };
                need(node.n);
                return `${node.a.name}${node.n}`;
            }
            const inline = (n) => {
                if(n === 1) return emitDual(node.a, ctx, 0);
                if(n % 2 === 0) return `tsqr(${n === 2 ? emitDual(node.a, ctx, 0) : inline(n/2)})`;
                return `tmul(${inline(n - 1)}, ${emitDual(node.a, ctx, 0)})`;
            };
            return inline(node.n);
        }

        case 'call': return `t${node.fn}(${emitDual(node.args[0], ctx, 0)})`;

        //a scalar subtree reaching a dual slot (defensive — callers split kinds)
        default: return constDual(emitScalar(node, ctx.refs, 0));
    }
}

//the data_ wrapper matrix (§3/§4): seeds (or the stereo lift, or the w = 1
//patch), power locals, one expression, and the .yzwx swizzle onto the
//existing data contract (grad, value). The view rule is variety-builder §4:
//capability is the SIGNATURE — a 3-ary source is affine, full stop; a 4-ary
//source defaults to stereo and may opt into the generated patch.
export function emitEquation({name, src, refs = null, view = null}){
    if(typeof name !== 'string' || !/^[A-Za-z_]\w*$/.test(name)){
        throw new Error(`scenegen: equations: emit needs a valid identifier name, got ${JSON.stringify(name)}`);
    }
    const eq = parseEquation(src);
    if(eq.arity === 3){
        if(view === 'stereo'){
            throw new Error(`scenegen: equations: '${name}': the stereo view needs the homogeneous 4-ary `
                + `form — author it (there is no automatic lift); docs/variety-builder.md §4`);
        }
        view = 'affine';
    }
    else{
        view = view ?? 'stereo';
        if(view !== 'stereo' && view !== 'affine'){
            throw new Error(`scenegen: equations: unknown view '${view}' — 'affine' or 'stereo'`);
        }
    }

    const ctx = {refs: {}, powers: new Map()};
    for(const p of eq.params) ctx.refs[p] = refs?.[p] ?? p;

    const body = isDualNode(eq.ast)
        ? emitDual(eq.ast, ctx, 0)
        : constDual(emitScalar(eq.ast, ctx.refs, 0));      //unreachable: parse requires a coordinate

    const lines = [`vec4 data_${name}(vec3 p){`];
    if(eq.arity === 4 && view === 'stereo'){
        lines.push(`    vec4 x, y, z, w;`);
        lines.push(`    invStereo(vec4(p.x, 1.0, 0.0, 0.0),`);
        lines.push(`              vec4(p.y, 0.0, 1.0, 0.0),`);
        lines.push(`              vec4(p.z, 0.0, 0.0, 1.0), x, y, z, w);`);
    }
    else{
        lines.push(`    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);`);
        lines.push(`    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);`);
        lines.push(`    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);`);
        if(eq.arity === 4){
            lines.push(`    vec4 w = vec4(1.0, 0.0, 0.0, 0.0);      //the affine patch: w = 1`);
        }
    }
    for(const v of (eq.arity === 4 ? ['x', 'y', 'z', 'w'] : ['x', 'y', 'z'])){
        const set = ctx.powers.get(v);
        if(!set) continue;
        for(const n of [...set].sort((a, b) => a - b)){
            lines.push(n % 2 === 0
                ? `    vec4 ${v}${n} = tsqr(${n === 2 ? v : v + n/2});`
                : `    vec4 ${v}${n} = tmul(${v}${n - 1}, ${v});`);
        }
    }
    lines.push(`    vec4 v = ${body};`);
    lines.push(`    return v.yzwx;`);
    lines.push(`}`);
    return lines.join('\n') + '\n';
}
