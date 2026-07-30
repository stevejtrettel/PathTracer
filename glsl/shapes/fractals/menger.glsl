//----------------------------------------------------------------------------
// MENGER SPONGE — IQ's classic, `size` across.
//
// The construction is subtractive and that is what makes it cheap: start with a
// box, then at each of seven scales fold space into a 3x3x3 cell (`mod(p*s, 2) - 1`)
// and MAX out a cross of three square tubes. Each iteration triples s, so the
// holes get three times finer, and seven levels is past the point where more
// would show.
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
//----------------------------------------------------------------------------


//the cheap max-form box the sponge's own iteration uses (file-private).
//NOT primitives/box.glsl: that one is exact, this returns min(maxcomp, length)
//which underestimates outside the box. The DE is tuned around this form, so it
//stays as it was rather than being unified with the vocabulary's exact box.
float menger_box(vec3 p, vec3 b){
    vec3  d  = abs(p) - b;
    float mc = max(d.x, max(d.y, d.z));
    return min(mc, length(max(d, 0.0)));
}


// p is in the sponge's own coordinates (origin at the centre).
//
// FIXED IN THE PORT: the legacy divided p by size but never scaled the returned
// distance back, so for size < 1 it overestimated distance and the marcher could
// tunnel (the same bug models/kleinBottle.glsl had). The sponge has never had a
// scene, so nothing depended on the old behaviour.
float mengerDistance(vec3 p, float size){
    vec3  q = p/size;
    float d = menger_box(q, vec3(1.0));

    float s = 1.0;
    for(int m = 0; m < 7; m++){
        vec3 a = mod(q*s, 2.0) - 1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0*abs(a));

        //the cross of three square tubes carved out of this cell
        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        float c  = (min(da, min(db, dc)) - 1.0)/s;

        d = max(d, c);
    }
    return size*d;
}


// bounding sphere: the sponge is the unit box carved DOWN, so it never leaves
// the box, whose corners reach sqrt(3) = 1.7321. 1.9 keeps a 10% margin.
float mengerBound(vec3 p, float size){
    return length(p) - 1.9*size;
}
