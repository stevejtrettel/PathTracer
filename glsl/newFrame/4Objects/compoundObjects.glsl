//-------------------------------------------------
// COMPOUND OBJECTS
// a compound object is built using constructive solid geometry
// or some other more complicated procedure, but has only one material.
//-------------------------------------------------




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




//auxilary function (From IQ) which is the truncated cone:
float sdCappedCone( vec3 p, float h, float r1, float r2 )
{
    vec2 q = vec2( length(p.xz), p.y );
    vec2 k1 = vec2(r2,h);
    vec2 k2 = vec2(r2-r1,2.0*h);
    vec2 ca = vec2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
    vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot(k2,k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot(ca,ca),dot(cb,cb)) );
}






//overload of distR3
float distR3( vec3 pos, Pint pint ){

    //get position relative to point on plane
    vec3 pOut = pos - pint.center;

    //get first cone:
    float outerWall=sdCappedCone(pOut, pint.height, pint.base, pint.flare*pint.base);

    //get the second one
    pint.center+=vec3(0,2.*pint.thickness,0);
    vec3 pIn=pos-pint.center;
    float innerWall=sdCappedCone(pIn, pint.height, pint.base-pint.thickness, pint.flare*(pint.base-pint.thickness));
    //return outerWall;
    return max(outerWall,-innerWall);

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























//-------------------------------------------------
//The COCKTAIL GLASS sdf
//-------------------------------------------------


//the distance function here will be used again in future functions, where knowing "inside" will be helpful.
//thus the first distance function has an inout telling you if you are inside the glass

struct CocktailGlass{
    vec3 center;
    float radius;
    float height;
    float thickness;
    float base;
    Material mat;
    Sphere boundingBox;
};


float cocktailGlassDistance(vec3 p, CocktailGlass glass,inout float insideDist){

    vec3 pos=p-glass.center;

    float outside=cylinderDist(pos,glass.radius,glass.height,0.1);

    //the height is the "half height" of the glass....
    vec3 q=pos-vec3(0,2.*glass.base,0);

    float inside=cylinderDist(q,glass.radius-glass.thickness,glass.height,0.05);

    //insideTheGlass=(inside<0.)?true:false;

    //the glass
    float dist= max(outside,-inside);

    //now subtract ball from bottom
    q=pos+vec3(0,glass.height-1.75*glass.base/2.5,0.);
    float ball=length(q)-2.*glass.base/2.5;

    insideDist=inside;
    return smax(dist,-ball,0.2);
}


//overload of distR3
float distR3( vec3 p, CocktailGlass glass ){
    return cocktailGlassDistance(p, glass, trashFloat);
}


//overload of sdf
float sdf(Vector tv, CocktailGlass glass){

    //only bother if we are inside the bounding sphere:
//    float bBox=sdf(tv, glass.boundingBox);
//
//    if(bBox>0.){
//        //if we are outisde the box, march towards it
//        return bBox+0.05;
//    }

    //if we are inside, compute the actual distance
    return distR3(tv.pos, glass);
}

//overload of normalVec
Vector normalVec(Vector tv, CocktailGlass glass){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, glass);
    float vyyx=distR3( pos + e.yyx*ep, glass);
    float vyxy=distR3( pos + e.yxy*ep, glass);
    float vxxx=distR3( pos + e.xxx*ep, glass);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

//overload of location booleans
//note inside here means in the glass of the cup not the enclosed volume
bvec2 relPosition( Vector tv, CocktailGlass glass ){
    float d = distR3( tv.pos, glass );
    bool atSurf = ((abs(d)-AT_THRESH)<0.);
    bool inside = (d<0.);
    return bvec2(atSurf, inside);
}



//overload of setData
void setData(inout Path path, CocktailGlass glass){

    bvec2 loc=relPosition(path.tv, glass);

    //if we are at the surface
    if(loc.x){
        //compute the normal
        Vector normal=normalVec(path.tv, glass);
        bool inside=loc.y;
        //set the material
        setObjectInAir(path.dat,inside,normal,glass.mat);
    }

}

