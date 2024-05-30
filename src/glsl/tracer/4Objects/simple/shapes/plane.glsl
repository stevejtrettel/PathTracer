

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
    vec3 relPos = pos - plane.orientation.pos;

    //project onto the normal vector
    return dot( relPos, plane.orientation.dir );

}


//overload of location booleans:
bool at( Vector tv, Plane plane){

    float d = distR3( tv.pos, plane );
    return  (abs(d) < AT_THRESH);

}

bool inside( Vector tv, Plane plane ){
    float d = distR3( tv.pos, plane );
    return (d < 0.);
}



//overload of sdf
float sdf( Vector tv, Plane plane ){

    //if aimed away from plane:
    if(dot(tv.dir,plane.orientation.dir)>0.){return maxDist;}

    //otherwise give distance
    return distR3(tv.pos, plane);
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
    return - distR3( tv.pos, plane) / denom;
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






