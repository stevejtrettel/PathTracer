//-------------------------------------------------
// SHAPE MODIFIERS — an ordered chain over a library shape
//
//   displace(base, {by, amp})        move the surface by amp*field(q)
//   repLim(base, {spacing, limit})   one region, a folded grid of copies
//   carve(base, {...})               erode it with an fbm of sphere lattices
//   accrete(base, {...})             the same lattice grown ON the surface
//   mirror(base, {axes})             fold across coordinate planes
//   radial(base, {n, axis})          n-fold rotational symmetry about an axis
//   round(base, {r})                 offset the surface outward by r
//   shell(base, {thickness})         keep a skin around the surface
//   clip(base, {to, at, blend})      intersect with a placed cutting volume
//   subtract(base, {what, at, blend})  carve a placed volume away
//   modifier(base, {expr, bound})    the ESCAPE HATCH: an authored field mod
//
// Each modifier takes one shape and returns one shape, so they STACK:
// nesting order = application order, innermost first (docs/shape-modifiers.md).
// A modifier is either a
//
//   domain mod   rewrites the query point BEFORE the base is evaluated
//   field  mod   rewrites the distance AFTER
//
// so a domain mod may not wrap a field mod — by the time a field mod has
// acted, the point is already spent. Field mods that take an infinite field
// (carve, displace) see the FOLDED point, which is what makes "a lattice of
// eroded spheres" mean what it looks like; field mods that take a placed
// volume (clip, subtract) act at the PRE-fold local point instead — a cutter
// is a placed thing, so it cuts the whole assembly, not each folded copy.
//
// A modifier record is plain data plus the plan(fx) closure the planner
// folds (plan.js owns the fold and the rendering; nothing here emits text on
// its own). What the planner derives stays FORMULAIC over declared data:
// displace's Lipschitz divisor (1 + amp*gradBound) and bound inflation
// (maxAbs(range)*amp), the bound kept/inflated/replaced per modifier, and
// the trace routing (no closed form any more -> marched).
//
// plan() receives fx — the fold context (plan.js makeFoldCtx): {name, value(),
// num(), glsl(), token(), cutter(), local} — and returns the planned instance:
//   domain:  {fold(ptExpr) -> exprText}
//   field:   {expr(d, pt) -> exprText,          the operation, expression form
//             frame: 'local' (placed volume) — omitted = the folded point,
//             readsQ, divisor (displace: statement `line` instead of expr),
//             boundEffect: 'keep' | {inflate: text} | {replace: (pt) -> text},
//             helperDefs, uses (cutter machinery)}
//-------------------------------------------------

import {isGlsl} from './glslTag.js';


//append one modifier to a chain, enforcing the rules every modifier obeys:
//phase order (a domain mod cannot act after the distance exists) and the
//true-distance-field requirement (displacement breaks it).
function appendMod(base, mod, call){
    if(!base || !base.__shape){
        throw new Error(`scenegen: ${call}: base must be a lib shape (or a modified one)`);
    }
    const chain = base.mods ?? [];
    if(mod.phase === 'domain'){
        const prior = chain.find(m => m.phase === 'field');
        if(prior){
            throw new Error(`scenegen: ${mod.kind}() is a domain fold, so it must be applied before `
                + `anything that acts on the distance — write ${mod.kind}(...) inside ${prior.kind}(...), not around it`);
        }
    }
    if(mod.requiresTrueDF){
        const broken = chain.find(m => m.breaksTrueDF);
        if(broken){
            throw new Error(`scenegen: ${mod.kind}() needs a true distance field, and ${broken.kind}() `
                + `breaks that — apply ${mod.kind}(...) before ${broken.kind}(...), not after`);
        }
    }
    return {...base, mods: [...chain, mod]};
}

