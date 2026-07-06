

vec3 ORIGIN=vec3(0,0,0);

//-------------------------------------------------
//The VECTOR Struct
//-------------------------------------------------


//tangent vector
struct Vector{
    vec3 pos;//point in the space
    vec3 dir; //tangent vector,
};

Vector randomVector(vec3 pos){
    return Vector(pos,randomUnitVec3());
}

//--basic geometry free operations

Vector add(Vector v, Vector w){
    //this only makes sense if v and w are based at the same point
    return Vector(v.pos, v.dir+w.dir);
}

Vector negate(Vector v){
    return Vector(v.pos,-v.dir);
}

Vector sub(Vector v, Vector w){
    return add(v,negate(w));
}

// scalar multiplication of a tangent vector (return a * v)
Vector multiplyScalar(float a,Vector v) {
    return Vector(v.pos, a * v.dir);
}


Vector rotateByFacing(Vector v, mat3 facing){
    return Vector(v.pos,facing*v.dir);
}



//overload of the usual mix command for vector directions
//assumes same starting point, interpolates directions
Vector mix(Vector v, Vector w, float x){
    vec3 dir=mix(v.dir,w.dir,x);
    return Vector(v.pos,dir);
}



void nudge(inout Vector v, vec3 dir,float amt){
    v.pos+=dir*amt;
}

//overload to nudge along a tangent vector
void nudge(inout Vector v, Vector offset,float amt){
    nudge(v,offset.dir,amt);
}









//-------------------------------------------------
//THE LOCAL GEOMETRY OF THE SPACE
//-------------------------------------------------


//riemannian metric
float vDot(Vector v, Vector w){
    return dot(v.dir,w.dir);
}


float vNorm(Vector v){
    return sqrt(vDot(v,v));
}

Vector vNormalize(Vector v){
    float length=vNorm(v);
    return multiplyScalar(1./length,v);
}


float cosAng(Vector v, Vector w){
    return vDot(vNormalize(v),vNormalize(w));
}




//-------------------------------------------------
//The GEODESIC FLOW
//-------------------------------------------------


//actually flowing along a geodesic
void flow(inout Vector tv, float t){
    //flow distance t in direction tv
    tv.pos += t*tv.dir;
}









//-------------------------------------------------
//The FRAME Struct
//
// a similarity transformation of R3: rotate, scale, translate.
// used to place (and size) objects in the world: an object is authored
// in its own local coordinates and carried into the scene by its frame.
//
// world -> local is exact and cheap: the inverse of the rotation is its
// transpose, which GLSL applies via vector*matrix multiplication.
// distances measured in local units convert to world units by *scale.
//-------------------------------------------------

struct Frame {
    mat3 rot;    //orthogonal: columns are the local axes in world coordinates
    vec3 pos;    //world position of the local origin
    float scale; //uniform scale, > 0
};

const Frame IDENTITY_FRAME = Frame(mat3(1.), vec3(0.), 1.);


//---- applying frames --------------

//points
vec3 toLocal( Frame f, vec3 p ){
    return ((p - f.pos) * f.rot) / f.scale;
}

vec3 toWorld( Frame f, vec3 p ){
    return f.rot * (f.scale * p) + f.pos;
}

//directions: rotation only (uniform scale preserves angles)
vec3 dirToLocal( Frame f, vec3 v ){
    return v * f.rot;
}

vec3 dirToWorld( Frame f, vec3 v ){
    return f.rot * v;
}

//tangent vectors
Vector toLocal( Frame f, Vector v ){
    return Vector( toLocal(f, v.pos), dirToLocal(f, v.dir) );
}

Vector toWorld( Frame f, Vector v ){
    return Vector( toWorld(f, v.pos), dirToWorld(f, v.dir) );
}


//---- the group structure --------------

//apply b, then a
Frame composeFrames( Frame a, Frame b ){
    return Frame( a.rot * b.rot, a.pos + a.rot * (a.scale * b.pos), a.scale * b.scale );
}

Frame invFrame( Frame f ){
    mat3 rotInv = transpose(f.rot);
    return Frame( rotInv, -(rotInv * f.pos) / f.scale, 1. / f.scale );
}


//---- making frames --------------

//place at pos (no rotation, unit scale)
Frame makeFrame( vec3 pos ){
    return Frame( mat3(1.), pos, 1. );
}

//place at pos with a uniform scale
Frame makeFrame( vec3 pos, float scale ){
    return Frame( mat3(1.), pos, scale );
}

//rotate angle degrees about axis, then place at pos
Frame makeFrame( vec3 pos, vec3 axis, float angle ){
    return Frame( rot3AxisAngle(normalize(axis), angle), pos, 1. );
}

//rotate angle degrees about axis, place at pos, with a uniform scale
Frame makeFrame( vec3 pos, vec3 axis, float angle, float scale ){
    return Frame( rot3AxisAngle(normalize(axis), angle), pos, scale );
}

//frame whose local z-axis points along the given normal
//(for planes and other surface-like objects placed by point + normal)
//NOTE: rotateZto lists its entries row-major into GLSL's column-major
//mat3 constructor, so it stores the transpose of the intended rotation;
//transposing back makes rot[2] (the local z-axis) equal the normal.
Frame makeFrameNormal( vec3 pos, vec3 normal ){
    return Frame( transpose(rotateZto(normalize(normal))), pos, 1. );
}
