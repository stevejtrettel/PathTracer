


//-------------------------------------------------
//The VECTOR Struct
//-------------------------------------------------

vec3 ORIGIN=vec3(0,0,0);

//tangent vector
struct Vector{
    vec3 pos;
    vec3 dir; 
};

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


Vector normalize(Vector v){
   return Vector(v.pos,normalize(v.dir));
}

Vector clone(Vector v){
    return v;
}

float dot(Vector v, Vector w){
    return dot(v.dir,w.dir);
}

float cosAng(Vector v, Vector w){
    return dot(normalize(v),normalize(w));
}


Vector rotateByFacing(Vector v, mat3 facing){
    return Vector(v.pos,facing*v.dir);
}





//actually flowing along a geodesic
void flow(inout Vector tv, float t){
    //flow distance t in direction tv
    tv.pos+=t*tv.dir;
}




void nudge(inout Vector v, vec3 dir){
    v.pos+=dir*0.003;
}

//overload to nudge along a tangent vector
void nudge(inout Vector v, Vector offset){
    v.pos+=offset.dir*0.003;
}


//small shift in the location of a point
vec3 shiftPoint(vec3 p, vec3 v, float t){
    return p+0.001*v;
}

Vector shift(Vector tv, vec3 dir, float t){
    return Vector(tv.pos+0.001*dir,tv.dir);
}




//use mix instead of if/then statements to choose
//this is NOT to take an average; x should be 0 or 1.
Vector select(Vector v, Vector w,float x){
    vec3 pos=mix(v.pos,w.pos,x);
    vec3 dir=mix(v.dir,w.dir,x);
    return Vector(pos,dir);
}


//overload of the usual mix command for vector directions
Vector mix(Vector v, Vector w, float x){
     vec3 dir=mix(v.dir,w.dir,x);
    return Vector(v.pos,dir);
}




//reflect the unit tangent vector u off the surface with unit normal n
Vector reflect(Vector v, Vector n){
    return add(multiplyScalar(-2.0 * dot(v, n), n), v);
}


//refract the vector v through the surface with normal vector n, coming from a material with refactive index n1 and entering a material with index n2.
Vector refract(Vector v, Vector n, float IOR){
   
    float r=IOR;
    float cosI=-dot(n,v);
    float sinT2=r*r* (1.0 - cosI * cosI);
    if(sinT2>1.){return Vector(v.pos,vec3(0.,0.,0.));}//TIR  
    //if we are not in this case, then refraction actually occurs
    float cosT=sqrt(1.0 - sinT2);
    vec3 dir=r*v.dir+(r * cosI - cosT) * n.dir;
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



