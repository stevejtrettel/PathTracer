

/// sampling methods for the lights:


//what is the solid angle subtended by the light at the location of TV?
float solidAngle( vec3 pos, Sphere sphere){
    //distance to the sphere's center
    float d = length(sphere.center-pos);
    float angSize = asin(sphere.radius/d);
    //area of disk on unit sphere
    float area = 2.*PI*(1.-cos(angSize));
    return area;
}



//construct two vectors orthogonal to the original v
void orthogVectors(inout vec3 v, out vec3 n1, out vec3 n2){
    v = normalize(v);
    //choose an initial starting vector: which unit basis vector makes the smallest dot product with v:
    n1 = vec3(1,0,0);
    //now subtract orthogonal projection and normalize
    n1 = n1 - dot(n1,v)*v;
    n1 = normalize(n1);
    //take cross product
    n2 = cross(n1,v);
}


//sample a point on the light uniformly wrt solid angle from tv.
// record the distance to the light in the float "dist".
Vector toLight( vec3 pos, Sphere sphere, out float dist){

    Vector lightDir;
    lightDir.pos = pos;

    //distance to the sphere's center
    float d = length(sphere.center-pos);
    //get direction to light center:
    vec3 toCent = normalize(sphere.center - pos);
    //find angle size:
    float angSize = asin(sphere.radius/d);

    //uniformly sample an angle around the center
    float theta = 2.*PI*randomFloat();
    // sample within angular size
    //THIS IS NOT UNIFORM ON THE MEASURE ON THE SPHERE! NEED TO FIX
    float ang = angSize * randomFloat();

    //use all this to produce a direction
    vec3 n1, n2;
    orthogVectors(toCent, n1,n2);

    vec3 newDir = toCent + ang*(n1*cos(theta)+n2*sin(theta));
    lightDir.dir = normalize(newDir);

    dist = trace(lightDir, sphere);

    return lightDir;
}