//an integer-valued modifier argument: a whole number in range, or an int knob
//(a GLSL loop count / fold count must stay integral even when live)
function requireInt(fn, what, v, {min, max, why}){
    if(v && v.__knob){
        if(v.type !== 'int'){
            throw new Error(`scenegen: ${fn}(): the ${what} knob '${v.name}' must be type: 'int' (${why})`);
        }
        return;
    }
    const range = max !== undefined ? `in ${min}..${max}` : `>= ${min}`;
    if(!Number.isInteger(v) || v < min || (max !== undefined && v > max)){
        throw new Error(`scenegen: ${fn}(): ${what} must be a whole number ${range}, got ${v}`);
    }
}


export function displace(base, {by, amp} = {}){
    if(!by || !by.__field){
        throw new Error('scenegen: displace(): `by` must be a field()');
    }
    if(amp === undefined) throw new Error('scenegen: displace() needs an amp');
    if(!by.gradBound || !by.range){
        throw new Error(`scenegen: displace(): field '${by.name}' must declare gradBound and range `
            + `to displace geometry (a preset can fill these in — see presets.js)`);
    }
    //the bound is the undisplaced shape pushed out by the largest possible
    //displacement — without the inflation it would shave off the peaks
    const maxAbs = Math.max(Math.abs(by.range[0]), Math.abs(by.range[1]));
    return appendMod(base, {
        kind: 'displace', phase: 'field', breaksTrueDF: true,
        plan(fx){
            const ampT = fx.num(amp, `displace amp of '${fx.name}'`);
            return {
                //statement-only: the += sugar plus the divisor on the return
                //make displacement genuinely statement-shaped
                line: `d += ${ampT}*${by.name}(q);`, readsQ: true,
                divisor: `${ampT}*(${fx.glsl(by.gradBound)})`,
                boundEffect: {inflate: `${fx.num(maxAbs)}*${ampT}`},
            };
        },
    }, 'displace(base, {by, amp})');
}

//EROSION, the structural opposite of displace: it subtracts a distance field
//(opCarveFbm, shapes/ops/carve.glsl) instead of adding a height field, so the result
//is still a distance field. Two things follow, and they are what the planner
//derives: no bound inflation (carving only shrinks the solid, so the UNCARVED
//base already bounds it), and no Lipschitz divisor of its own (the operator
//tracks its octaves' and returns a conservative distance).
//
//FUTURE US: the carving field is built in, the way repLim's fold is. Letting a
//caller pass their own DISTANCE field (`by:`, metadata = a declared Lipschitz
//constant, not displace's {gradBound, range}) is the natural next step and would
//not change any existing call site. Deferred until a second carving field exists.
export function carve(base, {octaves = 6, erosion = 1.0, gain = 0.5, blend = 0.15, seed = 0.0} = {}){
    requireInt('carve', 'octaves', octaves, {min: 1, max: 10, why: 'it is a GLSL loop count'});
    return appendMod(base, {
        kind: 'carve', phase: 'field', requiresTrueDF: true,
        plan(fx){
            const o = fx.value('int',   'OCTAVES', octaves, `carve octaves of '${fx.name}'`);
            const e = fx.value('float', 'EROSION', erosion, `carve erosion of '${fx.name}'`);
            const g = fx.value('float', 'GAIN',    gain,    `carve gain of '${fx.name}'`);
            const b = fx.value('float', 'BLEND',   blend,   `carve blend of '${fx.name}'`);
            const s = fx.value('float', 'SEED',    seed,    `carve seed of '${fx.name}'`);
            return {
                expr: (d, pt) => `opCarveFbm(${pt}, ${d}, ${o}, ${e}, ${g}, ${b}, ${s})`,
                readsQ: true,
                boundEffect: 'keep',
            };
        },
    }, 'carve(base, {...})');
}

