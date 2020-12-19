//-------------------------------------------------
//The LOCAL GEOMETRY
//-------------------------------------------------


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

















//-------------------------------------------------
//Using ISOMETRIES 
//-------------------------------------------------



// return the rotation around the z-axis by an angle alpha
Isometry rotation(float angle){
    mat4 mat = mat4(
    cos(angle), sin(angle), 0, 0,
    -sin(angle), cos(angle), 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
    );
    return Isometry(mat, false);
}

// Return the isometry sending the origin to p
Isometry makeLeftTranslation(Point p) {
    // this is in COLUMN MAJOR ORDER so the things that LOOK LIKE ROWS are actually FUCKING COLUMNS!
    mat4 mat = mat4(
    1., 0., -p.coords.y / 2., 0.,
    0., 1., p.coords.x / 2., 0.,
    0., 0., 1., 0.,
    p.coords.x, p.coords.y, p.coords.z, 1.);
    return Isometry(mat, true);
}

// Return the isometry sending p to the origin
Isometry makeInvLeftTranslation(Point p) {
    mat4 mat = mat4(
    1., 0., p.coords.y / 2., 0.,
    0., 1., -p.coords.x / 2., 0.,
    0., 0., 1., 0.,
    -p.coords.x, -p.coords.y, -p.coords.z, 1.);
    return Isometry(mat, true);
}


// Product of two isometries (more precisely isom1 * isom2)
Isometry composeIsometry(Isometry isom1, Isometry isom2) {
    return Isometry(isom1.mat * isom2.mat, isom1.nil && isom2.nil);
}

// Return the inverse of the given isometry
Isometry getInverse(Isometry isom) {
    return Isometry(inverse(isom.mat), isom.nil);
}





Isometry translateByVector(vec3 dir) {
    //eventually replace wit the isometry which is exponential of dir in Lie algebra
return makeLeftTranslation(Point(dir));
}


Isometry translateByVector(Vector v) {
   return translateByVector(v.dir);
}



// Translate a point by the given isometry
Point translate(Isometry isom, Point p) {
    vec4 coords=isom.mat * vec4(p.coords,1.);
    return Point(coords.xyz);
}




// overlaod using Vector
Isometry makeLeftTranslation(Vector v) {
    return makeLeftTranslation(v.pos);
}

// overlaod using Vector
Isometry makeInvLeftTranslation(Vector v) {
    return makeInvLeftTranslation(v.pos);
}

// overload to translate a direction
//SHOULD THIS CHANGE THE DIRECTION?
Vector translate(Isometry isom, Vector v) {
    // apply an isometry to the tangent vector (both the point and the direction)
    if (isom.nil) {
        return Vector(translate(isom, v.pos), v.dir);
    }
    else {
        Isometry shift = makeLeftTranslation(v.pos);
        Point target = translate(isom, v.pos);
        Isometry shiftInv = makeInvLeftTranslation(target);
        mat4 matDir = shiftInv.mat * isom.mat * shift.mat;
        vec3 newDir= (matDir * vec4(v.dir,0.)).xyz;
        return Vector(target,newDir);
    }
}


















//-------------------------------------------------
//The GEODESIC FLOW
//-------------------------------------------------




//actually flowing along a geodesic
void flow(inout Vector tv, float t){
    //flow distance t in direction tv
    tv.pos.coords+=t*tv.dir;
}
