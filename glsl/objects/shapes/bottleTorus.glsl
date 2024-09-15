


//-------------------------------------------------
//The DONUT BOTTLE sdf
//-------------------------------------------------

//a donut bottle is a smooth union of a truncated cone and a torus:

struct BottleTorus{
//need a position, a height, base/top sizes, and glass thickness
    vec3 center;
    float outer;
    float inner;
    float height;
    float base;
    float flare;//factor of toprad/bottomrad
    float smoothing; //how much smoothing happens
    float thickness;
    Material mat;
};


float bottleTorusDistance(vec3 pos, BottleTorus donut, out float insideBottle){

    //get position relative center
    vec3 torusPos = pos - donut.center;
    //get position relative to torus
    vec3  conePos = torusPos - vec3(0,donut.outer+donut.inner+donut.height,0);

    //get torus portion
    float base = sdTorus(torusPos, donut.outer, donut.inner);

    //get cone1 portion:
    float donutTop = donut.flare*donut.base;
    float neck =sdCappedCone(conePos, 0.8*donut.height, donut.base, donutTop);

    //give the subtraction of these:
    float theBottle=opMinDist( base, neck, donut.smoothing );

    //make the shell
    theBottle=opOnionDist(theBottle,donut.thickness);


    float top=conePos.y-1.7;
    theBottle=opMaxDist(theBottle,top,donut.thickness);

    return theBottle;

    //
    //    //chop off the top:
    //    float top=q.y-bottle.neckHeight/3.;
    //
    //    theBottle=opMaxDist(theBottle,top,bottle.thickness);
    //
    //    return abs(smin(torusDist,coneDist,donut.smoothing))-donut.thickness;
}



//overload of distR3
float distR3( vec3 pos, BottleTorus donut ){

    return bottleTorusDistance(pos, donut, trashFloat);

}


//overload of location booleans:
bool at( Vector tv, BottleTorus donut){

    float d = distR3( tv.pos, donut );
    return  (abs(d) < AT_THRESH);

}

bool inside( Vector tv, BottleTorus donut ){
    float d = distR3( tv.pos, donut );
    return (d < 0.);
}



//overload of sdf
float sdf( Vector tv, BottleTorus donut ){

    return distR3(tv.pos, donut);
}

//overload of normalVec
Vector normalVec( Vector tv, BottleTorus donut ){
    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, donut);
    float vyyx=distR3( pos + e.yyx*ep, donut);
    float vyxy=distR3( pos + e.yxy*ep, donut);
    float vxxx=distR3( pos + e.xxx*ep, donut);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}


//overload of setData for a sphere
void setData( inout Path path, BottleTorus donut ){

    //if we are at the surface
    if(at(path.tv, donut)){
        //compute the normal
        Vector normal=normalVec(path.tv, donut);
        bool side = inside(path.tv, donut);
        //set the material
        setObjectInAir(path.dat, side, normal, donut.mat);
    }

}
