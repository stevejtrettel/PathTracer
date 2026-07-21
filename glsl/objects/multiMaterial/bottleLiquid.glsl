

//-------------------------------------------------
// The LIQUOR BOTTLE sdf
//-------------------------------------------------

struct BottleLiquid{
    Bottle glass;//we don't use the material; just the shape
    Material cup;
    Material drink;
    float fill;
};


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

    //distance to the top of the drink (fill=0 is the bottom of the glass)
    float drinkTop=tv.pos.y-liquid.glass.frame.pos.y-liquid.glass.baseHeight*liquid.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    return min(cup,drink);
}


bool inside(Vector tv,BottleLiquid liquid){
    return inside(tv,liquid.glass);
}


//overload of set data — structured to match multiMaterial/cocktail.glsl and beer.glsl:
//setObjectInAir for the air-facing hits, setMaterialInterface only for the true
//cup <-> drink boundary.
void setData(inout Path path, BottleLiquid liquid){

    float drinkSide;

    //sets the distance to the glass part of the cup; drinkSide gets the sdf of its interior (the drink volume)
    //bottleDistance works in the glass's local frame; rescale distances to world
    float cup=liquid.glass.frame.scale * bottleDistance(toLocal(liquid.glass.frame, path.tv.pos),liquid.glass,drinkSide);
    drinkSide *= liquid.glass.frame.scale;

    //distance to the top of the drink (fill=0 is the bottom of the glass)
    float drinkTop=path.tv.pos.y-liquid.glass.frame.pos.y-liquid.glass.baseHeight*liquid.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    Vector normal;
    float eps=AT_THRESH;

    if(abs(cup)<AT_THRESH){
        //----if we hit the cup
        //normal is automatically from the cup (or its negation)
        normal=normalVec(path.tv,liquid.glass);

        if(cup>0.){
            //if we hit the cup from outside its glass
            //but did we hit it near the drink?
            if(abs(drink)>eps||drinkTop>0.){
                //we hit the cup from the air, far from the drink
                setObjectInAir(path.dat,false,normal,liquid.cup);
            }
            else{
                //we hit the cup from inside the drink
                //cup is dominant material
                path.dat.normal=normal;
                setMaterialInterface(path.dat,liquid.drink,liquid.cup,liquid.cup);
            }
        }
        else{
            //we hit the cup from inside its own glass
            if(abs(drink)>eps){
                //we are exiting the glass into the air
                setObjectInAir(path.dat,true,normal,liquid.cup);
            }
            else{
                //we are exiting the glass into the drink
                //drink is dominant material
                path.dat.normal=negate(normal);
                setMaterialInterface(path.dat,liquid.cup,liquid.drink,liquid.drink);
            }
        }
    }
    //------------------------------------------------
    else if(abs(drink)<AT_THRESH){
        //if we didn't hit the cup, but we hit the liquid's surface
        //normal vector is just pointed straight upward
        normal=Vector(path.tv.pos,vec3(0,1,0));
        //are we coming from above or below the water line?
        bool insideMat = drinkTop>0. ? false : true;
        setObjectInAir(path.dat,insideMat,normal,liquid.drink);
    }

}
