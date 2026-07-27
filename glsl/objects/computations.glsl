//-------------------------------------------------
// COMPUTATIONS FOR CREATING OBJECTS
// shared helpers (op* combinators, bounding shapes, cylinderDistance)
// used by the object files; included in every scene (see tracer/setupShader.glsl)
//-------------------------------------------------


//-------------------------------------------------
//-------------------------------------------------
//=====useful
//====OPERATIONS
//-------------------------------------------------
//-------------------------------------------------


//get the input for a 2d sdf/normal from a 3d point
vec2 opRevolution( in vec3 p, float w )
{
    return vec2( length(p.xz) - w, p.y );
}

vec3 opRevolutionOutputNormal(in vec3 p, float w, vec2 n){

    //right now this STRAIGHT UP IGNORES W
    vec3 rVec=normalize(vec3(p.x,0,p.z));
    vec3 hVec=vec3(0,1,0);

    return n.x*rVec+n.y*hVec;
}



//smooth min of signed distance functions
float opMinDist(float distA, float distB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float m = 0.25*h*h/k;
    return min(distA,distB)-m;
}


//smooth min of two normal vectors
vec3 opMinVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float n=0.5*h/k;
    float f=(distA<distB)?n:1.-n;
    return normalize(mix(nvecA, nvecB, f));
}



float opMaxDist( float a, float b, float k )
{
    return -opMinDist(-a,-b,k);
}

vec3 opMaxVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    return opMinVec(-distA, nvecA,-distB, nvecB,k);
}


float opOnionDist(float dist, float thickness){
    return abs(dist)-thickness;
}


vec3 opOnionVec(float dist,vec3 nVec){
    return sign(dist)*nVec;
}




vec3 opTwist( vec3 p )
{
    float k =50.0; // or some other amount
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec2 rot=m*p.xz;
    vec3  q = vec3(rot.x,p.y,rot.y);
    return q;
}



// IQ's extrusion formula.
float opExtrusion(in float sdf, in float pz, in float h){

    //vec2 w = vec2( sdf, abs(pz) - h );
    //return min(max(w.x, w.y), 0.) + length(max(w, 0.));

    // Slight rounding. A little nicer, but slower.
    const float sf = .028;
    vec2 w = vec2( sdf, abs(pz) - h ) + sf;
    return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - sf;

}



//--- combine two sdfs -----------------------------------------------
//(hard union/intersection are just min()/max() on the distances)

//SUBTRACTION: carve B out of A (result surface = A minus B)
float opSubtractDist(float distA, float distB){ return max(distA, -distB); }
//smooth subtraction with blend radius k
float opSubtractDist(float distA, float distB, float k){ return opMaxDist(distA, -distB, k); }
//the matching normal blend for the smooth version
vec3 opSubtractVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    return opMaxVec(distA, nvecA, -distB, -nvecB, k);
}

//ROUNDING: inflate a surface by r (r>0 rounds outward)
float opRound(float dist, float r){ return dist - r; }


//--- fold/repeat the DOMAIN (call on p BEFORE the sdf) ---------------

//MIRROR across the coordinate planes (fold to the positive octant/half)
vec3 opSymX(vec3 p){ p.x = abs(p.x); return p; }
vec3 opSymY(vec3 p){ p.y = abs(p.y); return p; }
vec3 opSymZ(vec3 p){ p.z = abs(p.z); return p; }
vec3 opSymXY(vec3 p){ p.xy = abs(p.xy); return p; }
vec3 opSymXZ(vec3 p){ p.xz = abs(p.xz); return p; }
vec3 opSymYZ(vec3 p){ p.yz = abs(p.yz); return p; }
vec3 opSymXYZ(vec3 p){ return abs(p); }

//INFINITE repetition on a grid of spacing s (one copy of the shape per cell)
vec3 opRep(vec3 p, vec3 s){ return p - s*round(p/s); }

//LIMITED repetition: a (2*lim+1) grid of spacing s, centered at the origin
vec3 opRepLim(vec3 p, float s, vec3 lim){ return p - s*clamp(round(p/s), -lim, lim); }

