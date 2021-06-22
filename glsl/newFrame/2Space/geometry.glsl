
//-------------------------------------------------
//The POINT Struct
//-------------------------------------------------


struct Point {
    vec3 coords;// the point in R4
//last coordinate is 1.
};

// origin of the space
const Point ORIGIN = Point(vec3(0, 0, 0));

//in case we need something in a function
Point trashPoint;

Point createPoint(vec3 p){
    return Point(p);
}

//to delete later
//vec3 ORIGIN=vec3(0,0,0);


void shiftPoint(Point p, vec3 v, float ep){
    p.coords.xyz+=ep*v;
}






//-------------------------------------------------
//The VECTOR Struct
//-------------------------------------------------


//tangent vector
struct Vector{
    Point pos;//point in the space
    vec3 dir; //tangent vector,
};

Vector trashVector;

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


//use mix instead of if/then statements to choose
//this is NOT to take an average; x should be 0 or 1.
Vector select(Vector v, Vector w,float x){
    vec3 pos=mix(v.pos.coords,w.pos.coords,x);
    vec3 dir=mix(v.dir,w.dir,x);
    return Vector(Point(pos),dir);
}


//overload of the usual mix command for vector directions
Vector mix(Vector v, Vector w, float x){
    vec3 dir=mix(v.dir,w.dir,x);
    return Vector(v.pos,dir);
}



void nudge(inout Vector v, vec3 dir,float amt){
    v.pos.coords+=dir*amt;
}

//overload to nudge along a tangent vector
void nudge(inout Vector v, Vector offset,float amt){
    nudge(v,offset.dir,amt);
}








//--------the local geometry----------------



float dot(Vector v, Vector w){
    return dot(v.dir,w.dir);
}


float norm(Vector v){
    return sqrt(dot(v,v));
}

Vector normalize(Vector v){
    float length=norm(v);
    return multiplyScalar(1./length,v);
}


float cosAng(Vector v, Vector w){
    return dot(normalize(v),normalize(w));
}


//reflect the unit tangent vector u off the surface with unit normal n
Vector reflect(Vector v, Vector n){
    return add(multiplyScalar(-2.0 * dot(v, n), n), v);
}


//refract the vector v through the surface with normal vector n, and ratio of indices IOR=current/entering
Vector refract(Vector incident, Vector normal, float n){

    float cosX=-dot(normal, incident);
    float sinT2=n*n* (1.0 - cosX * cosX);

    if (sinT2>1.){
        //just returning a nonsense value here as we should never have refraction when TIR
        return incident; }//TIR

    // reflect(incident,normal);}
    //Vector(incident.pos,vec3(0.,0.,0.));}//TIR
    //if we are not in this case, then there is no refraction, but instead total internal reflection

    float cosT=sqrt(1.0 - sinT2);
    vec3 dir=n*incident.dir+(n * cosX - cosT) * normal.dir;
    return Vector(incident.pos, dir);
}





float FresnelReflectAmount(float n, Vector normal, Vector incident, float f0, float f90)
{
    //n=ratio of indices of refraction, current/entering

    // Schlick aproximation
    float r0 = (n-1.)/(n+1.);
    r0 *= r0;
    float cosX = -dot(normal, incident);
    if (n>1.)
    {
        float sinT2 = n*n*(1.0-cosX*cosX);
        // Total internal reflection
        if (sinT2 > 1.0){
            return f90;
        }
        cosX = sqrt(1.0-sinT2);
    }
    float x = 1.0-cosX;
    float ret = clamp(r0+(1.0-r0)*x*x*x*x*x,0.,1.);

    // adjust reflect multiplier for object reflectivity
    //return mix(f0, f90, ret);
    return  f0 + (f90-f0)*ret;
}



//-------------------------------------------------
//The GEODESIC FLOW
//-------------------------------------------------


//actually flowing along a geodesic
void flow(inout Vector tv, float t){
    //flow distance t in direction tv
    tv.pos.coords+=t*tv.dir;
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
Point translate(Isometry isom, Point p) {
    vec4 coords=isom.mat * vec4(p.coords,1.);
    return Point(coords.xyz);
}



// overload to translate a direction
//applying isometry acts via linear part on direction
Vector translate(Isometry isom, Vector v) {
    // apply an isometry to the tangent vector
    Point newPos=translate(isom, v.pos);
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

//overload for points
Isometry makeTranslation(Point p){
    return makeTranslation(p.coords);
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


//overload for point
Isometry makeIsometry(Point pos,vec3 axis, float angle){
    return makeIsometry(pos.coords, axis, angle);
}

