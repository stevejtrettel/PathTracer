//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

struct Sphere{
    Frame frame;
    float radius;
    Material mat;
};


//the local-frame sdf
float sdf( vec3 p, Sphere sphere ){
    return length(p) - sphere.radius;
}

//the standard interface: initObject, at, inside, sdf
OBJECT_INIT(Sphere)
OBJECT_LOCATORS(Sphere)

//analytic normalVec: radial from the center (valid for any rotation/scale)
Vector normalVec( Vector tv, Sphere sphere ){
    vec3 dir = normalize(tv.pos - sphere.frame.pos);
    return Vector(tv.pos, dir);
}

//auxiliary function for writing trace()
//works in world space: center = frame.pos, world radius = scale*radius
vec2 intersectRay_Sphere( Vector tv, Sphere sphere ){
    vec3 p = tv.pos - sphere.frame.pos;
    vec3 v = tv.dir;
    float R = sphere.frame.scale * sphere.radius;

    float a = dot(v,v);
    float b = 2.*dot(p,v);
    float c = (dot(p,p) - R*R)/a;

    float disc = b*b - 4.*a*c;
    if(disc < 0.){
        //intersections do not exist
        return 2.*vec2(maxDist,maxDist);
    }
    //else, return the two intersection points:
    float D = sqrt(abs(disc));
    return vec2(-b-D, -b+D)/(2.*a);
}


//overload of trace for a sphere
float trace( Vector tv, Sphere sphere ){

    vec2 intPt = intersectRay_Sphere(tv, sphere);

    if(intPt.y < 0. || intPt.x > maxDist){
        //the sphere is not in front of us
        return maxDist;
    }
    //otherwise, find the first intersection of the sphere:
    float dist = intPt.x < 0.  ?  intPt.y  :  intPt.x;
    return min(dist,maxDist);
}

//the standard interface: setData
OBJECT_SETDATA(Sphere)