//ELONGATE: pull a shape apart by h along each axis (cheap; exact for convex shapes)
vec3 opElongate(vec3 p, vec3 h){ return p - clamp(p, -h, h); }

//RADIAL: fold space into one of n wedges around the axis — an n-fold rotational
//symmetry. A rotation is an isometry, so this is exact; but like opRepLim, the
//base must stay INSIDE its wedge or the fold overestimates distance across the
//seam, which the marcher punishes as tunneling.
vec3 opRadialY(vec3 p, float n){
    float r = length(p.xz);
    if(r < 1.0e-6){ return p; }              //on the axis atan is undefined
    float seg = 6.2831853/n;
    float a   = mod(atan(p.z, p.x) + 0.5*seg, seg) - 0.5*seg;
    return vec3(r*cos(a), p.y, r*sin(a));
}
vec3 opRadialX(vec3 p, float n){
    float r = length(p.yz);
    if(r < 1.0e-6){ return p; }
    float seg = 6.2831853/n;
    float a   = mod(atan(p.z, p.y) + 0.5*seg, seg) - 0.5*seg;
    return vec3(p.x, r*cos(a), r*sin(a));
}
vec3 opRadialZ(vec3 p, float n){
    float r = length(p.xy);
    if(r < 1.0e-6){ return p; }
    float seg = 6.2831853/n;
    float a   = mod(atan(p.y, p.x) + 0.5*seg, seg) - 0.5*seg;
    return vec3(r*cos(a), r*sin(a), p.z);
}


//--- CARVE: erode a solid with an fbm of sphere lattices ---------------
//
// IQ's fbmSDF (https://iquilezles.org/articles/fbmsdf). The point is what it is
// NOT: displacement. `d + amp*noise(p)` is not a distance field, which is why
// displace() pays a Lipschitz divisor at every march step and has to inflate its
// bound. This SUBTRACTS a distance field instead — a lattice of spheres, smooth-
// maxed out of the solid octave by octave — and a smooth max of two distance
// fields is still one. So the detail is free to march, and because carving only
// ever ERODES, the uncarved base remains a valid bound.
//
// FUTURE US: the carving field is hard-wired to the sphere lattice, the way
// repLim hard-wires its fold. The natural generalization is to let carve() take
// a caller-supplied DISTANCE field (`by:`), whose metadata would be a declared
// Lipschitz constant rather than displace's {gradBound, range}. Call sites would
// not change; opCarveFbm would take the field's function instead of calling
// opCarveCell. Deferred until a second carving field actually exists.

const float CARVE_LACUNARITY = 2.0;

//the rotation between octaves, so the lattices never line up (IQ's matrix)
const mat3 CARVE_ROT = mat3( 0.00,  0.80,  0.60,
                            -0.80,  0.36, -0.48,
                            -0.60, -0.48,  0.64);

//one sphere per corner of the unit cell, radius from the corner's own hash.
//`erosion` scales every radius: 0 bites nothing, 1 is the full 0.7 of a cell.
//
//A min over the 8 CORNERS is IQ's approximation — a lattice point one cell over
//sits as close as 1.0 while a corner can be 1.73 away, so a big enough neighbour
//sphere can in principle be nearer than all eight. Used subtractively, as here,
//the error is small and bounded; do not lift this out as a general-purpose sdf.
float opCarveCell(vec3 p, float erosion){
    vec3  i = floor(p);
    vec3  f = p - i;
    float d = 1.0e9;
    for(int x = 0; x <= 1; x++){
        for(int y = 0; y <= 1; y++){
            for(int z = 0; z <= 1; z++){
                vec3  c = vec3(float(x), float(y), float(z));
                float r = fieldHash(i + c);
                d = min(d, length(f - c) - erosion*r*r*0.7);
            }
        }
    }
    return d;
}

