

//-------------------------------------------------
// The LIQUOR BOTTLE sdf
//-------------------------------------------------

struct BottleLiquid{
    Bottle glass;//we don't use the material; just the shape
    Material cup;
    Material drink;
    float fill;
};








//set the local data at a hit: either on the glass surface or the free
//liquid surface, each an interface between two of {air, cup, drink}.
//uses the standard setMaterialInterface(current, neighbor, dominant),
//then overrides roughness with the dominant material's (the helper
//takes it from the neighbor, which would zero it against air).
void setTheData(float cup, float drinkSide,float drinkTop, Vector tv, inout localData dat,BottleLiquid cocktail){

    float eps=2.*EPSILON;
    float drink=max(drinkSide,drinkTop);
    Material airMat = air(vec3(0.));

    if(abs(cup)<eps){
        //we hit the glass surface
        Vector normal=normalVec(tv,cocktail.glass);

        if(cup>0.){
            //hit from outside the glass
            dat.normal=normal;
            if(abs(drink)>eps||drinkTop>0.){
                //far from the drink: air -> cup
                setMaterialInterface(dat, airMat, cocktail.cup, cocktail.cup);
            }
            else{
                //against the drink: drink -> cup
                setMaterialInterface(dat, cocktail.drink, cocktail.cup, cocktail.cup);
            }
        }
        else{
            //hit from inside the glass wall
            dat.normal=negate(normal);
            if(abs(drink)>eps){
                //far from the drink: cup -> air
                setMaterialInterface(dat, cocktail.cup, airMat, cocktail.cup);
            }
            else{
                //entering the drink: cup -> drink
                setMaterialInterface(dat, cocktail.cup, cocktail.drink, cocktail.cup);
            }
        }
        dat.surfRoughness=cocktail.cup.roughness;
    }

    else{
        //we hit the free surface of the liquid (world-horizontal)
        if(drinkTop>0.){
            //from above: air -> drink
            dat.normal=Vector(tv.pos,vec3(0,1,0));
            setMaterialInterface(dat, airMat, cocktail.drink, cocktail.drink);
        }
        else{
            //from below: drink -> air
            dat.normal=Vector(tv.pos,vec3(0,-1,0));
            setMaterialInterface(dat, cocktail.drink, airMat, cocktail.drink);
        }
        dat.surfRoughness=cocktail.drink.roughness;
    }
}








float sdf(Vector tv, BottleLiquid gin){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    //bottleDistance works in the glass's local frame; rescale distances to world
    float cup=gin.glass.frame.scale * bottleDistance(toLocal(gin.glass.frame, tv.pos),gin.glass,drinkSide);
    drinkSide *= gin.glass.frame.scale;

    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass

    float drinkTop=tv.pos.y-gin.glass.frame.pos.y;

    drinkTop-=gin.glass.baseHeight*gin.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    return min(cup,drink);
}


bool inside(Vector tv,BottleLiquid gin){
    return inside(tv,gin.glass);
}


void setData(inout Path path, BottleLiquid gin){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    //bottleDistance works in the glass's local frame; rescale distances to world
    float cup=gin.glass.frame.scale * bottleDistance(toLocal(gin.glass.frame, path.tv.pos),gin.glass,drinkSide);
    drinkSide *= gin.glass.frame.scale;


    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass

    float drinkTop=path.tv.pos.y-gin.glass.frame.pos.y;

    drinkTop-=gin.glass.baseHeight*gin.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    if(dist<5.*EPSILON){
        setTheData(cup,drinkSide,drinkTop,path.tv,path.dat,gin);
    }

}


