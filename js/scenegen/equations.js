//-------------------------------------------------
// EQUATIONS — the variety equation transpiler
// (docs/equation-transpiler.md; the parent design is docs/variety-builder.md)
//
// An equation is authored as the GLSL expression subset — a string that is
// simultaneously valid float GLSL and valid input here (`^` integer powers
// are the one piece of sugar) — or, catalogue-style, as STANDARD FLOAT GLSL
// FUNCTIONS whose bodies carry the statement whitelist (counted `for`,
// `if`/`else`, reassignment, helper functions). This module owns:
//
//   parse      expression strings (parseEquation) and function sources
//              (parseFunctions). `w` in a string / a 4-ary signature = a
//              projective source; capability is the SIGNATURE, never the
//              body (variety-builder §4).
//   evaluate   everything two ways in JS float64: FLOAT (plain arithmetic)
//              and DUAL — the exact vec4 forward-mode semantics the emitted
//              GLSL computes: (value, dx, dy, dz), one pass, three tangents.
//              Statement bodies run through a small interpreter.
//   verify     the self-check gate (§5): dual value vs float value, dual
//              gradient vs central differences, numeric homogeneity for
//              4-ary sources (the sole homogeneity authority), and the two
//              composed R³ views (stereo lift, w = 1 patch).
//   emit       the same AST as GLSL: the scalar/dual kind rule,
//              hand-catalogue power locals, dual TWINS of statement
//              functions (vec4 overloads of the float originals), and the
//              data_ wrapper matrix. Pinned by byte-exact fixtures in
//              render-tests/equations/emitted/ (--equations --write bakes).
//
// The dual arithmetic here is the REFERENCE for what dualNumbers.glsl's
// vec4 overloads must compute — keep the two in lockstep, formula for
// formula.
//-------------------------------------------------

import {fnum} from './fmt.js';


//the function vocabulary (docs/equation-transpiler.md §3) — name -> arity.
//Adding one = a row here, a dual rule in D_FNS below, and the vec4 overload
//in dualNumbers.glsl.
const FNS = {sin: 1, cos: 1, tan: 1, exp: 1, sqrt: 1};

const COORDS = new Set(['x', 'y', 'z', 'w']);


//-------------------------------------------------
// tokens — shared by the string and function parsers
//-------------------------------------------------

function eqError(msg, src, pos){
    const ctx = src.slice(Math.max(0, pos - 20), pos) + '‸' + src.slice(pos, pos + 20);
    return new Error(`scenegen: equations: ${msg} at position ${pos}: ...${ctx}...`);
}

const TWO_CHAR = ['<=', '>=', '==', '!=', '++'];

