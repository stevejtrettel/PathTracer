


//reflect the unit tangent vector u off the surface with unit normal n
Vector vReflect(Vector v, Vector n){
    return add(multiplyScalar(-2.0 * vDot(v, n), n), v);
}




//refract the vector v through the surface with normal vector n, and ratio of indices IOR=current/entering
Vector vRefract(Vector incident, Vector normal, float n){

    float cosX=-vDot(normal, incident);
    float sinT2=n*n* (1.0 - cosX * cosX);

    if (sinT2>1.){
        //just returning a nonsense value here as we should never have refraction when TIR
        return Vector(incident.pos,vec3(0.,0.,0.));
        //incident;
    }//TIR

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
    float cosX = -vDot(normal, incident);
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

