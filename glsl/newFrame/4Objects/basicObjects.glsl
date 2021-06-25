//-------------------------------------------------
// BASIC OBJECTS
// a basic object is built using a single signed distance function
// or some simple computation, and has one material
//-------------------------------------------------








//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    Point center;
    float radius;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Sphere sphere ){
    //normalize position
    vec3 pos = p - sphere.center.coords;

    //distance to closest point on the sphere
    return length(pos) - sphere.radius;
}

//overload of location booleans:
bvec2 relPosition( Vector tv, Sphere sphere){

    float d = distR3( tv.pos.coords, sphere );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv, Sphere sphere){

    float d = distR3( tv.pos.coords, sphere );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Sphere sphere ){
    float d = distR3( tv.pos.coords, sphere );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Sphere sphere ){

    //distance to closest point on sphere
    float d=distR3(tv.pos.coords, sphere);

    //if you are looking away from the sphere, stop
    if(d>0.&&dot(tv.dir,tv.pos.coords)>0.){return maxDist;}

    //otherwise return the actual distance
    return d;
}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Sphere sphere ){
    //position vector rel center
    vec3 dir = tv.pos.coords-sphere.center.coords;
    dir=normalize(dir);

    return Vector(tv.pos,dir);
}

//auxilary function for writing trace()
vec2 intersectRay_Sphere( Vector tv, Sphere sphere ){
    //return all intersections with the sphere along the line:
    vec3 p=tv.pos.coords-sphere.center.coords;
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


//overload of setData for a sphere
void setData( inout Path path, Sphere sphere ){

    //if we are at the surface
    if(at(path.tv, sphere)){
        //compute the normal
        Vector normal=normalVec(path.tv,sphere);
        bool side = inside(path.tv, sphere);
        //set the material
        setObjectInAir(path.dat, side, normal, sphere.mat);
    }

}










//-------------------------------------------------
//The PLANE sdf
//-------------------------------------------------

//the data of a plane is its normal and a constant:

struct Plane{
    //a plane is given by a position and the unit normal at that point:
    Vector orientation;
    Material mat;
};



//overload of distR3
float distR3( vec3 pos, Plane plane ){

    //get position relative to point on plane
    vec3 relPos = pos - plane.orientation.pos.coords;

    //project onto the normal vector
    return dot( relPos, plane.orientation.dir );

}


//overload of location booleans:
bool at( Vector tv, Plane plane){

    float d = distR3( tv.pos.coords, plane );
    return  (abs(d) < AT_THRESH);

}

bool inside( Vector tv, Plane plane ){
    float d = distR3( tv.pos.coords, plane );
    return (d < 0.);
}



//overload of sdf
float sdf( Vector tv, Plane plane ){

    //if aimed away from plane:
    if(dot(tv.dir,plane.orientation.dir)>0.){return maxDist;}

    //otherwise give distance
    return distR3(tv.pos.coords, plane);
}

//overload of normalVec
Vector normalVec( Vector tv,Plane plane ){
    //the normal is just the plane's normal vector
    return Vector(tv.pos, plane.orientation.dir);
}

//overload of trace
float trace( Vector tv, Plane plane ){

    float denom=dot(tv.dir,plane.orientation.dir);
    if(denom>0.){return maxDist;}

    //otherwise, aimed at plane
    return - distR3( tv.pos.coords, plane) / denom;
}


//overload of setData for a sphere
void setData( inout Path path, Plane plane ){

    //if we are at the surface
    if(at(path.tv, plane)){
        //compute the normal
        Vector normal=normalVec(path.tv, plane);
        bool side = inside(path.tv, plane);
        //set the material
        setObjectInAir(path.dat, side, normal, plane.mat);
    }

}

