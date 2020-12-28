
//-------------------------------------------------
//The POINT Struct
//-------------------------------------------------


struct Point {
    vec3 coords;// the point in R4
    //last coordinate is 1.
};

// origin of the space
const Point ORIGIN = Point(vec3(0, 0, 0));

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


//refract the vector v through the surface with normal vector n, and ratio of indices IOR=entering/current
Vector refract(Vector v, Vector n, float IOR){
   
    float cosI=-dot(n,v);
    float sinT2=IOR*IOR* (1.0 - cosI * cosI);
    
    if(sinT2>1.){return Vector(v.pos,vec3(0.,0.,0.));}//TIR  
    //if we are not in this case, then refraction actually occurs
    
    float cosT=sqrt(1.0 - sinT2);
    vec3 dir=IOR*v.dir+(IOR * cosI - cosT) * n.dir;
    return Vector(v.pos, dir);
}





float FresnelReflectAmount(float n1, float n2, Vector normal, Vector incident, float f0, float f90)
{
        // Schlick aproximation
        float r0 = (n1-n2) / (n1+n2);
        r0 *= r0;
        float cosX = -dot(normal, incident);
        if (n1 > n2)
        {
            float n = n1/n2;
            float sinT2 = n*n*(1.0-cosX*cosX);
            // Total internal reflection
            if (sinT2 > 1.0)
                return f90;
            cosX = sqrt(1.0-sinT2);
        }
        float x = 1.0-cosX;
        float ret = r0+(1.0-r0)*x*x*x*x*x;
 
        // adjust reflect multiplier for object reflectivity
        return mix(f0, f90, ret);
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





































//==== THINGS TO REPLACE AS NEEDED


void nudge(inout Vector v, vec3 dir){
    v.pos.coords+=dir*0.003;
}

//overload to nudge along a tangent vector
void nudge(inout Vector v, Vector offset){
    nudge(v,offset.dir);
}


//small shift in the location of a point
vec3 shiftPoint(vec3 p, vec3 v, float t){
    return p+0.001*v;
}

Vector shift(Vector tv, vec3 dir, float t){
    return Vector(Point(tv.pos.coords+0.001*dir),tv.dir);
}



