

//-------------------------------------------------
//The PINT GLASS sdf
//-------------------------------------------------

//a pint glass is the subtraction of two truncated cones:

struct Pint{
//need a placement, a height, base/top sizes, and glass thickness
    Frame frame;
    float height;
    float base;
    float flare;//factor of toprad/bottomrad
    float thickness;
    float rounded;
    Material mat;
};


//takes a position in the pint's LOCAL coordinates
float pintDistance(vec3 pos, Pint pint, out float insideGlass){

    //position is already relative to the center (local coordinates)
    vec3 pOut = pos;

    //get first cone:
    float outerWall=sdCappedCone(pOut, pint.height, pint.base, pint.flare*pint.base)-0.1;

    //get the second one: shifted up by 2*thickness (was center+=vec3(0,2.*thickness,0))
    vec3 pIn=pos-vec3(0,2.*pint.thickness,0)-vec3(0,0.4,0);
    insideGlass=sdCappedCone(pIn, pint.height+0.2, pint.base-pint.thickness, pint.flare*(pint.base-pint.thickness));
    return smax(outerWall,-insideGlass,0.1);

}



//the point-level sdf
float sdf( vec3 pos, Pint pint ){

    return pintDistance(pos, pint, trashFloat);

}

//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(Pint)










