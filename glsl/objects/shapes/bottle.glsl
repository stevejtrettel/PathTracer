

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
    float base=cylinderDist(pos,bottle.baseRadius, bottle.baseHeight,bottle.rounded);

    //the neck of the bottle
    //first: adjust the height
    vec3 q=pos-vec3(0,bottle.baseHeight+bottle.neckHeight,0);

    float neck=cylinderDist(q,bottle.neckRadius,bottle.neckHeight,bottle.rounded);

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

//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(Bottle)
