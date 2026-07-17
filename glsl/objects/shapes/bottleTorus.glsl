


//-------------------------------------------------
//The BOTTLE TORUS sdf
//-------------------------------------------------

//a donut bottle is a smooth union of a truncated cone and a torus:

struct BottleTorus{
//need a placement, a height, base/top sizes, and glass thickness
    Frame frame;
    float outer;
    float inner;
    float height;
    float base;
    float flare;//factor of toprad/bottomrad
    float smoothing; //how much smoothing happens
    float thickness;
    Material mat;
};


//takes a position in the bottle's LOCAL coordinates
float bottleTorusDistance(vec3 pos, BottleTorus donut, out float insideBottle){

    //position is already relative to the center (local coordinates)
    vec3 torusPos = pos;
    //get position relative to torus
    vec3  conePos = torusPos - vec3(0,donut.outer+donut.inner+donut.height,0);

    //get torus portion
    float base = sdTorus(torusPos, donut.outer, donut.inner);

    //the cone portion:
    float donutTop = donut.flare*donut.base;
    float neck =sdCappedCone(conePos, 0.8*donut.height, donut.base, donutTop);

    //give the smooth union of these:
    float theBottle=opMinDist( base, neck, donut.smoothing );

    //make the shell
    theBottle=opOnionDist(theBottle,donut.thickness);


    float top=conePos.y-1.7;
    theBottle=opMaxDist(theBottle,top,donut.thickness);

    return theBottle;
}



//the point-level sdf
float sdf( vec3 pos, BottleTorus donut ){

    return bottleTorusDistance(pos, donut, trashFloat);

}

//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(BottleTorus)