function tokenize(src){
    const toks = [];
    let i = 0;
    while(i < src.length){
        const c = src[i];
        if(/\s/.test(c)){ i++; continue; }
        if(/[0-9.]/.test(c)){
            const m = src.slice(i).match(/^(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?/);
            if(!m) throw eqError(`cannot read number`, src, i);
            toks.push({t: 'num', v: parseFloat(m[0]), int: /^\d+$/.test(m[0]), pos: i});
            i += m[0].length;
            continue;
        }
        if(/[A-Za-z_]/.test(c)){
            const m = src.slice(i).match(/^[A-Za-z_]\w*/);
            toks.push({t: 'ident', name: m[0], pos: i});
            i += m[0].length;
            continue;
        }
        const two = src.slice(i, i + 2);
        if(TWO_CHAR.includes(two)){
            toks.push({t: two, pos: i});
            i += 2;
            continue;
        }
        if('+-*/^(),{};=<>?:'.includes(c)){
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


//-------------------------------------------------
// parsing an equation STRING (scene-level customs)
// precedence: ^ (integer literal only) > unary - > * / > + -
//-------------------------------------------------

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
// parsing FUNCTION SOURCES (catalogue-style standard float GLSL)
//
// The statement whitelist (§3): float/int declarations, reassignment,
// counted `for` over int bounds, `if`/`else`, ternaries, `return`. A
// FORMULA is a function whose leading parameters are 3–4 floats named
// x, y, z(, w), plus trailing float parameters; anything else is a HELPER,
// transpiled too, with a generated vec4 twin. Identifiers must resolve —
// function sources are closed (no free identifiers; scene-string params
// have no analogue here, trailing formula parameters play that role).
//-------------------------------------------------

const stripComments = (s) => s.replace(/\/\*[\s\S]*?\*\//g, ' ').replace(/\/\/[^\n]*/g, ' ');

export function parseFunctions(src){
    const clean = stripComments(src);
    const toks  = tokenize(clean);
    let at = 0;
    const peek = () => toks[at];
    const next = () => toks[at++];
    const expect = (t, what) => {
        if(peek().t !== t) throw eqError(`expected ${what}`, clean, peek().pos);
        return next();
    };
    const kw = (name) => peek().t === 'ident' && peek().name === name;

    const defs = new Map();      //name -> def, in declaration order

    //--- expressions, body flavour: scope-resolved idents, helper calls,
    //    ternaries; same precedence and the same ^ rule as the string form
    function nud(scope){
        const tok = next();
        if(tok.t === 'num'){ return {t: 'num', v: tok.v, int: tok.int}; }
        if(tok.t === '('){
            const inner = valueExpr(scope);
            expect(')', `')'`);
            return inner;
        }
        if(tok.t === '-'){ return {t: 'neg', a: expr(UNARY_BP, scope)}; }
        if(tok.t === '+'){ return expr(UNARY_BP, scope); }
        if(tok.t === 'ident'){
            if(peek().t === '('){
                next();      //'('
                const args = [valueExpr(scope)];
                while(peek().t === ','){ next(); args.push(valueExpr(scope)); }
                expect(')', `')'`);
                if(tok.name in FNS){
                    if(args.length !== FNS[tok.name]){
                        throw eqError(`${tok.name}() takes ${FNS[tok.name]} argument(s), got ${args.length}`, clean, tok.pos);
                    }
                    return {t: 'call', fn: tok.name, args};
                }
                const def = defs.get(tok.name);
                if(!def){
                    throw eqError(`unknown function '${tok.name}' (vocabulary: ${Object.keys(FNS).join(', ')}; `
                        + `defined: ${[...defs.keys()].join(', ') || 'none'})`, clean, tok.pos);
                }
                if(args.length !== def.params.length){
                    throw eqError(`${tok.name}() takes ${def.params.length} argument(s), got ${args.length}`, clean, tok.pos);
                }
                return {t: 'hcall', fn: tok.name, args};
            }
            if(!scope.has(tok.name)){
                throw eqError(`unknown identifier '${tok.name}' — function sources are closed `
                    + `(parameters and locals only)`, clean, tok.pos);
            }
            return {t: 'ident', name: tok.name};
        }
        throw eqError(`expected a value`, clean, tok.pos);
    }

    function expr(minBp, scope){
        let left = nud(scope);
        for(;;){
            const tok = peek();
            if(tok.t === '^'){
                if(30 <= minBp) break;
                next();
                const e = peek();
                if(e.t !== 'num' || !Number.isInteger(e.v) || e.v < 0){
                    throw eqError(`'^' needs a nonnegative integer literal exponent (use / for negative powers)`, clean, e.pos);
                }
                next();
                left = {t: 'pow', a: left, n: e.v};
                continue;
            }
            const bp = BINARY_BP[tok.t];
            if(bp === undefined || bp <= minBp) break;
            next();
            left = {t: tok.t === '+' ? 'add' : tok.t === '-' ? 'sub' : tok.t === '*' ? 'mul' : 'div',
                    a: left, b: expr(bp, scope)};
        }
        return left;
    }

    const CMP = ['<', '>', '<=', '>=', '==', '!='];

    //a full RHS: arithmetic, optionally `cmp ? value : value`
    function valueExpr(scope){
        const a = expr(0, scope);
        if(CMP.includes(peek().t)){
            const op = next().t;
            const b  = expr(0, scope);
            expect('?', `'?' (a comparison only exists as a condition)`);
            const then = valueExpr(scope);
            expect(':', `':'`);
            const els  = valueExpr(scope);
            return {t: 'ternary', cond: {t: 'cmp', op, a, b}, a: then, b: els};
        }
        return a;
    }

    function condition(scope){
        const a  = expr(0, scope);
        const op = CMP.includes(peek().t)
            ? next().t
            : (() => { throw eqError(`expected a comparison (${CMP.join(' ')})`, clean, peek().pos); })();
        return {t: 'cmp', op, a, b: expr(0, scope)};
    }

    //--- statements -----------------------------------------------------
    function block(scope){
        expect('{', `'{'`);
        const stmts = [];
        while(peek().t !== '}'){
            stmts.push(statement(scope));
        }
        next();      //'}'
        return stmts;
    }

    function statement(scope){
        const tok = peek();
        if(tok.t !== 'ident'){
            throw eqError(`expected a statement`, clean, tok.pos);
        }
        if(tok.name === 'while'){
            throw eqError(`'while' is outside the statement whitelist (declarations, assignment, counted `
                + `for, if/else, return) — value-dependent iteration cannot be transpiled; `
                + `author a data: body instead (docs/variety-builder.md §5)`, clean, tok.pos);
        }
        if(tok.name === 'float' || tok.name === 'int'){
            next();
            const name = expect('ident', 'a name').name;
            if(scope.has(name)) throw eqError(`'${name}' is already declared`, clean, tok.pos);
            expect('=', `'='`);
            const e = valueExpr(scope);
            expect(';', `';'`);
            scope.add(name);
            return {t: 'decl', kind: tok.name, name, e};
        }
        if(tok.name === 'for'){
            next();
            expect('(', `'('`);
            if(!kw('int')) throw eqError(`for wants a counted loop: for(int i = ...; i < ...; i++)`, clean, peek().pos);
            next();
            const counter = expect('ident', 'a counter name').name;
            expect('=', `'='`);
            const from = expr(0, scope);
            expect(';', `';'`);
            const c = expect('ident', 'the counter');
            if(c.name !== counter) throw eqError(`the loop condition must test '${counter}'`, clean, c.pos);
            expect('<', `'<' (counted loops only)`);
            const limit = expr(0, scope);
            expect(';', `';'`);
            const c2 = expect('ident', 'the counter');
            if(c2.name !== counter) throw eqError(`the loop increment must step '${counter}'`, clean, c2.pos);
            expect('++', `'++'`);
            expect(')', `')'`);
            const inner = new Set(scope);
            inner.add(counter);
            return {t: 'for', counter, from, limit, body: block(inner)};
        }
        if(tok.name === 'if'){
            next();
            expect('(', `'('`);
            const cond = condition(scope);
            expect(')', `')'`);
            const then = block(new Set(scope));
            let els = null;
            if(kw('else')){
                next();
                els = kw('if') ? [statement(scope)] : block(new Set(scope));
            }
            return {t: 'if', cond, then, els};
        }
        if(tok.name === 'return'){
            next();
            const e = valueExpr(scope);
            expect(';', `';'`);
            return {t: 'ret', e};
        }
        //assignment
        next();
        if(!scope.has(tok.name)){
            throw eqError(`unknown statement or identifier '${tok.name}' — the whitelist is: declarations, `
                + `assignment, counted for, if/else, return`, clean, tok.pos);
        }
        expect('=', `'='`);
        const e = valueExpr(scope);
        expect(';', `';'`);
        return {t: 'assign', name: tok.name, e};
    }

    //--- function definitions -------------------------------------------
    while(peek().t !== 'end'){
        const ret = expect('ident', `'float' (a function definition)`);
        if(ret.name !== 'float'){
            throw eqError(`functions return float (got '${ret.name}')`, clean, ret.pos);
        }
        const name = expect('ident', 'a function name').name;
        if(defs.has(name) || name in FNS){
            throw eqError(`'${name}' is already defined`, clean, ret.pos);
        }
        expect('(', `'('`);
        const params = [];
        if(peek().t !== ')'){
            for(;;){
                const ty = expect('ident', `'float' or 'int'`);
                if(ty.name !== 'float' && ty.name !== 'int'){
                    throw eqError(`parameters are float or int (got '${ty.name}')`, clean, ty.pos);
                }
                params.push({type: ty.name, name: expect('ident', 'a parameter name').name});
                if(peek().t !== ','){ break; }
                next();
            }
        }
        expect(')', `')'`);
        const scope = new Set(params.map(p => p.name));
        const body  = block(scope);
        //the source span (comment-stripped text): a helper's float ORIGINAL
        //is re-emitted verbatim when a scalar-kind call site needs it
        const srcText = clean.slice(ret.pos, toks[at - 1].pos + 1)
            .split('\n').map(l => l.replace(/\s+$/, '')).join('\n');
        const def = {name, params, body, srcText};
        classify(def);
        analyze(def, defs);
        defs.set(name, def);
    }
    if(!defs.size){
        throw new Error('scenegen: equations: no function definitions found');
    }
    return defs;
}

//formula vs helper: a formula's leading params are 3–4 floats named
//x, y, z(, w) in order; anything after is a trailing scalar parameter —
//float or int (the knob hooks; int for things like a Chebyshev order).
//Everything else is a helper.
function classify(def){
    const names = def.params.map(p => p.name);
    const lead  = ['x', 'y', 'z', 'w'];
    let n = 0;
    while(n < 4 && n < def.params.length
          && def.params[n].type === 'float' && names[n] === lead[n]) n++;
    if(n === 3 || n === 4){
        def.formula  = true;
        def.arity    = n;
        def.trailing = def.params.slice(n).map(p => ({name: p.name, type: p.type}));
        return;
    }
    def.formula = false;
}

//kinds: ints (never differentiated), duals (promoted to fixpoint — a float
//assigned a dual anywhere is vec4 throughout). Helper float params are dual
//by construction: the twin's signature is float->vec4. Float expressions may
//not read int names (GLSL ES has no implicit conversion) except as helper
//int arguments and loop machinery.
function analyze(def, defs){
    const ints  = new Set(def.params.filter(p => p.type === 'int').map(p => p.name));
    const duals = new Set(def.formula
        ? def.params.slice(0, def.arity).map(p => p.name)
        : def.params.filter(p => p.type === 'float').map(p => p.name));

    const isDual = (node) => isDualNode(node, duals);

    const walkStmts = (stmts) => {
        let changed = false;
        for(const s of stmts){
            if(s.t === 'decl'){
                if(s.kind === 'int'){ ints.add(s.name); checkInt(s.e, ints, defs); }
                else if(!duals.has(s.name) && isDual(s.e)){ duals.add(s.name); changed = true; }
            }
            if(s.t === 'assign'){
                if(ints.has(s.name)){ checkInt(s.e, ints, defs); }
                else if(def.formula && def.trailing.some(t => t.name === s.name)){
                    throw new Error(`scenegen: equations: '${def.name}' assigns to its parameter '${s.name}' — `
                        + `trailing formula parameters are read-only`);
                }
                else if(!duals.has(s.name) && isDual(s.e)){ duals.add(s.name); changed = true; }
            }
            if(s.t === 'for'){ checkInt(s.from, ints, defs); checkInt(s.limit, ints, defs); changed = walkStmts(s.body) || changed; }
            if(s.t === 'if'){
                changed = walkStmts(s.then) || changed;
                if(s.els) changed = walkStmts(s.els) || changed;
            }
        }
        return changed;
    };
    while(walkStmts(def.body));      //to fixpoint

    //float expressions must not read int names
    const checkFloats = (stmts) => {
        for(const s of stmts){
            if(s.t === 'decl' && s.kind === 'float') checkNoInt(s.e, ints, defs, def.name);
            if(s.t === 'assign' && !ints.has(s.name)) checkNoInt(s.e, ints, defs, def.name);
            if(s.t === 'ret') checkNoInt(s.e, ints, defs, def.name);
            if(s.t === 'for') checkFloats(s.body);
            if(s.t === 'if'){ checkFloats(s.then); if(s.els) checkFloats(s.els); }
        }
    };
    checkFloats(def.body);

    def.ints  = ints;
    def.duals = duals;
}

function checkInt(node, ints, defs){
    const ok = (n) => {
        switch(n.t){
            case 'num':   return n.int === true;
            case 'ident': return ints.has(n.name);
            case 'neg':   return ok(n.a);
            case 'add': case 'sub': case 'mul': return ok(n.a) && ok(n.b);
            default: return false;
        }
    };
    if(!ok(node)){
        throw new Error(`scenegen: equations: expected an int expression (int literals, int names, + - *)`);
    }
}

function checkNoInt(node, ints, defs, where){
    switch(node.t){
        case 'ident':
            if(ints.has(node.name)){
                throw new Error(`scenegen: equations: '${where}' uses int '${node.name}' in a float `
                    + `expression — GLSL ES has no implicit conversion`);
            }
            return;
        case 'hcall': {
            const ps = defs.get(node.fn).params;
            node.args.forEach((a, i) => { if(ps[i].type !== 'int') checkNoInt(a, ints, defs, where); });
            return;
        }
        case 'call':    checkNoInt(node.args[0], ints, defs, where); return;
        case 'neg': case 'pow': checkNoInt(node.a, ints, defs, where); return;
        case 'ternary':
            checkNoInt(node.a, ints, defs, where);
            checkNoInt(node.b, ints, defs, where);
            return;
        case 'add': case 'sub': case 'mul': case 'div':
            checkNoInt(node.a, ints, defs, where);
            checkNoInt(node.b, ints, defs, where);
            return;
    }
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
        case 'ident': return env[node.name];
        case 'neg':   return -evalFloat(node.a, env);
        case 'add':   return evalFloat(node.a, env) + evalFloat(node.b, env);
        case 'sub':   return evalFloat(node.a, env) - evalFloat(node.b, env);
        case 'mul':   return evalFloat(node.a, env) * evalFloat(node.b, env);
        case 'div':   return evalFloat(node.a, env) / evalFloat(node.b, env);
        case 'pow':   return Math.pow(evalFloat(node.a, env), node.n);
        case 'call':  return F_FNS[node.fn](evalFloat(node.args[0], env));
        case 'hcall': return env.__call(node.fn, node.args, env, 'float');
        case 'ternary':
            return evalCmp(node.cond, env, 'float') ? evalFloat(node.a, env) : evalFloat(node.b, env);
    }
    throw new Error(`scenegen: equations: unknown AST node '${node.t}'`);
}


//-------------------------------------------------
// dual evaluation — the vec4 forward-mode semantics, in float64
//
// A dual is [value, dx, dy, dz]. These formulas ARE the contract for the
// vec4 overloads in dualNumbers.glsl: tmul/tsqr/tdiv/... must compute
// exactly these, lane for lane.
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
//the emitter writes, so the numerics line up exactly
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

//a value that may be an int (plain number) or a dual — comparisons and
//helper int arguments read through this
const valOf = (x) => (Array.isArray(x) ? x[0] : x);

function evalCmp(cmp, env, world){
    const ev = world === 'dual' ? evalDual : evalFloat;
    const a = valOf(ev(cmp.a, env));
    const b = valOf(ev(cmp.b, env));
    switch(cmp.op){
        case '<':  return a < b;
        case '>':  return a > b;
        case '<=': return a <= b;
        case '>=': return a >= b;
        case '==': return a === b;
        case '!=': return a !== b;
    }
}

export function evalDual(node, env){
    switch(node.t){
        case 'num':   return dnum(node.v);
        case 'var':   return env[node.name];
        case 'param': return env[node.name];
        case 'ident': return env[node.name];
        case 'neg':   return dneg(evalDual(node.a, env));
        case 'add':   return dadd(evalDual(node.a, env), evalDual(node.b, env));
        case 'sub':   return dsub(evalDual(node.a, env), evalDual(node.b, env));
        case 'mul':   return dmul(evalDual(node.a, env), evalDual(node.b, env));
        case 'div':   return ddiv(evalDual(node.a, env), evalDual(node.b, env));
        case 'pow':   return dpow(evalDual(node.a, env), node.n);
        case 'call':  return D_FNS[node.fn](evalDual(node.args[0], env));
        case 'hcall': return env.__call(node.fn, node.args, env, 'dual');
        case 'ternary':
            return evalCmp(node.cond, env, 'dual') ? evalDual(node.a, env) : evalDual(node.b, env);
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


//-------------------------------------------------
// the statement interpreter — one body, both worlds
//-------------------------------------------------

const LOOP_CAP = 100000;      //runaway backstop; counted loops only, so far above any real formula

function makeCaller(defs){
    const finish = (name, def, env, world) => {
        const ret = execBlock(def.body, env, world, def);
        if(ret === undefined){
            throw new Error(`scenegen: equations: '${name}' returned nothing`);
        }
        return ret;
    };
    const call = (name, argNodes, callerEnv, world) => {
        const def = defs.get(name);
        const ev  = world === 'dual' ? evalDual : evalFloat;
        const env = {__call: call};
        def.params.forEach((p, i) => {
            //int arguments are int-only expressions (validated) — evaluate
            //them as plain floats in EITHER world; int names hold numbers
            env[p.name] = p.type === 'int'
                ? evalFloat(argNodes[i], callerEnv)
                : ev(argNodes[i], callerEnv);
        });
        return finish(name, def, env, world);
    };
    //entry from OUTSIDE the AST: arguments as already-computed values
    const callValues = (name, values, world) => {
        const def = defs.get(name);
        const env = {__call: call};
        def.params.forEach((p, i) => { env[p.name] = p.type === 'int' ? valOf(values[i]) : values[i]; });
        return finish(name, def, env, world);
    };
    return {call, callValues};
}

function execBlock(stmts, env, world, def){
    const ev = world === 'dual' ? evalDual : evalFloat;
    for(const s of stmts){
        switch(s.t){
            case 'decl':
            case 'assign':
                //int slots always evaluate as plain numbers (int-only exprs)
                env[s.name] = def.ints.has(s.name) ? evalFloat(s.e, env) : ev(s.e, env);
                break;
            case 'for': {
                const from  = evalFloat(s.from, env);
                const limit = evalFloat(s.limit, env);
                if(limit - from > LOOP_CAP) throw new Error(`scenegen: equations: loop bound ${limit} is absurd`);
                for(let i = from; i < limit; i++){
                    env[s.counter] = i;
                    const r = execBlock(s.body, env, world, def);
                    if(r !== undefined) return r;
                }
                break;
            }
            case 'if': {
                const r = evalCmp(s.cond, env, world)
                    ? execBlock(s.then, env, world, def)
                    : (s.els ? execBlock(s.els, env, world, def) : undefined);
                if(r !== undefined) return r;
                break;
            }
            case 'ret':
                return world === 'dual' ? evalDual(s.e, env) : evalFloat(s.e, env);
        }
    }
    return undefined;
}


//-------------------------------------------------
// the verification gate (docs/equation-transpiler.md §5)
//
// One core over two closures: F(vals) evaluates the float form at named
// coordinate values; D(dualMap) evaluates the dual form with arbitrary dual
// inputs. Everything — the standard checks, the w-partial, homogeneity, and
// both composed R³ views — derives from those two.
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

function verifyField({arity, F, D}, {points = 2000, seed = 12345} = {}){
    const rng   = makeRng(seed);
    const coord = () => rng()*4 - 2;                //uniform in [-2, 2]
    const usable = (v) => Number.isFinite(v) && Math.abs(v) < 1e12;
    const failures = [];

    const seeds = (pt) => ({x: [pt.x, 1, 0, 0], y: [pt.y, 0, 1, 0], z: [pt.z, 0, 0, 1],
                            ...(arity === 4 ? {w: dnum(pt.w)} : {})});

    //--- value + gradient, dual vs float --------------------------------
    let checked = 0, attempts = 0;
    while(checked < points && attempts < points*20){
        attempts++;
        const pt = {x: coord(), y: coord(), z: coord(), w: arity === 4 ? coord() : 0};
        const f = F(pt);
        if(!usable(f)) continue;                     //poles, overflow: resample

        const d = D(seeds(pt));
        if(!relClose(d[0], f, 1e-9)){
            failures.push({kind: 'value', pt, float: f, dual: d[0]});
            if(failures.length >= 5) break;
        }

        const names = arity === 4 ? ['x', 'y', 'z', 'w'] : ['x', 'y', 'z'];
        const dw = arity === 4
            ? D({x: dnum(pt.x), y: dnum(pt.y), z: dnum(pt.z), w: [pt.w, 1, 0, 0]})
            : null;
        const analytic = (i) => (i < 3) ? d[i + 1] : dw[1];
        for(let i = 0; i < names.length; i++){
            const h  = 1e-5*Math.max(1, Math.abs(pt[names[i]]));
            const fa = F({...pt, [names[i]]: pt[names[i]] + h});
            const fb = F({...pt, [names[i]]: pt[names[i]] - h});
            if(!usable(fa) || !usable(fb)) continue;             //kissed a pole: skip the partial
            const num = (fa - fb)/(2*h);
            if(!relClose(analytic(i), num, 1e-4)){
                failures.push({kind: 'gradient', coord: names[i], pt, analytic: analytic(i), numeric: num});
                break;
            }
        }
        if(failures.length >= 5) break;
        checked++;
    }
    if(checked < points && failures.length === 0){
        failures.push({kind: 'sampling', note: `only ${checked}/${points} usable sample points`});
    }

    //--- homogeneity, 4-ary only: fit one integer degree numerically ----
    //(the SOLE homogeneity authority — body-agnostic by design, §4/§5)
    let degree = null;
    if(arity === 4 && failures.length === 0){
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

    //--- the two R³ views, composed — what actually marches -------------
    if(arity === 4 && failures.length === 0){
        const views = [
            {kind: 'stereo-composite',
             F3: (pt) => F(liftStereo(pt)),
             D3: (pt) => D(liftStereoDual(pt))},
            {kind: 'patch-composite',
             F3: (pt) => F({...pt, w: 1}),
             D3: (pt) => D({x: [pt.x, 1, 0, 0], y: [pt.y, 0, 1, 0], z: [pt.z, 0, 0, 1], w: dnum(1)})},
        ];
        for(const {kind, F3, D3} of views){
            let done = 0, tries = 0;
            while(done < 400 && tries < 8000 && failures.length < 5){
                tries++;
                const pt = {x: coord(), y: coord(), z: coord()};
                const f = F3(pt);
                if(!usable(f)) continue;
                const d = D3(pt);
                if(!relClose(d[0], f, 1e-9)){
                    failures.push({kind, sub: 'value', pt, float: f, dual: d[0]});
                    continue;
                }
                for(const [i, n] of ['x', 'y', 'z'].entries()){
                    const h  = 1e-5*Math.max(1, Math.abs(pt[n]));
                    const fa = F3({...pt, [n]: pt[n] + h});
                    const fb = F3({...pt, [n]: pt[n] - h});
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

    return {checked, degree, failures};
}

//`params` must cover the free identifiers exactly — the same loud-cover
//rule the scene schema will enforce
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

export function verifyEquation({name = '(unnamed)', src, params = {}}, opts = {}){
    const eq = parseEquation(src);
    checkParams(eq, params);

    const pflt  = Object.fromEntries(eq.params.map(p => [p, params[p]]));
    const pdual = Object.fromEntries(eq.params.map(p => [p, dnum(params[p])]));
    const F = (vals) => evalFloat(eq.ast, {...vals, ...pflt});
    const D = (duals) => evalDual(eq.ast, {...duals, ...pdual});

    const {checked, degree, failures} = verifyField({arity: eq.arity, F, D}, opts);
    return {name, src, arity: eq.arity, params: eq.params, checked, degree,
            ok: failures.length === 0, failures};
}

//pick the formula out of a function source: an explicit `formula:` name, or
//the exactly-one rule when unnamed (scene-level sources)
function pickFormula(defs, formula){
    if(formula !== undefined){
        const f = defs.get(formula);
        if(!f || !f.formula){
            throw new Error(`scenegen: equations: no formula named '${formula}' in this source `
                + `(formulas: ${[...defs.values()].filter(d => d.formula).map(d => d.name).join(', ') || 'none'})`);
        }
        return f;
    }
    const formulas = [...defs.values()].filter(d => d.formula);
    if(formulas.length !== 1){
        throw new Error(`scenegen: equations: expected exactly one formula (leading params x, y, z[, w]) — `
            + `found ${formulas.length ? formulas.map(f => f.name).join(', ') : 'none'}`);
    }
    return formulas[0];
}

export function verifyFunctions({name = '(unnamed)', src, params = {}, formula}, opts = {}){
    const defs = parseFunctions(src);
    const f = pickFormula(defs, formula);
    checkParams({params: f.trailing.map(t => t.name)}, params);

    const {callValues} = makeCaller(defs);
    const F = (vals)  => callValues(f.name,
        f.params.map(p => (p.name in vals ? vals[p.name] : params[p.name])), 'float');
    const D = (duals) => callValues(f.name,
        f.params.map(p => (p.name in duals ? duals[p.name] : dnum(params[p.name]))), 'dual');

    const {checked, degree, failures} = verifyField({arity: f.arity, F, D}, opts);
    return {name, src, arity: f.arity, params: f.trailing, checked, degree,
            ok: failures.length === 0, failures};
}


//-------------------------------------------------
// GLSL emission (docs/equation-transpiler.md §3)
//
// The kind rule: a node is SCALAR iff it contains no coordinate (and no
// dual-promoted local) — scalars emit as plain float arithmetic, duals as
// vec4 ops. Native vec4 +, -, unary -, scalar* and dual/scalar are correct
// dual arithmetic and emit as themselves; products of duals emit tmul
// (n-ary up to 4, the vec2 library's own idiom), powers of a bare
// coordinate become cached power locals in the hand-catalogue style,
// other powers inline their tsqr/tmul chains.
//
// Sums are FLATTENED with signs and their scalar terms fold into one
// trailing constant dual — `- vec4(0.1, 0.0, 0.0, 0.0)`, the hand
// catalogue's `- T(0.1, 0)` idiom one lane wider. (So `a - (b + c)` emits
// as `a - b - c`: value-exact, one term per sum — the single sanctioned
// restructuring; there is no other simplification.)
//
// Statement functions emit as DUAL TWINS: same name, float params become
// vec4 (int stays int), statements carried over with each expression
// emitted by its kind — GLSL overloading does the rest. Scalar-kind calls
// to helpers emit the plain name and rely on the float ORIGINAL, which the
// catalogue file itself provides.
//-------------------------------------------------

function isDualNode(node, duals){
    switch(node.t){
        case 'var':   return true;
        case 'num':   return false;
        case 'param': return false;
        case 'ident': return duals ? duals.has(node.name) : false;
        case 'neg':   return isDualNode(node.a, duals);
        case 'pow':   return isDualNode(node.a, duals);
        case 'call':  return isDualNode(node.args[0], duals);
        case 'hcall': return node.args.some(a => isDualNode(a, duals));
        case 'ternary':
            return isDualNode(node.a, duals) || isDualNode(node.b, duals);
        default:      return isDualNode(node.a, duals) || isDualNode(node.b, duals);
    }
}

//precedence levels for parenthesization: sum 10, product 20, unary 25
function emitScalar(node, ctx, prec = 0){
    const wrap = (text, my) => (prec > my ? `(${text})` : text);
    switch(node.t){
        case 'num':   return node.int && ctx.intSlot ? String(node.v) : fnum(node.v);
        case 'param': return ctx.refs[node.name];
        case 'ident': return ctx.refs[node.name] ?? node.name;
        case 'neg':   return wrap(`-${emitScalar(node.a, ctx, 25)}`, 12);
        case 'add':   return wrap(`${emitScalar(node.a, ctx, 10)} + ${emitScalar(node.b, ctx, 10)}`, 10);
        case 'sub':   return wrap(`${emitScalar(node.a, ctx, 10)} - ${emitScalar(node.b, ctx, 11)}`, 10);
        case 'mul':   return wrap(`${emitScalar(node.a, ctx, 20)}*${emitScalar(node.b, ctx, 20)}`, 20);
        case 'div':   return wrap(`${emitScalar(node.a, ctx, 20)}/${emitScalar(node.b, ctx, 21)}`, 20);
        case 'call':  return `${node.fn}(${emitScalar(node.args[0], ctx, 0)})`;
        case 'hcall': {
            //a scalar-kind helper call runs the float ORIGINAL — mark it
            //(and its own callees, transitively) for verbatim re-emission
            if(ctx.needFloat){
                for(const fn of callClosure(ctx.defs.get(node.fn), ctx.defs)) ctx.needFloat.add(fn);
            }
            const ps = ctx.defs.get(node.fn).params;
            return `${node.fn}(${node.args.map((a, i) =>
                ps[i].type === 'int' ? emitInt(a, ctx, 0) : emitScalar(a, ctx, 0)).join(', ')})`;
        }
        case 'ternary':
            return wrap(`${emitCond(node.cond, ctx)} ? ${emitScalar(node.a, ctx, 6)} : ${emitScalar(node.b, ctx, 6)}`, 5);
        case 'pow': {
            if(node.n === 0) return '1.0';
            if(node.n === 1) return emitScalar(node.a, ctx, prec);
            const simple = node.a.t === 'param' || node.a.t === 'num' || node.a.t === 'ident';
            if(simple && node.n <= 4){
                const b = emitScalar(node.a, ctx, 20);
                return wrap(Array(node.n).fill(b).join('*'), 20);
            }
            return `pow(${emitScalar(node.a, ctx, 0)}, ${fnum(node.n)})`;
        }
    }
    throw new Error(`scenegen: equations: cannot emit scalar '${node.t}'`);
}

//int expressions (loop machinery, int helper arguments)
function emitInt(node, ctx, prec = 0){
    const wrap = (text, my) => (prec > my ? `(${text})` : text);
    switch(node.t){
        case 'num':   return String(node.v);
        case 'ident': return node.name;
        case 'neg':   return wrap(`-${emitInt(node.a, ctx, 25)}`, 12);
        case 'add':   return wrap(`${emitInt(node.a, ctx, 10)} + ${emitInt(node.b, ctx, 10)}`, 10);
        case 'sub':   return wrap(`${emitInt(node.a, ctx, 10)} - ${emitInt(node.b, ctx, 11)}`, 10);
        case 'mul':   return wrap(`${emitInt(node.a, ctx, 20)}*${emitInt(node.b, ctx, 20)}`, 20);
    }
    throw new Error(`scenegen: equations: cannot emit int expression '${node.t}'`);
}

//a helper-call argument, by the CALLEE's parameter kind
function emitArg(node, i, fn, ctx){
    const p = ctx.defs.get(fn).params[i];
    if(p.type === 'int') return emitInt(node, ctx, 0);
    return isDualNode(node, ctx.duals)
        ? emitDual(node, ctx, 0)
        : constDual(emitScalar(node, ctx, 0));
}

//a comparison — a dual operand reads its VALUE lane
function emitCond(cmp, ctx){
    const side = (n) => {
        if(ctx.ints && onlyInts(n, ctx.ints)) return emitInt(n, ctx, 8);
        return isDualNode(n, ctx.duals)
            ? `${emitDual(n, ctx, 30)}.x`
            : emitScalar(n, ctx, 8);
    };
    return `${side(cmp.a)} ${cmp.op} ${side(cmp.b)}`;
}

function onlyInts(node, ints){
    switch(node.t){
        case 'num':   return node.int === true;
        case 'ident': return ints.has(node.name);
        case 'neg':   return onlyInts(node.a, ints);
        case 'add': case 'sub': case 'mul':
            return onlyInts(node.a, ints) && onlyInts(node.b, ints);
        default: return false;
    }
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
        case 'var':   return node.name;
        case 'ident': return node.name;
        case 'neg':   return wrap(`-${emitDual(node.a, ctx, 25)}`, 12);

        case 'add':
        case 'sub': {
            const terms = [];
            flattenSum(node, 1, terms);
            const duals   = terms.filter(t => isDualNode(t.node, ctx.duals));
            const scalars = terms.filter(t => !isDualNode(t.node, ctx.duals));
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
                        const e = emitScalar(t.node, ctx, 15);
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
            const duals   = factors.filter(f => isDualNode(f, ctx.duals));
            const scalars = factors.filter(f => !isDualNode(f, ctx.duals));
            const sText   = scalars.map(f => emitScalar(f, ctx, 20)).join('*');
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
            const aDual = isDualNode(node.a, ctx.duals);
            const bDual = isDualNode(node.b, ctx.duals);
            if(aDual && bDual) return `tdiv(${emitDual(node.a, ctx, 0)}, ${emitDual(node.b, ctx, 0)})`;
            if(aDual)          return wrap(`${emitDual(node.a, ctx, 20)}/${emitScalar(node.b, ctx, 21)}`, 20);
            return `tdiv(${constDual(emitScalar(node.a, ctx, 0))}, ${emitDual(node.b, ctx, 0)})`;
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

        case 'call':  return `t${node.fn}(${emitDual(node.args[0], ctx, 0)})`;
        case 'hcall': return `${node.fn}(${node.args.map((a, i) => emitArg(a, i, node.fn, ctx)).join(', ')})`;
        case 'ternary':
            return wrap(`${emitCond(node.cond, ctx)} ? ${emitDualOr(node.a, ctx)} : ${emitDualOr(node.b, ctx)}`, 5);

        //a scalar subtree reaching a dual slot (defensive — callers split kinds)
        default: return constDual(emitScalar(node, ctx, 0));
    }
}

//a dual-valued slot whose expression may be scalar-kind (ternary branches,
//returns): promote through the constant dual
function emitDualOr(node, ctx){
    return isDualNode(node, ctx.duals) ? emitDual(node, ctx, 6) : constDual(emitScalar(node, ctx, 0));
}

//the seed lines shared by every wrapper form
const SEED_LINES = [
    `    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);`,
    `    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);`,
    `    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);`,
];

function resolveView(name, arity, view){
    if(arity === 3){
        if(view === 'stereo'){
            throw new Error(`scenegen: equations: '${name}': the stereo view needs the homogeneous 4-ary `
                + `form — author it (there is no automatic lift); docs/variety-builder.md §4`);
        }
        return 'affine';
    }
    view = view ?? 'stereo';
    if(view !== 'stereo' && view !== 'affine'){
        throw new Error(`scenegen: equations: unknown view '${view}' — 'affine' or 'stereo'`);
    }
    return view;
}

function wrapperHead(name, arity, view){
    const lines = [`vec4 data_${name}(vec3 p){`];
    if(arity === 4 && view === 'stereo'){
        lines.push(`    vec4 x, y, z, w;`);
        lines.push(`    invStereo(vec4(p.x, 1.0, 0.0, 0.0),`);
        lines.push(`              vec4(p.y, 0.0, 1.0, 0.0),`);
        lines.push(`              vec4(p.z, 0.0, 0.0, 1.0), x, y, z, w);`);
    }
    else{
        lines.push(...SEED_LINES);
        if(arity === 4){
            lines.push(`    vec4 w = vec4(1.0, 0.0, 0.0, 0.0);      //the affine patch: w = 1`);
        }
    }
    return lines;
}

//the data_ wrapper matrix (§3/§4) over an equation STRING: seeds (or the
//stereo lift, or the w = 1 patch), power locals, one expression, and the
//.yzwx swizzle onto the existing data contract (grad, value). The view rule
//is variety-builder §4: capability is the SIGNATURE — a 3-ary source is
//affine, full stop; a 4-ary source defaults to stereo and may opt into the
//generated patch.
export function emitEquation({name, src, refs = null, view = null}){
    if(typeof name !== 'string' || !/^[A-Za-z_]\w*$/.test(name)){
        throw new Error(`scenegen: equations: emit needs a valid identifier name, got ${JSON.stringify(name)}`);
    }
    const eq = parseEquation(src);
    view = resolveView(name, eq.arity, view);

    const ctx = {refs: {}, powers: new Map()};
    for(const p of eq.params) ctx.refs[p] = refs?.[p] ?? p;

    const body = isDualNode(eq.ast, null)
        ? emitDual(eq.ast, ctx, 0)
        : constDual(emitScalar(eq.ast, ctx, 0));      //unreachable: parse requires a coordinate

    const lines = wrapperHead(name, eq.arity, view);
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

//statement emission — one function's dual twin, statements carried over
function emitStmts(stmts, ctx, indent){
    const pad = '    '.repeat(indent);
    const lines = [];
    const rhs = (name, e) => {
        if(ctx.ints.has(name)) return emitInt(e, ctx, 0);
        return ctx.duals.has(name)
            ? emitDualOr(e, ctx)
            : emitScalar(e, ctx, 0);
    };
    for(const s of stmts){
        switch(s.t){
            case 'decl': {
                const ty = s.kind === 'int' ? 'int' : (ctx.duals.has(s.name) ? 'vec4' : 'float');
                lines.push(`${pad}${ty} ${s.name} = ${rhs(s.name, s.e)};`);
                break;
            }
            case 'assign':
                lines.push(`${pad}${s.name} = ${rhs(s.name, s.e)};`);
                break;
            case 'for':
                lines.push(`${pad}for(int ${s.counter} = ${emitInt(s.from, ctx, 0)}; `
                    + `${s.counter} < ${emitInt(s.limit, ctx, 0)}; ${s.counter}++){`);
                lines.push(...emitStmts(s.body, ctx, indent + 1));
                lines.push(`${pad}}`);
                break;
            case 'if':
                lines.push(`${pad}if(${emitCond(s.cond, ctx)}){`);
                lines.push(...emitStmts(s.then, ctx, indent + 1));
                if(s.els){
                    lines.push(`${pad}}`);
                    lines.push(`${pad}else{`);
                    lines.push(...emitStmts(s.els, ctx, indent + 1));
                }
                lines.push(`${pad}}`);
                break;
            case 'ret':
                lines.push(`${pad}return ${emitDualOr(s.e, ctx)};`);
                break;
        }
    }
    return lines;
}

//the functions a formula transitively calls (helpers only — vocabulary
//calls are engine-global)
function callClosure(f, defs){
    const keep = new Set([f.name]);
    const walkNode = (n) => {
        if(!n || typeof n !== 'object') return;
        if(n.t === 'hcall' && !keep.has(n.fn)){
            keep.add(n.fn);
            walkStmts(defs.get(n.fn).body);
        }
        if(n.args) n.args.forEach(walkNode);
        if(n.cond) walkNode(n.cond);
        walkNode(n.a); walkNode(n.b); walkNode(n.e);
    };
    const walkStmts = (stmts) => {
        for(const s of stmts){
            walkNode(s.e); walkNode(s.from); walkNode(s.limit); walkNode(s.cond);
            if(s.then) walkStmts(s.then);
            if(s.els)  walkStmts(s.els);
            if(s.body) walkStmts(s.body);
        }
    };
    walkStmts(f.body);
    return keep;
}

//emit a function source set: a dual twin per needed function (same names —
//GLSL overloading), the float ORIGINAL of any helper a scalar-kind call
//site needs, and the data_ wrapper for the formula, calling its twin.
//`formula:` selects out of a many-formula source (a catalogue file); the
//call graph prunes everything the chosen formula does not reach.
export function emitFunctions({name, src, refs = null, view = null, formula}){
    const defs = parseFunctions(src);
    const f = pickFormula(defs, formula);
    name = name ?? f.name;      //the data_ wrapper carries the CALLER's name (the object)
    view = resolveView(name, f.arity, view);

    const keep      = callClosure(f, defs);
    const needFloat = new Set();      //helpers with a scalar-kind call site
    const twins     = new Map();
    for(const def of defs.values()){
        if(!keep.has(def.name)) continue;
        const ctx = {refs: {}, powers: new Map(), duals: def.duals, ints: def.ints, defs, needFloat};
        const params = def.params.map(p => {
            const ty = p.type === 'int' ? 'int' : (def.duals.has(p.name) ? 'vec4' : 'float');
            return `${ty} ${p.name}`;
        }).join(', ');
        const body = emitStmts(def.body, ctx, 1);
        twins.set(def.name, [`vec4 ${def.name}(${params}){`, ...body, `}`].join('\n'));
    }

    const pieces = [];
    for(const def of defs.values()){
        if(!keep.has(def.name)) continue;
        if(needFloat.has(def.name)) pieces.push(def.srcText);
        pieces.push(twins.get(def.name));
    }

    //the wrapper: seeds (per view), then one call into the formula's twin —
    //trailing parameters stay SCALAR (the twin's signature keeps them
    //scalar per the kind rule; int stays int), passed as their references
    const trail = f.trailing.map(p => `, ${refs?.[p.name] ?? p.name}`).join('');
    const args  = f.params.slice(0, f.arity).map(p => p.name).join(', ');
    const lines = wrapperHead(name, f.arity, view);
    lines.push(`    vec4 v = ${f.name}(${args}${trail});`);
    lines.push(`    return v.yzwx;`);
    lines.push(`}`);
    pieces.push(lines.join('\n'));

    return pieces.join('\n\n') + '\n';
}
