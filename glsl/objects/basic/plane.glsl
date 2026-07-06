//-------------------------------------------------
//The PLANE sdf
//-------------------------------------------------

//a plane is the surface z=0 of its local frame (normal = the frame's z-axis).
//place one with makeFrameNormal(pos, normal).

struct Plane{
    Frame frame;
    Material mat;
};


//the local-frame sdf
float sdf( vec3 p, Plane plane ){
    return p.z;
}

//the world normal is the frame's z-axis (third column of the rotation)
vec3 planeNormal( Plane plane ){
    return plane.frame.rot[2];
}

//world signed distance to the plane at a point
float planeDist( vec3 p, Plane plane ){
    return plane.frame.scale * sdf( toLocal(plane.frame, p), plane );
}


OBJECT_INIT(Plane)

//location booleans (hand-written: the Vector-level sdf below is custom)
bool at( Vector tv, Plane plane ){
    return abs(planeDist(tv.pos, plane)) < AT_THRESH;
}

bool inside( Vector tv, Plane plane ){
    return planeDist(tv.pos, plane) < 0.;
}

//custom Vector-level sdf: returns maxDist when aimed away from the plane
float sdf( Vector tv, Plane plane ){
    if( dot(tv.dir, planeNormal(plane)) > 0. ){ return maxDist; }
    return planeDist(tv.pos, plane);
}

//overload of normalVec
Vector normalVec( Vector tv, Plane plane ){
    return Vector(tv.pos, planeNormal(plane));
}

//overload of trace: analytic ray-plane intersection
float trace( Vector tv, Plane plane ){
    float denom = dot(tv.dir, planeNormal(plane));
    if(denom > 0.){ return maxDist; }
    return - planeDist(tv.pos, plane) / denom;
}

//the standard interface: setData
OBJECT_SETDATA(Plane)
