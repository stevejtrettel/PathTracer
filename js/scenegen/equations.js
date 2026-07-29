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
//
// Stage 1 is deliberately pure: no GLSL emission (stage 2), no statement
// bodies (stage 5), no imports, no side effects. The dual arithmetic here is
// the REFERENCE for what dualNumbers.glsl's vec4 overloads must compute —
// keep the two in lockstep, formula for formula.
//-------------------------------------------------


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

    return {name, src, arity: eq.arity, params: eq.params, checked, degree,
            ok: failures.length === 0, failures};
}
