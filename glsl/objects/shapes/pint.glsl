

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



//the point-level sdf
float sdf( vec3 pos, Pint pint ){

    return pintDistance(pos, pint, trashFloat);

}

//the standard interface: at, inside, sdf, normalVec, setData
UNFRAMED_OBJECT_API(Pint)










