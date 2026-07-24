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
vec3 opSymXZ(vec3 p){ p.xz = abs(p.xz); return p; }

//INFINITE repetition on a grid of spacing s (one copy of the shape per cell)
vec3 opRep(vec3 p, vec3 s){ return p - s*round(p/s); }

//LIMITED repetition: a (2*lim+1) grid of spacing s, centered at the origin
vec3 opRepLim(vec3 p, float s, vec3 lim){ return p - s*clamp(round(p/s), -lim, lim); }

//ELONGATE: pull a shape apart by h along each axis (cheap; exact for convex shapes)
vec3 opElongate(vec3 p, vec3 h){ return p - clamp(p, -h, h); }













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