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
//    float bDist=sphereDistance(path.tv,bottle.boundingSphere);
//
//    if(bDist>0.){
//        return bDist+0.01;
//    }

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


























//-------------------------------------------------
//The COCKTAIL GLASS sdf
//-------------------------------------------------


//the distance function here will be used again in future functions, where knowing "inside" will be helpful.
//thus the first distance function has an inout telling you if you are inside the glass

struct CocktailGlass{
    Point center;
    float radius;
    float height;
    float thickness;
    float base;
    Material mat;
};


float cocktailGlassDistance(vec3 p, CocktailGlass glass,inout float insideDist){

    vec3 pos=p-glass.center.coords;

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


//overload not worrying about if we are inside the glass
float cocktailGlassDistance(vec3 p, CocktailGlass glass){
    return cocktailGlassDistance(p,glass,trashFloat);
}


float cocktailGlassDistance(Vector tv,CocktailGlass glass){
    return cocktailGlassDistance(tv.pos.coords,glass);
}



Vector cocktailGlassNormal(Vector tv, CocktailGlass glass){

    vec3 pos=tv.pos.coords;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=cocktailGlassDistance( pos + e.xyy*ep,glass);
    float vyyx=cocktailGlassDistance( pos + e.yyx*ep,glass);
    float vyxy=cocktailGlassDistance( pos + e.yxy*ep,glass);
    float vxxx=cocktailGlassDistance( pos + e.xxx*ep,glass);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}





//------sdf
float cocktailGlassSDF(Path path, CocktailGlass glass){

    float dist = cocktailGlassDistance(path.tv,glass);

    return dist;

}




void setCocktailGlassData(inout Path path, CocktailGlass glass){
    //see if we are at the plane: if not, do nothing
    float dist=cocktailGlassDistance(path.tv,glass);

    if(abs(dist)<EPSILON){
        //compute the normal
        Vector normal=cocktailGlassNormal(path.tv,glass);

        //set the material
        setObjectInAir(path.dat,dist,normal,glass.mat);
    }

}


