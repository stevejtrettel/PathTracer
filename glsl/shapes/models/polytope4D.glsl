//----------------------------------------------------------------------------
// REGULAR 4-POLYTOPE — the six regular polytopes of R^4, drawn as a wireframe
// (a ball at each vertex, a tube along each edge) STEREOGRAPHICALLY PROJECTED
// from S^3 into R^3.
//
// ONE FILE FOR ALL SIX, because the machinery below is identical for every one
// of them: only `type` and `coords` differ, and those are parameters. The six
// classic names are presets over this shape (js/presets/polytopes.js), so a
// scene writes hypercube(...) or sixHundredCell(...) and never sees the pair.
//
// HOW IT WORKS, in the order the code runs:
//
//   1. the point is inverse-stereographically projected onto the unit S^3, so
//      the whole construction happens on the sphere and only the DISTANCE comes
//      back to R^3;
//   2. `spin` rotates it there — an internal rotation of S^3, which is what
//      turns the figure inside out as it sweeps. Not 3D placement;
//   3. `p4_fold` reflects it into the Coxeter fundamental domain: abs() on the
//      xy pair plus reflections in two mirrors nc, nd, iterated. After folding,
//      ONE vertex and FOUR edges represent the whole polytope, which is why a
//      600-cell costs the same per step as a 5-cell (only the fold depth grows);
//   4. distances to that vertex and those edges are SPHERICAL, so `p4_DD`
//      converts each into the Euclidean distance seen under the projection from
//      radius r. That conversion is the heart of the file.
//
// WHICH POLYTOPE: `type` is the Coxeter parameter (3, 4 or 5) and `coords` picks
// a point in the fundamental domain; together they choose the figure.
//   type 3, (0,1,0,0)   5-cell           type 4, (0,0,1,0)   24-cell
//   type 4, (0,1,0,0)   hypercube        type 5, (0,1,0,0)   120-cell
//   type 4, (0,0,0,1)   16-cell          type 5, (0,0,0,1)   600-cell
//
// COST: the fold runs 3, 8 or 15 times for type 3, 4 or 5 — so the 120-cell and
// the 600-cell are markedly dearer than the rest.
//
// VERTEX vs EDGE is a DATA OUTPUT (docs/shape-data.md), not two regions. The
// legacy carried two Material fields and picked between them in a custom
// setData; here the shape is one region and `partData` says which part was hit,
// so a material body switches on it — the same channel the room uses for its
// walls. That keeps the shape usable as an ordinary `shape:` (and so through the
// six presets), which two outputs would not: multi-output shapes have to be
// called from a group's authored body.
//
// The one thing this gives up is a separate MEDIUM per part — one region, one
// interior. The classic look is gloss on both, which has no interior at all, so
// nothing is lost today; a vertex-glass/edge-metal scene would need the group
// form instead.
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
//----------------------------------------------------------------------------


//the two parts a hit can belong to, for the partData channel
const int P4_VERTEX = 0;
const int P4_EDGE   = 1;


//how many times the fold must run to close up this Coxeter group
int p4_iterates(int type){
    if(type == 3){ return 3; }
    if(type == 4){ return 8; }
    if(type == 5){ return 15; }
    return 10;
}


//reflect into the fundamental domain
vec4 p4_fold(vec4 pos, vec4 nc, vec4 nd, int iterates){
    for(int i = 0; i < 15; i++){
        if(i > iterates){ break; }
        pos.xy = abs(pos.xy);
        float t = -2.*min(0., dot(pos, nc));
        pos += t*nc;
        t = -2.*min(0., dot(pos, nd));
        pos += t*nd;
    }
    return pos;
}


//a spherical distance on the unit S^3 (given as its cosine ca and sine sa) as
//the EUCLIDEAN distance seen from a point at radius r under the stereographic
//projection. This is what lets a 4D construction be sphere-traced in R^3.
float p4_DD(float ca, float sa, float r){
    return r - (2.*r*ca - (1. - r*r)*sa)/((1. - r*r)*ca + 2.*r*sa + 1. + r*r);
}


float p4_toVertex(vec4 z, vec4 pVec, float r){
    float ca = dot(z, pVec);
    float sa = 0.5*length(pVec - z)*length(pVec + z);
    return p4_DD(ca, sa, r);
}


//distance to the edge lying in the plane of pVec and the mirror normal n
float p4_toSegment(vec4 z, vec4 n, vec4 pVec, float r){
    //pmin: z projected onto that plane, then back onto the sphere
    float zn = dot(z, n), zp = dot(z, pVec), np = dot(n, pVec);
    float alpha = zp - zn*np, beta = zn - zp*np;
    vec4  pmin  = normalize(alpha*pVec + min(0., beta)*n);

    float ca = dot(z, pmin), sa = 0.5*length(pmin - z)*length(pmin + z);
    return p4_DD(ca, sa, r);
}


