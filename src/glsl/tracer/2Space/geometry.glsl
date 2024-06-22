

vec3 ORIGIN=vec3(0,0,0);

//-------------------------------------------------
//The VECTOR Struct
//-------------------------------------------------


//tangent vector
struct Vector{
    vec3 pos;//point in the space
    vec3 dir; //tangent vector,
};

Vector trashVector;

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


void flow(inout Vector tv, float t){
    tv.pos += t*tv.dir;
}





//-------------------------------------------------
//The ISOMETRY Struct
//-------------------------------------------------


struct Isometry {
    mat4 mat;// isometry of the space.
};


Isometry trashIsometry;

const Isometry identity = Isometry(mat4(1));


// Product of two isometries (more precisely isom1 * isom2)
Isometry composeIsometry(Isometry isom1, Isometry isom2) {
    return Isometry(isom1.mat * isom2.mat);
}

// Return the inverse of the given isometry
Isometry getInverse(Isometry isom) {
    return Isometry(inverse(isom.mat));
}



// Translate a point by the given isometry
vec3 translate(Isometry isom, vec3 p) {
    vec4 coords=isom.mat * vec4(p,1.);
    return coords.xyz;
}



// overload to translate a direction
//applying isometry acts via linear part on direction
Vector translate(Isometry isom, Vector v) {
    // apply an isometry to the tangent vector
    vec3 newPos=translate(isom, v.pos);
    vec3 newDir=(isom.mat*vec4(v.dir,0.)).xyz;
    return Vector(newPos,newDir);
}






//---- making Isometries --------------



//make isometry taking origin to p
Isometry makeTranslation(vec3 p){
    //remember matrices are entered BACKWARDS
    mat4 mat=mat4(1.,0.,0.,0.,
    0.,1.,0.,0.,
    0.,0.,1.,0.,
    p.x,p.y,p.z,1.);
    return Isometry(mat);
}


//return isometry rotating angle around axis
Isometry makeRotation(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    mat4 mat= mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
    0.0,                                0.0,                                0.0,                                1.0);
    return Isometry(mat);
}


//roate about an axis then translate
Isometry makeIsometry(vec3 pos, vec3 axis, float angle){

    Isometry trans=makeTranslation(pos);
    Isometry rot=makeRotation(axis, angle);

    //first rotate using point stabilizer, then translate
    return composeIsometry(trans,rot);

}
