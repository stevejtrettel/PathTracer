

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
void setTheData(float cup, float drinkSide,float drinkTop, Vector tv, inout LocalData dat,BottleLiquid liquid){

    float eps=2.*EPSILON;
    float drink=max(drinkSide,drinkTop);
    Material airMat = air(vec3(0.));

    if(abs(cup)<eps){
        //we hit the glass surface
        Vector normal=normalVec(tv,liquid.glass);

        if(cup>0.){
            //hit from outside the glass
            dat.normal=normal;
            if(abs(drink)>eps||drinkTop>0.){
                //far from the drink: air -> cup
                setMaterialInterface(dat, airMat, liquid.cup, liquid.cup);
            }
            else{
                //against the drink: drink -> cup
                setMaterialInterface(dat, liquid.drink, liquid.cup, liquid.cup);
            }
        }
        else{
            //hit from inside the glass wall
            dat.normal=negate(normal);
            if(abs(drink)>eps){
                //far from the drink: cup -> air
                setMaterialInterface(dat, liquid.cup, airMat, liquid.cup);
            }
            else{
                //entering the drink: cup -> drink
                setMaterialInterface(dat, liquid.cup, liquid.drink, liquid.cup);
            }
        }
        dat.surfRoughness=liquid.cup.roughness;
    }

    else{
        //we hit the free surface of the liquid (world-horizontal)
        if(drinkTop>0.){
            //from above: air -> drink
            dat.normal=Vector(tv.pos,vec3(0,1,0));
            setMaterialInterface(dat, airMat, liquid.drink, liquid.drink);
        }
        else{
            //from below: drink -> air
            dat.normal=Vector(tv.pos,vec3(0,-1,0));
            setMaterialInterface(dat, liquid.drink, airMat, liquid.drink);
        }
        dat.surfRoughness=liquid.drink.roughness;
    }
}








float sdf(Vector tv, BottleLiquid liquid){

    //bounding cylinder: the whole drink lives inside the bottle, so the bottle's
    //own bound contains the composite. skip the (medium) sdf when far.
    float b = liquid.glass.frame.scale * bound(toLocal(liquid.glass.frame, tv.pos), liquid.glass);
    if( b > BOUND_MARGIN ) return b;

    float drinkSide;

    //sets the distance to the glass part of the cup; drinkSide gets the sdf of its interior (the drink volume)
    //bottleDistance works in the glass's local frame; rescale distances to world
    float cup=liquid.glass.frame.scale * bottleDistance(toLocal(liquid.glass.frame, tv.pos),liquid.glass,drinkSide);
    drinkSide *= liquid.glass.frame.scale;

    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass

    float drinkTop=tv.pos.y-liquid.glass.frame.pos.y;

    drinkTop-=liquid.glass.baseHeight*liquid.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    return min(cup,drink);
}


bool inside(Vector tv,BottleLiquid liquid){
    return inside(tv,liquid.glass);
}


void setData(inout Path path, BottleLiquid liquid){

    float drinkSide;

    //sets the distance to the glass part of the cup; drinkSide gets the sdf of its interior (the drink volume)
    //bottleDistance works in the glass's local frame; rescale distances to world
    float cup=liquid.glass.frame.scale * bottleDistance(toLocal(liquid.glass.frame, path.tv.pos),liquid.glass,drinkSide);
    drinkSide *= liquid.glass.frame.scale;


    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass

    float drinkTop=path.tv.pos.y-liquid.glass.frame.pos.y;

    drinkTop-=liquid.glass.baseHeight*liquid.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    if(dist<5.*EPSILON){
        setTheData(cup,drinkSide,drinkTop,path.tv,path.dat,liquid);
    }

}