//ACCRETION, carve's mirror image: the same fbm sphere lattice GROWS on the
//surface instead of being eaten from it (opAccreteFbm, shapes/ops/carve.glsl).
//The one derivation that flips: accreted material lies OUTSIDE the base, so
//the bound inflates — each octave attaches at most REACH*s past the surface
//plus the smooth-union bulge, and the total over octaves is the geometric
//series (REACH + blend/4)/(1 - gain). That formula is why accrete's gain
//must stay below 1 where carve's may not: the growth itself would diverge.
export function accrete(base, {octaves = 6, erosion = 1.0, gain = 0.5, blend = 0.15, seed = 0.0} = {}){
    requireInt('accrete', 'octaves', octaves, {min: 1, max: 10, why: 'it is a GLSL loop count'});
    if(gain && gain.__knob){
        if(gain.min < 0 || gain.max >= 1){
            throw new Error(`scenegen: accrete(): the gain knob '${gain.name}' must keep its range inside [0, 1) — `
                + `the bound inflation (and the growth) diverge as gain reaches 1`);
        }
    }
    else if(!(typeof gain === 'number' && gain >= 0 && gain < 1)){
        throw new Error(`scenegen: accrete(): gain must be a number in [0, 1) — `
            + `the bound inflation diverges at 1 — got ${JSON.stringify(gain)}`);
    }
    return appendMod(base, {
        kind: 'accrete', phase: 'field', requiresTrueDF: true,
        plan(fx){
            const o = fx.value('int',   'OCTAVES', octaves, `accrete octaves of '${fx.name}'`);
            const e = fx.value('float', 'EROSION', erosion, `accrete erosion of '${fx.name}'`);
            const g = fx.value('float', 'GAIN',    gain,    `accrete gain of '${fx.name}'`);
            const b = fx.value('float', 'BLEND',   blend,   `accrete blend of '${fx.name}'`);
            const s = fx.value('float', 'SEED',    seed,    `accrete seed of '${fx.name}'`);
            return {
                expr: (d, pt) => `opAccreteFbm(${pt}, ${d}, ${o}, ${e}, ${g}, ${b}, ${s})`,
                readsQ: true,
                boundEffect: {inflate: `(ACCRETE_REACH + 0.25*${b})/(1.0 - ${g})`},
            };
        },
    }, 'accrete(base, {...})');
}

export function repLim(base, {spacing, limit} = {}){
    if(spacing === undefined || limit === undefined){
        throw new Error('scenegen: repLim() needs spacing and limit');
    }
    return appendMod(base, {
        kind: 'repLim', phase: 'domain',
        plan(fx){
            const S = fx.value('float', 'SPACING', spacing, `repLim spacing of '${fx.name}'`);
            const L = fx.value('vec3',  'LIMIT',   limit,   `repLim limit of '${fx.name}'`);
            return {fold: (pt) => `opRepLim(${pt}, ${S}, ${L})`};
        },
    }, 'repLim(base, {spacing, limit})');
}

//MIRROR: fold across coordinate planes (opSym*, shapes/ops/fold.glsl). A
//reflection is an isometry, so this is exact.
const SYM_AXES = {x: 'opSymX', y: 'opSymY', z: 'opSymZ',
                  xy: 'opSymXY', xz: 'opSymXZ', yz: 'opSymYZ', xyz: 'opSymXYZ'};

export function mirror(base, {axes} = {}){
    const fn = SYM_AXES[axes];
    if(!fn){
        throw new Error(`scenegen: mirror(): axes must be one of ${Object.keys(SYM_AXES).join(', ')} `
            + `(letters in xyz order), got ${JSON.stringify(axes)}`);
    }
    return appendMod(base, {
        kind: 'mirror', phase: 'domain',
        plan(){ return {fold: (pt) => `${fn}(${pt})`}; },
    }, 'mirror(base, {axes})');
}

//RADIAL: fold into one of n wedges around the axis (opRadial*,
//shapes/ops/fold.glsl) — an n-fold rotational symmetry, exact like mirror, with
//repLim's caveat: the base must stay inside its wedge or the fold
//overestimates distance across the seam.
const RADIAL_AXES = {x: 'opRadialX', y: 'opRadialY', z: 'opRadialZ'};

