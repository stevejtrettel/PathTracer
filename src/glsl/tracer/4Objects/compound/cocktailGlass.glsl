

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





