//carve `d` with `octaves` of that lattice, each half the size and `gain` of the
//amplitude of the last. Returns a CONSERVATIVE distance.
//
//THE DIVISOR. Octave i carries amplitude gain^i at frequency LACUNARITY^i, so its
//gradient is (gain*LACUNARITY)^i, and a smooth max is bounded by the steepest of
//its operands. With gain <= 1/LACUNARITY every octave is 1-Lipschitz and the
//field is a true distance function — divisor 1, nothing paid. Above that the
//divisor is real and the marcher needs it, so it is tracked in the loop rather
//than assumed away. This is why gain is worth exposing: it is the dial between
//"free to march" and "richer, and paying for it".
float opCarveFbm(vec3 p, float d, int octaves, float erosion, float gain, float blend, float seed){
    vec3  q   = p + vec3(seed);
    float s   = 1.0;      //this octave's amplitude
    float g   = 1.0;      //this octave's gradient bound
    float lip = 1.0;      //the steepest octave so far

    for(int i = 0; i < octaves; i++){
        lip = max(lip, g);
        d   = opMaxDist(d, -s*opCarveCell(q, erosion), blend*s);
        q   = CARVE_LACUNARITY*(CARVE_ROT*q);
        s  *= gain;
        g  *= gain*CARVE_LACUNARITY;
    }
    return d/lip;
}













//-------------------------------------------------
//-------------------------------------------------
//=====BOUNDING SHAPES  (box / cylinder signed distances)
//
// these serve TWO distinct roles in the object files; keep them straight:
//   (1) a geometry CLIP baked into a local sdf, e.g. smax(surfaceDist, bBox(p,box)):
//       this CHANGES the shape (cuts the object to the region). see varBox/surfBox.
//   (2) a bounding SDF returned by a type's `bound( vec3 p, Type )` for the
//       OBJECT_*_B acceleration: pure speed, never changes geometry. see objectAPI.glsl.
// a type often uses the SAME box for both (clip up close, skip when far).
//-------------------------------------------------
//-------------------------------------------------


//signed distance to a box: box = half-widths
float bBox(vec3 pos, vec3 box){
    vec3 q = abs(pos) - box;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}


//signed distance to a cylinder: cyl.x = radius, cyl.y = half-height
float bCyl(vec3 pos, vec2 cyl){
    float r = length(pos.xz)-cyl.x;
    float h = abs(pos.y)-cyl.y;
    return max(r,h);
}




//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======CYLINDER
//==from rotating a box
//-------------------------------------------------
//-------------------------------------------------


//from https://www.iquilezles.org/www/articles/distgradfunctions2d/distgradfunctions2d.htm
//get the distnance as .x and the 2d normal as .yz
vec3 sdgBox( in vec2 p, in vec2 b )
{
    vec2 w = abs(p)-b;
    vec2 s = vec2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
    return vec3(   (g>0.0)?l  :g,
    s*((g>0.0)?q/l:((w.x>w.y)?vec2(1,0):vec2(0,1))));
}






float cylinderDistance(vec3 pos, float radius, float height, float rounded){

    vec2 p=vec2( length(pos.xz) , pos.y);
    //the box we rotate about its central axis has width 2rad and height = 2height.
    vec2 b=vec2(radius-rounded, height);

    vec2 w = abs(p)-b;
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);

    float dist= (g>0.0) ?  l  :g;
    return dist-rounded;
}


//truncated cone (from IQ): height h (half), bottom radius r1, top radius r2.
//a component of the bottle/pint profile shapes (glsl/shapes/)
float sdCappedCone(vec3 p, float h, float r1, float r2){
    vec2 q  = vec2(length(p.xz), p.y);
    vec2 k1 = vec2(r2, h);
    vec2 k2 = vec2(r2 - r1, 2.0*h);
    vec2 ca = vec2(q.x - min(q.x, (q.y < 0.0) ? r1 : r2), abs(q.y) - h);
    vec2 cb = q - k1 + k2*clamp(dot(k1 - q, k2)/dot(k2, k2), 0.0, 1.0);
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s*sqrt(min(dot(ca, ca), dot(cb, cb)));
}


//torus with symmetry axis = y: ra = ring radius (centre of tube to origin),
//rb = tube radius. A component of the bottleTorus profile shape.
float sdTorus(vec3 pos, float ra, float rb){
    vec3  p = vec3(pos.x, pos.z, -pos.y);   //stand it up (axis = y)
    float h = length(p.xz);
    return length(vec2(h - ra, p.y)) - rb;
}