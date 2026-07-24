//-------------------------------------------------
// SHAPE WRAPPERS — the two first-class mechanisms over a library shape
//
//   displace(base, {by, amp})       move the surface by amp*field(q)
//   repLim(base, {spacing, limit})  one region, a folded grid of copies
//
// Each wraps a plain lib shape and is planned specially by the emitter, which
// derives only what is FORMULAIC over declared data: displace's Lipschitz
// divisor (1 + amp*gradBound) and bound inflation (maxAbs(range)*amp), and
// the trace routing (no closed form any more -> marched). Nothing here knows
// any particular math — a field's gradBound/range are declared by its author
// or filled in by a preset.
//
// Anything more elaborate is an authored sdf body on the node, not a wrapper.
//-------------------------------------------------


export function displace(base, {by, amp} = {}){
    if(!base || !base.__shape){
        throw new Error('scenegen: displace(base, {by, amp}): base must be a lib shape');
    }
    if(base.kind){
        throw new Error('scenegen: displace() does not compose with other wrappers — author the sdf instead');
    }
    if(!by || !by.__field){
        throw new Error('scenegen: displace(): `by` must be a field()');
    }
    if(amp === undefined) throw new Error('scenegen: displace() needs an amp');
    if(!by.gradBound || !by.range){
        throw new Error(`scenegen: displace(): field '${by.name}' must declare gradBound and range `
            + `to displace geometry (a preset can fill these in — see presets.js)`);
    }
    return {__shape: true, kind: 'displaced', stem: base.stem, entry: base.entry, values: base.values, by, amp};
}

export function repLim(base, {spacing, limit} = {}){
    if(!base || !base.__shape || base.kind){
        throw new Error('scenegen: repLim(base, {spacing, limit}): base must be a plain lib shape');
    }
    if(spacing === undefined || limit === undefined){
        throw new Error('scenegen: repLim() needs spacing and limit');
    }
    return {__shape: true, kind: 'repLim', stem: base.stem, entry: base.entry, values: base.values, spacing, limit};
}
