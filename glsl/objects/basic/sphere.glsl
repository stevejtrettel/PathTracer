

//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};


//the point-level sdf
float sdf( vec3 p, Sphere sphere ){
    //normalize position
    vec3 pos = p - sphere.center;

    //distance to closest point on the sphere
    return length(pos) - sphere.radius;
}

//the standard interface: at, inside, sdf
UNFRAMED_LOCATORS(Sphere)

//analytic normalVec for a sphere
Vector normalVec( Vector tv, Sphere sphere ){
    //position vector rel center
    vec3 dir = tv.pos-sphere.center;
    dir=normalize(dir);

    return Vector(tv.pos,dir);
}

//auxilary function for writing trace()
vec2 intersectRay_Sphere( Vector tv, Sphere sphere ){
    //return all intersections with the sphere along the line:
    vec3 p=tv.pos-sphere.center;
    vec3 v=tv.dir;

    float a=dot(v,v);
    float b=2.*dot(p,v);
    float c=(dot(p,p)-sphere.radius*sphere.radius)/a;

    float disc=b*b-4.*a*c;
    if(disc<0.){
        //intersections do not exist
        return 2.*vec2(maxDist,maxDist);
    }
    //else, return the two intersection points:
    float D=sqrt(abs(disc));
    return vec2(-b-D, -b+D)/(2.*a);

}


//overload of trace for a sphere
float trace( Vector tv, Sphere sphere ){

    vec2 intPt=intersectRay_Sphere(tv, sphere);

    if(intPt.y < 0. || intPt.x > maxDist){
        //the sphere is not in front of us
        return maxDist;
    }
    //otherwise, find the first intersection of the sphere:
    float dist=intPt.x < 0.  ?  intPt.y  :  intPt.x;
    return min(dist,maxDist);
}

//the standard interface: setData
OBJECT_SETDATA(Sphere)


float sdRoundBox( vec3 p, vec3 b, float r )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}
