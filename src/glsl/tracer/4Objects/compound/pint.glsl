

//-------------------------------------------------
//The PINT GLASS sdf
//-------------------------------------------------

//a pint glass is the subtraction of two truncated cones:

struct Pint{
//need a position, a height, base/top sizes, and glass thickness
    vec3 center;
    float height;
    float base;
    float flare;//factor of toprad/bottomrad
    float thickness;
    float rounded;
    Material mat;
};


float pintDistance(vec3 pos, Pint pint, out float insideBottle){

    //get position relative to point on plane
    vec3 pOut = pos - pint.center;

    //get first cone:
    float outerWall=sdCappedCone(pOut, pint.height, pint.base, pint.flare*pint.base)-0.1;

    //get the second one
    pint.center+=vec3(0,2.*pint.thickness,0);
    vec3 pIn=pos-pint.center-vec3(0,0.4,0);
    insideBottle=sdCappedCone(pIn, pint.height+0.2, pint.base-pint.thickness, pint.flare*(pint.base-pint.thickness));
    //return outerWall;
    return smax(outerWall,-insideBottle,0.1);

}



//overload of distR3
float distR3( vec3 pos, Pint pint ){

    return pintDistance(pos, pint, trashFloat);

}


//overload of location booleans:
bool at( Vector tv, Pint pint){

    float d = distR3( tv.pos, pint );
    return  (abs(d) < AT_THRESH);

}

bool inside( Vector tv, Pint pint ){
    float d = distR3( tv.pos, pint );
    return (d < 0.);
}



//overload of sdf
float sdf( Vector tv, Pint pint ){

    return distR3(tv.pos, pint);
}

//overload of normalVec
Vector normalVec( Vector tv, Pint pint ){
    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, pint);
    float vyyx=distR3( pos + e.yyx*ep, pint);
    float vyxy=distR3( pos + e.yxy*ep, pint);
    float vxxx=distR3( pos + e.xxx*ep, pint);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}


//overload of setData for a sphere
void setData( inout Path path, Pint pint ){

    //if we are at the surface
    if(at(path.tv, pint)){
        //compute the normal
        Vector normal=normalVec(path.tv, pint);
        bool side = inside(path.tv, pint);
        //set the material
        setObjectInAir(path.dat, side, normal, pint.mat);
    }

}










