

//-------------------------------------------------
//The COCKTAIL GLASS sdf
//-------------------------------------------------


//the distance function here is reused by other objects (see multiMaterial/cocktail.glsl),
//where knowing the distance to the enclosed volume is helpful: the out parameter
//insideGlass returns the sdf of the glass's interior cavity

struct CocktailGlass{
    Frame frame;
    float radius;
    float height;
    float thickness;
    float base;
    Material mat;
};


//takes a position in the glass's LOCAL coordinates
float cocktailGlassDistance(vec3 p, CocktailGlass glass, out float insideGlass){

    vec3 pos=p;

    float outside=cylinderDistance(pos,glass.radius,glass.height,0.1);

    //the height is the "half height" of the glass....
    vec3 q=pos-vec3(0,2.*glass.base,0);

    float inside=cylinderDistance(q,glass.radius-glass.thickness,glass.height,0.05);

    //the glass
    float dist= max(outside,-inside);

    //now subtract ball from bottom
    q=pos+vec3(0,glass.height-1.75*glass.base/2.5,0.);
    float ball=length(q)-2.*glass.base/2.5;

    insideGlass=inside;
    return smax(dist,-ball,0.2);
}


//the point-level sdf
float sdf( vec3 p, CocktailGlass glass ){
    return cocktailGlassDistance(p, glass, trashFloat);
}

//local bounding cylinder: the bowl (radius, height) plus the base ball below,
//about the y-axis (generous margins).
float bound( vec3 p, CocktailGlass glass ){
    return bCyl(p, vec2(glass.radius + 0.3, glass.height + 2.0*glass.base + 1.0));
}

//the standard interface pieces: initObject, at, inside, sdf, normalVec (custom bound above)
OBJECT_INIT(CocktailGlass)
OBJECT_LOCATORS_B(CocktailGlass)
OBJECT_NORMAL_FD(CocktailGlass)

//overload of location booleans
//note inside here means in the glass of the cup not the enclosed volume
bvec2 relPosition( Vector tv, CocktailGlass glass ){
    float d = sdf( tv, glass );
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