export function radial(base, {n, axis = 'y'} = {}){
    const fn = RADIAL_AXES[axis];
    if(!fn){
        throw new Error(`scenegen: radial(): axis must be 'x', 'y' or 'z', got ${JSON.stringify(axis)}`);
    }
    requireInt('radial', 'n', n, {min: 2, why: 'a fractional fold count has no meaning'});
    return appendMod(base, {
        kind: 'radial', phase: 'domain',
        plan(fx){
            //the operator takes a float; fx.value casts an int knob at the call
            const N = fx.value('float', 'SEGMENTS', n, `radial n of '${fx.name}'`);
            return {fold: (pt) => `${fn}(${pt}, ${N})`};
        },
    }, 'radial(base, {n, axis})');
}

//ROUND: offset the surface outward by r (negative r shrinks). The bound
//inflates by r — the offset surface lies r outside the base.
export function round(base, {r} = {}){
    if(r === undefined) throw new Error('scenegen: round() needs r');
    return appendMod(base, {
        kind: 'round', phase: 'field', requiresTrueDF: true,
        plan(fx){
            const R = fx.value('float', 'ROUND', r, `round r of '${fx.name}'`);
            return {
                expr: (d) => `${d} - ${R}`,
                boundEffect: {inflate: R},
            };
        },
    }, 'round(base, {r})');
}

//SHELL: keep a skin around the surface. Two forms (docs/variety-builder.md
//§8): {thickness} — symmetric, `abs(d) - T`, today's exact semantics — and
//{inward, outward} — asymmetric, solid where -inward <= d <= outward,
//emitted abs(d - (o-i)/2) - (i+o)/2. Either way the bound inflates by the
//outer face's reach (a bound that ignored it would tunnel at grazing
//angles), and the total must clear 2*AT_THRESH or the classifier cannot
//separate the two faces (docs/marching.md).
export function shell(base, {thickness, inward, outward} = {}){
    const asym = inward !== undefined || outward !== undefined;
    if(asym && thickness !== undefined){
        throw new Error(`scenegen: shell(): give {thickness} OR {inward, outward}, not both`);
    }
    if(!asym){
        if(thickness === undefined) throw new Error('scenegen: shell() needs a thickness (or {inward, outward})');
        if(!(thickness && thickness.__knob) && !(typeof thickness === 'number' && thickness >= 0.006)){
            throw new Error(`scenegen: shell(): thickness must be at least 0.006 (2*AT_THRESH) — `
                + `thinner and the classifier cannot separate the two faces (docs/marching.md), got ${JSON.stringify(thickness)}`);
        }
        return appendMod(base, {
            kind: 'shell', phase: 'field', requiresTrueDF: true,
            plan(fx){
                const T = fx.value('float', 'SHELL', thickness, `shell thickness of '${fx.name}'`);
                return {
                    expr: (d) => `abs(${d}) - ${T}`,
                    boundEffect: {inflate: T},
                };
            },
        }, 'shell(base, {thickness})');
    }
    //the asymmetric form — each side a number >= 0 or a float knob whose
    //whole range stays >= 0; their floors must together clear 2*AT_THRESH
    const side = (v, what) => {
        if(v === undefined) return 0;
        if(v && v.__knob){
            if(v.type !== 'float' || v.min < 0){
                throw new Error(`scenegen: shell(): the ${what} knob '${v.name}' must be type float with min >= 0`);
            }
            return v;
        }
        if(!(typeof v === 'number' && v >= 0)){
            throw new Error(`scenegen: shell(): ${what} must be a number >= 0 or a float knob, got ${JSON.stringify(v)}`);
        }
        return v;
    };
    const i = side(inward, 'inward');
    const o = side(outward, 'outward');
    const floor = (v) => (v && v.__knob ? v.min : v);
    if(floor(i) + floor(o) < 0.006){
        throw new Error(`scenegen: shell(): inward + outward must stay at least 0.006 (2*AT_THRESH) across `
            + `the knobs' whole ranges — the classifier cannot separate thinner faces (docs/marching.md)`);
    }
    return appendMod(base, {
        kind: 'shell', phase: 'field', requiresTrueDF: true,
        plan(fx){
            const I = fx.value('float', 'INWARD',  i, `shell inward of '${fx.name}'`);
            const O = fx.value('float', 'OUTWARD', o, `shell outward of '${fx.name}'`);
            return {
                expr: (d) => `abs(${d} - (${O} - ${I})*0.5) - (${I} + ${O})*0.5`,
                boundEffect: {inflate: O},
            };
        },
    }, 'shell(base, {inward, outward})');
}

