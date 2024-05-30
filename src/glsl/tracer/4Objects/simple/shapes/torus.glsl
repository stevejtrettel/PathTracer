

//-------------------------------------------------
//The TORUS sdf
//-------------------------------------------------

//the data of a torus is its inner and outer radii, and its center
//(also orientation, but for now all tori are vertical until I am more careful)


struct Torus{
    vec3 center;
    float innerR;
    float outerR;
    Material mat;
};




//signed dist in terms of basic parameters
float sdTorus( vec3 pos, float ra, float rb  ){
    //normalize position
    vec3 p = vec3(pos.x,pos.z,-pos.y);

    float h = length(p.xz);
    float dist =  length(vec2(h-ra,p.y))-rb;

    return dist;
}


//overload of distR3: distance in R3 coordinates
float distR3( vec3 pos, Torus torus ){
    //normalize position
    pos = vec3(pos.x,pos.z,-pos.y);
    vec3 p = (pos - torus.center);

    float rb = torus.innerR;
    float ra = torus.outerR;

    float h = length(p.xz);
    float dist =  length(vec2(h-ra,p.y))-rb;

    return dist;
}

//overload of location booleans:
bool at( Vector tv, Torus torus){

    float d = distR3( tv.pos, torus );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Torus torus ){
    float d = distR3( tv.pos, torus );
    return (d<0.);
}


//overload of sdf for a torus
float sdf( Vector tv, Torus torus ){
    return distR3(tv.pos, torus);
}



////overload of normalVec for a torus
//Vector normalVec( Vector tv, Torus torus ){
//
//    //normalize position
//    vec3 p = (pos - torus.center);
//
//    float ra = torus.outerR;
//    float rb = torus.innerR;
//
//    float h = length(p.xz);
//    vec3 dir = normalize(p*vec3(h-ra,h,h-ra));
//
//    return Vector(tv.pos,dir);
//}




//overload of normalVec for a sphere
Vector normalVec( Vector tv, Torus torus ){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    vec3 pos = tv.pos;

    float vxyy=distR3( pos + e.xyy*ep, torus);
    float vyyx=distR3( pos + e.yyx*ep, torus);
    float vyxy=distR3( pos + e.yxy*ep, torus);
    float vxxx=distR3( pos + e.xxx*ep, torus);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//overload of setData for a torus
void setData( inout Path path, Torus torus ){

    //if we are at the surface
    if(at(path.tv, torus)){
        //compute the normal
        Vector normal=normalVec(path.tv, torus);
        bool side = inside(path.tv, torus);
        //set the material
        setObjectInAir(path.dat, side, normal, torus.mat);
    }

}






