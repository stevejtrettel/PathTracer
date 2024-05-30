

//-------------------------------------------------
//The BOTTLE sdf
//-------------------------------------------------


struct Bottle{
    vec3 center;
    float baseRadius;
    float baseHeight;
    float neckRadius;
    float neckHeight;
    float thickness;
    float rounded;
    float smoothJoin;
    float bump;
    Material mat;
    Sphere boundingBox;
};



//----distance and normal functions

//auxilary function calculating bottle distance, and giving inside/outside info
float bottleDistance(vec3 p, Bottle bottle,out float insideBottle ){

    vec3 pos=p-bottle.center;

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



//overload: the distance in coordinates
float distR3(vec3 pos, Bottle bottle){
    return bottleDistance(pos,bottle,trashFloat);
}


//overload of sdf
float sdf(Vector tv, Bottle bottle){

    //    //only bother if we are inside the bounding sphere:
    //    float bBox=sdf(tv, bottle.boundingBox);
    //
    //    if(bBox>0.){
    //        //if we are outisde the box, march towards it
    //        return bBox+0.05;
    //    }

    //if we are inside, compute the actual distance
    return distR3(tv.pos, bottle);
}



//overload of normalVec
Vector normalVec(Vector tv, Bottle bottle){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, bottle);
    float vyyx=distR3( pos + e.yyx*ep, bottle);
    float vyxy=distR3( pos + e.yxy*ep, bottle);
    float vxxx=distR3( pos + e.xxx*ep, bottle);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

//overload of location booleans:
bool at( Vector tv, Bottle bottle){

    float d = distR3( tv.pos, bottle );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

//note inside here means in the glass of the bottle not the enclosed volume
bool inside( Vector tv, Bottle bottle ){
    float d = distR3( tv.pos, bottle );
    return (d<0.);
}


//overload of setData for a sphere
void setData( inout Path path, Bottle bottle ){

    //if we are at the surface
    if(at(path.tv, bottle)){
        //compute the normal
        Vector normal=normalVec(path.tv,bottle);
        bool side = inside(path.tv, bottle);
        //set the material
        setObjectInAir(path.dat, side, normal, bottle.mat);
    }

}