//CLIP and SUBTRACT: intersect with / carve away a placed cutting VOLUME —
//a called lib shape (optionally itself modified), used only as geometry: no
//region, no id, no material. The cutter lives in the node's PRE-FOLD local
//frame (it is a placed thing, so it cuts the whole assembly; carve/displace,
//which take infinite fields, act on the folded point instead). A plain
//cutter is one inline call; a modified one becomes its own small function
//(plan.js planCutter), so its folds evaluate once.
//
//Sign note: planeDistance is negative behind the normal, so
//clip(to: lib.plane({normal: [0,1,0]})) keeps the part BELOW the plane.
//
//clip REPLACES the derived bound with the CUTTER'S bound (its Bound if the
//catalogue has one, its chain folded by the same keep/inflate rules — a
//carved cutter donates its uncarved base), minus the blend (the polynomial
//smax bulges outward by up to blend/4): that is the point of the modifier,
//an unbounded base (a lattice, a limit set) gains a bound it could not
//otherwise have. subtract leaves the bound alone (the result is inside the
//base).
function cutMod(base, spec, kind, operandKey){
    const cutter = spec[operandKey];
    const at     = spec.at ?? [0, 0, 0];
    const blend  = spec.blend ?? 0;
    if(typeof cutter === 'function' && cutter.entry){
        throw new Error(`scenegen: ${kind}(): ${operandKey}: must be a CALLED lib shape — `
            + `lib.${cutter.entry.stem}({...}), not lib.${cutter.entry.stem}`);
    }
    if(!cutter || !cutter.__shape){
        throw new Error(`scenegen: ${kind}() needs ${operandKey}: a called lib shape `
            + `(e.g. lib.box({halfSize: [...]})) to use as the cutting volume`);
    }
    if(cutter.__variety){
        throw new Error(`scenegen: ${kind}(): a variety cannot be a cutter — a cutter must be a `
            + `boundable placed volume, and a variety's zero set is unbounded`);
    }
    if(cutter.entry.outputs){
        throw new Error(`scenegen: ${kind}(): ${cutter.entry.stem} yields several outputs — `
            + `a cutter must be a single-output shape`);
    }
    const bad = (cutter.mods ?? []).find(m => m.breaksTrueDF);
    if(bad){
        throw new Error(`scenegen: ${kind}(): the cutter may not be ${bad.kind}d — `
            + `a displaced surface has no conservative distance to cut with`);
    }
    if(!Array.isArray(at) || at.length !== 3){
        throw new Error(`scenegen: ${kind}(): at must be [x, y, z], got ${JSON.stringify(at)}`);
    }
    if(!(blend && blend.__knob) && !(typeof blend === 'number' && blend >= 0)){
        throw new Error(`scenegen: ${kind}(): blend must be a number >= 0 or a knob, got ${JSON.stringify(blend)}`);
    }
    const isClip = kind === 'clip';
    return appendMod(base, {
        kind, phase: 'field',
        //the library files this cutter (and any nested one) calls into —
        //collected onto the unit's include list by the planner
        uses: [cutter.entry, ...(cutter.mods ?? []).flatMap(m => m.uses ?? [])],
        plan(fx){
            const tok  = fx.token(isClip ? 'CLIP' : 'CUT');
            const cut  = fx.cutter(cutter, tok, at, `${kind} of '${fx.name}'`);
            const hard = blend === 0;
            const B    = hard ? null : fx.value('float', `${tok}_BLEND`, blend, `${kind} blend of '${fx.name}'`);
            const combine = (d, ct) => isClip
                ? (hard ? `max(${d}, ${ct})`            : `smax(${d}, ${ct}, ${B})`)
                : (hard ? `opSmoothSubtract(${d}, ${ct})` : `opSmoothSubtract(${d}, ${ct}, ${B})`);
            return {
                expr: (d, pt) => combine(d, cut.call(pt)),
                frame: 'local',
                helperDefs: cut.helperDefs,
                //the raw cutter call — the marched-sheet form hard-maxes it
                //outside the abs (docs/variety-builder.md §7)
                cutCall: (pt) => cut.call(pt),
                boundEffect: isClip
                    ? {replace: (pt) => `${cut.boundExpr(pt)}${hard ? '' : ` - ${B}`}`}
                    : 'keep',
            };
        },
    }, `${kind}(base, {${operandKey}, at, blend})`);
}

