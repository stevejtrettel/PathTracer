//----------------------------------------------------------------------------
// APOLLONIAN — the evilryu/mla Apollonian gasket: a domain-repeat + sphere-
// inversion IFS wrapped in an outer inversion that bounds the space-filler.
// `r2` = 1 + K is the morph that deforms the gasket (~0.9..1.3; 1.2 = the still).
//
// glsl/shapes/ is the math-only library. Exposes an orbit-trap DATA output for
// coloring (docs/shape-data.md): a material that reads `orbitTrapData` gets it.
//----------------------------------------------------------------------------


//the core gasket: fold into ±1 cubes, invert in a sphere of radius² r2, and
//accumulate the conformal scale. `orb` = orbit trap (min of |p| and |p|²).
float apo_gasket(vec3 p, float r2, out vec4 orb){
    float scale = 1.0;
    orb = vec4(1000.0);
    for(int i = 0; i < 10; i++){
        p -= 2.0*round(0.5*p);
        float p2 = dot(p, p);
        orb = min(orb, vec4(abs(p), p2));
        float k = r2/p2;
        p     *= k;
        scale *= k;
    }
    float res = min(abs(p.z)+abs(p.x), min(abs(p.x)+abs(p.y), abs(p.y)+abs(p.z)));
    return res/scale;
}

//the outer inversion mapping the space-filling gasket to a bounded object
float apo_map(vec3 p, float r2, out vec4 orb){
    float s = 4.0/dot(p, p);
    p *= s;
    p += vec3(1.0);
    return 0.25 * apo_gasket(p, r2, orb) / s;
}


// p in the gasket's own coordinates
float apollonianDistance(vec3 p, float r2){
    vec4 orb;
    return apo_map(p, r2, orb);
}

// the orbit trap at a point (shape data): min of |p| and |p|² over the orbit
vec4 apollonianOrbitTrapData(vec3 q, float r2){
    vec4 orb;
    apo_map(q, r2, orb);
    return orb;
}

// the outer inversion compacts the gasket near the origin
float apollonianBound(vec3 p){
    return length(p) - 6.0;
}