//the four edges that survive the fold
float p4_toEdges(vec4 z, vec4 nc, vec4 nd, vec4 pVec, float r){
    float da = p4_toSegment(z, vec4(1., 0., 0., 0.), pVec, r);
    float db = p4_toSegment(z, vec4(0., 1., 0., 0.), pVec, r);
    float dc = p4_toSegment(z, nc, pVec, r);
    float dd = p4_toSegment(z, nd, pVec, r);
    return min(min(da, db), min(dc, dd));
}


//the Coxeter data for (type, coords): two mirror normals and the generating
//point whose orbit is the polytope's vertex set
void p4_setup(int type, vec4 coords, out vec4 nc, out vec4 nd, out vec4 pVec){
    float cospin  = cos(PI/float(type));
    float isinpin = 1./sin(PI/float(type));
    float scospin = sqrt(2./3. - cospin*cospin);
    float issinpin = 1./sqrt(3. - 4.*cospin*cospin);

    nc = 0.5*vec4(0., -1., sqrt(3.), 0.);
    nd = vec4(-cospin, -0.5, -0.5/sqrt(3.), scospin);

    vec4 pabc = vec4(0., 0., 0., 1.);
    vec4 pbdc = 0.5*sqrt(3.)*vec4(scospin, 0., 0., cospin);
    vec4 pcda = isinpin*vec4(0., 0.5*sqrt(3.)*scospin, 0.5*scospin, 1./sqrt(3.));
    vec4 pdba = issinpin*vec4(0., 0., 2.*scospin, 1./sqrt(3.));

    pVec = normalize(coords.x*pabc + coords.y*pbdc + coords.z*pcda + coords.w*pdba);
}


//the shared work: project, spin, fold, and measure both parts (file-private)
void p4_parts(vec3 p, int type, vec4 coords, vec3 spinAxis, float spinAngle,
              out float vertexDist, out float edgeDist){
    vec4 nc, nd, pVec;
    p4_setup(type, coords, nc, nd, pVec);

    //onto the sphere
    float r = length(p);
    vec4  z = vec4(2.*p, 1. - r*r)*(1./(1. + r*r));

    //spin it there, then fold into the fundamental domain
    z.xyw = rot3AxisAngle(normalize(spinAxis), spinAngle)*z.xyw;
    z = p4_fold(z, nc, nd, p4_iterates(type));

    vertexDist = p4_toVertex(z, pVec, r);
    edgeDist   = p4_toEdges(z, nc, nd, pVec, r);
}


// p is in the polytope's own coordinates.
//
// `spinAxis` and `spinAngle` (DEGREES) are the internal rotation of S^3 — the
// figure's pose in 4D, not its placement in 3D. The legacy carried this as a
// mat3 built by rot3AxisAngle; taking the axis and angle instead is the same
// rotation, and makes it drivable by a knob.
float polytope4DDistance(vec3 p, int type, vec4 coords, float vertexRad, float edgeRad,
                         vec3 spinAxis, float spinAngle){
    float v, e;
    p4_parts(p, type, coords, spinAxis, spinAngle, v, e);
    return min(v - vertexRad, e - edgeRad);
}


// which part was hit (shape data): P4_VERTEX or P4_EDGE. A material body that
// reads `partData` gets it injected with this object's own consts baked in.
int polytope4DPartData(vec3 q, int type, vec4 coords, float vertexRad, float edgeRad,
                       vec3 spinAxis, float spinAngle){
    float v, e;
    p4_parts(q, type, coords, spinAxis, spinAngle, v, e);
    return (v - vertexRad < e - edgeRad) ? P4_VERTEX : P4_EDGE;
}


// NO BOUND, and there cannot be a constant one. Under the stereographic
// projection the figure's extent DEPENDS ON THE SPIN: as the S^3 rotation
// sweeps, cells pass through the projection point and shoot off toward infinity.
// Measured for the hypercube at vertexRad 0.15, the extent swings from |p| = 1.25
// at spin -45 to 3.76 at spin 0 — and it is unbounded in principle. The legacy's
// fixed `length(p) - 2.4` therefore CLIPPED the figure at some spins, which is a
// bound that silently deletes geometry.
//
// A scene that wants finiteness clips explicitly — clip() donates its cutter as
// the bound, so the cut is visible and chosen rather than accidental.