export function clip(base, spec = {}){ return cutMod(base, spec, 'clip', 'to'); }
export function subtract(base, spec = {}){ return cutMod(base, spec, 'subtract', 'what'); }

//THE ESCAPE HATCH — an authored field mod, the modifier analogue of the
//material() ground builder (docs/authored-modifiers.md). The author writes
//the distance rewrite as a glsl`` EXPRESSION over two documented locals —
//`d` the running distance, `q` the folded local point (the infinite-field
//frame, like carve: every folded copy gets identical treatment) — and
//DECLARES the one thing the generator cannot derive, the bound effect:
//'keep' promises the surface stays inside the base; {inflate: v} promises
//it reaches at most v outside (v a number, or a float knob whose WHOLE
//range keeps the promise). The expression must return a conservative
//distance — `d + noise(q)` is displacement and belongs to displace(),
//which pays the Lipschitz divisor for it. Promotion to a named combinator:
//docs/shape-modifiers.md §11.
export function modifier(base, {expr, bound} = {}){
    if(!isGlsl(expr)){
        throw new Error('scenegen: modifier() needs expr: a glsl`...` expression over d and q — '
            + 'see docs/authored-modifiers.md');
    }
    const authored = expr.strings.join('');
    if(authored.includes(';') || /(^|[^=!<>+\-*/])=(?!=)/.test(authored)){
        throw new Error('scenegen: modifier(): expr must be a single EXPRESSION producing the new '
            + 'distance — no statements, no `;`, no assignment. Real structure belongs in '
            + 'glsl/shapes/ops/ as an op the expression calls');
    }
    if(bound === undefined){
        throw new Error("scenegen: modifier() must declare its bound — 'keep' if the surface stays "
            + 'inside the base, {inflate: v} if it can move outward by at most v. This is your '
            + 'promise to the marcher (docs/authored-modifiers.md §3)');
    }
    let inflate = null;
    if(bound !== 'keep'){
        inflate = bound ? bound.inflate : undefined;
        const ok = (inflate && inflate.__knob)
            ? (inflate.type === 'float' && inflate.min >= 0)
            : (typeof inflate === 'number' && inflate >= 0);
        if(!ok){
            throw new Error(`scenegen: modifier(): bound must be 'keep' or {inflate: v} — v a number >= 0, `
                + `or a float knob with min >= 0 (the whole range is the promise) — got ${JSON.stringify(bound)}`);
        }
    }
    return appendMod(base, {
        kind: 'modifier', phase: 'field', requiresTrueDF: true,
        plan(fx){
            const text = fx.glsl(expr);
            return {
                //the fragment names d and q itself, so the closure ignores its args
                expr: () => text,
                readsQ: true,
                boundEffect: inflate === null ? 'keep'
                    : {inflate: fx.num(inflate, `modifier inflate of '${fx.name}'`)},
            };
        },
    }, 'modifier(base, {expr, bound})');
}
