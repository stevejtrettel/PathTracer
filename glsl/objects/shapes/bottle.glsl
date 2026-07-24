

//-------------------------------------------------
//The BOTTLE sdf
//-------------------------------------------------


struct Bottle{
    Frame frame;
    float baseRadius;
    float baseHeight;
    float neckRadius;
    float neckHeight;
    float thickness;
    float rounded;
    float smoothJoin;
    float bump;
    Material mat;
};



//----distance and normal functions

//auxiliary function calculating bottle distance, and giving inside/outside info
//takes a position in the bottle's LOCAL coordinates
float bottleDistance(vec3 p, Bottle bottle,out float insideBottle ){

    vec3 pos=p;

    //the base of the bottle
    float base=cylinderDistance(pos,bottle.baseRadius, bottle.baseHeight,bottle.rounded);

    //the neck of the bottle
    //first: adjust the height
    vec3 q=pos-vec3(0,bottle.baseHeight+bottle.neckHeight,0);

    float neck=cylinderDistance(q,bottle.neckRadius,bottle.neckHeight,bottle.rounded);

    //give the smooth union of these:
    float theBottle=opMinDist(base, neck,bottle.smoothJoin);

    if(bottle.bump!=0.){
        vec3 r=pos+vec3(0,bottle.baseHeight,0.);
        float bump=length(r)-0.25;
        theBottle=opMaxDist(theBottle,-bump,1.);
    }

    insideBottle=theBottle+bottle.thickness;

    //make the shell
    theBottle=opOnionDist(theBottle,bottle.thickness);

    //chop off the top:
    float top=q.y-bottle.neckHeight/3.;

    theBottle=opMaxDist(theBottle,top,bottle.thickness);

    return theBottle;

}



//the point-level sdf
float sdf(vec3 pos, Bottle bottle){
    return bottleDistance(pos,bottle,trashFloat);
}

//local bounding cylinder, tight and CENTERED ON THE SHAPE, not the origin: the
//bottle's extents are asymmetric (bottom at -(baseHeight+rounded+thickness), top at
//the chopped neck, baseHeight + 4/3*neckHeight), so a symmetric cylinder wastes
//~neckHeight of empty bound both above and below — the old bound nearly doubled the
//marched volume on tall bottles. Radially the shell reaches baseRadius + thickness
//PLUS the smooth-join bulge: smin extends the surface outward by up to smoothJoin/4
//where base and neck are equidistant (the old fixed +0.3 under-covered big joins).
//0.1 margins; verified conservative (bound <= sdf) over all scene parameter sets.
float bound( vec3 p, Bottle bottle ){
    float yTop = bottle.baseHeight + (4./3.)*bottle.neckHeight + bottle.thickness + 0.1;
    float yBot = -(bottle.baseHeight + bottle.rounded + bottle.thickness + 0.1);
    float R    = bottle.baseRadius + bottle.thickness + 0.25*bottle.smoothJoin + 0.1;
    return bCyl(p - vec3(0., 0.5*(yTop + yBot), 0.), vec2(R, 0.5*(yTop - yBot)));
}

//the standard interface: initObject, at, inside, sdf, normalVec, setData (custom bound above)
OBJECT_API_B(Bottle)
