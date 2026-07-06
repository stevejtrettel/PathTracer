


//-------------------------------------------------
//The BOTTLE TORUS sdf
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



//the point-level sdf
float sdf( vec3 pos, BottleTorus donut ){

    return bottleTorusDistance(pos, donut, trashFloat);

}

//the standard interface: at, inside, sdf, normalVec, setData
UNFRAMED_OBJECT_API(BottleTorus)
