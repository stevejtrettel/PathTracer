//-------------------------------------------------
// COMPOUND OBJECTS
// a compound object is built using constructive solid geometry
// or some other more complicated procedure, but has only one material.
//-------------------------------------------------








//-------------------------------------------------
//The BOTTLE sdf
//-------------------------------------------------


struct Bottle{
    Point center;
    float baseRadius;
    float baseHeight;
    float neckRadius;
    float neckHeight;
    float thickness;
    float rounded;
    float smoothJoin;
    float bump;
    Material mat;
    Sphere boundingSphere;
};



//----distance and normal functions

float bottleDistance(vec3 p, Bottle bottle,out float insideBottle ){

    vec3 pos=p-bottle.center.coords;

    //the base of the bottle
    float base=cylinderDist(pos,bottle.baseRadius, bottle.baseHeight,bottle.rounded);

    //the neck of the bottle
    //first: adjust the height
    vec3 q=pos-vec3(0,bottle.baseHeight+bottle.neckHeight,0);

    float neck=cylinderDist(q,bottle.neckRadius,bottle.neckHeight,bottle.rounded);

    //give the subtraction of these:
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

float bottleDistance(vec3 pos, Bottle bottle){
    return bottleDistance(pos,bottle,trashFloat);
}



//the default option: 4 calls of SDF
Vector bottleNormal(Vector tv, Bottle bottle){

    vec3 pos=tv.pos.coords;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=bottleDistance( pos + e.xyy*ep,bottle);
    float vyyx=bottleDistance( pos + e.yyx*ep,bottle);
    float vyxy=bottleDistance( pos + e.yxy*ep,bottle);
    float vxxx=bottleDistance( pos + e.xxx*ep,bottle);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}




//------sdf
float bottleSDF(Path path, Bottle bottle){

    //speed things up only calculating boundign sphere
    float bDist=sphereDistance(path.tv,bottle.boundingSphere);

    if(bDist>0.){
        return bDist+0.01;
    }

    //only if we are inside that, run bottleDist
    return bottleDistance(path.tv.pos.coords,bottle);
}

void setBottleData(inout Path path, Bottle bottle){
    //see if we are at the plane: if not, do nothing
    float dist=bottleDistance(path.tv.pos.coords,bottle);

    if(abs(dist)<EPSILON){
        //compute the normal
        Vector normal=bottleNormal(path.tv,bottle);

        //set the material
        setObjectInAir(path.dat,dist,normal,bottle.mat);
    }

}