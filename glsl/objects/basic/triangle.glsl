

//-------------------------------------------------
//The TRIANGLE sdf
//-------------------------------------------------

//the data of a triantle prism is its center and radius
struct Triangle{
    vec3 center;
    mat3 orientation;
    float side;
    float thickness;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Triangle obj ){
    //normalize position
    p = p - obj.center;
    p = obj.orientation * p;

    vec3 q = abs(p);
    return max(q.z-obj.thickness,max(q.x*0.86602+p.y*0.5,-p.y)-obj.side*0.5);
}
//overload of location booleans:
bvec2 relPosition( Vector tv, Triangle obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv,Triangle obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Triangle obj ){
    float d = distR3( tv.pos, obj );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Triangle obj ){

    //distance to closest point on box
    float d=distR3(tv.pos, obj);
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, Triangle obj ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, obj);
    float vyyx=distR3( pos + e.yyx*ep, obj);
    float vyxy=distR3( pos + e.yxy*ep, obj);
    float vxxx=distR3( pos + e.xxx*ep, obj);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//overload of setData for a sphere
void setData( inout Path path, Triangle obj){

    //if we are at the surface
    if(at(path.tv, obj)){
        //compute the normal
        Vector normal=normalVec(path.tv,obj);
        bool side = inside(path.tv, obj);
        //set the material
        setObjectInAir(path.dat, side, normal, obj.mat);
    }

}





