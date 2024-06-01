

//-------------------------------------------------
// The LIQUOR BOTTLE sdf
//-------------------------------------------------

struct LiquorBottle{
    Bottle glass;//we don't use the material; just the shape
    Material cup;
    Material drink;
    float fill;
};








void setTheData(float cup, float drinkSide,float drinkTop, Vector tv, inout localData dat,LiquorBottle cocktail){

    float eps=2.*EPSILON;
    float drink=max(drinkSide,drinkTop);

    dat.renderMaterial=true;

    //------------------------------------------------
    if(abs(cup)<eps){
        //if we hit the cup (the main option)
        //the normal will be this or its negation
        dat.normal=normalVec(tv,cocktail.glass);

        //whether we are in the drink or not, will use the glass as the interacting material
        dat.surfDiffuse=cocktail.cup.diffuseColor;
        dat.surfSpecular=cocktail.cup.specularColor;
        dat.surfEmit=cocktail.cup.surfaceEmit;
        dat.surfRoughness=cocktail.cup.roughness;

        dat.probSpecular=cocktail.cup.specularChance;
        dat.probRefract=cocktail.cup.refractionChance;
        dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;

        //if we hit the cup from inside or outside determines direction of normal
        if(cup>0.){
            //we hit the cup from outside
            //the normal stays the same
            //but did we hit it near the drink?
            if(abs(drink)>eps||drinkTop>0.){
                //we are far from drink
                //dat.materialInterface=false;
                dat.IOR=1./cocktail.cup.IOR;
                dat.reflectAbsorb=vec3(0.);
                dat.refractAbsorb=cocktail.cup.absorbColor;
            }
            else{
                //we are inside the drink
                //dat.materialInterface=true;
                dat.IOR=cocktail.drink.IOR/cocktail.cup.IOR;
                dat.reflectAbsorb=cocktail.drink.absorbColor;
                dat.refractAbsorb=cocktail.cup.absorbColor;
            }

        }
        else{
            //we hit the cup from inside the glass
            //normal gets reversed
            dat.normal=negate(dat.normal);
            //again, did we hit it near the drink?
            if(abs(drink)>eps){
                //we are far from the drink
                //dat.materialInterface=false;
                dat.IOR=cocktail.cup.IOR/1.;
                dat.reflectAbsorb=cocktail.cup.absorbColor;
                dat.refractAbsorb=vec3(0.);
            }
            else{
                //we are entering the drink
                //dat.materialInterface=true;
                dat.IOR=cocktail.cup.IOR/cocktail.drink.IOR;
                dat.reflectAbsorb=cocktail.cup.absorbColor;
                dat.refractAbsorb=cocktail.drink.absorbColor;
            }
        }

    }
    //------------------------------------------------


    //------------------------------------------------
    else{
        //if we didn't hit the cup, we hit the liquid's surface
        dat.surfDiffuse=cocktail.drink.diffuseColor;
        dat.surfSpecular=cocktail.drink.specularColor;
        dat.surfEmit=cocktail.drink.surfaceEmit;
        dat.surfRoughness=cocktail.drink.roughness;

        dat.probSpecular=cocktail.drink.specularChance;
        dat.probRefract=cocktail.drink.refractionChance;
        dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;

        //upward normal
        dat.normal=Vector(tv.pos,vec3(0,1,0));
        //dat.materialInterface=false;

        //only two options: above or below water line:
        if(drinkTop>0.){
            //above the water line
            dat.IOR=1./cocktail.drink.IOR;
            dat.reflectAbsorb=vec3(0.);
            dat.refractAbsorb=cocktail.drink.absorbColor;
        }
        else{
            //below the water line
            //reverse the normal
            dat.normal=negate(dat.normal);
            dat.IOR=cocktail.drink.IOR/1.;
            dat.reflectAbsorb=cocktail.drink.absorbColor;
            dat.refractAbsorb=vec3(0.);
        }

    }
    //------------------------------------------------
}








float sdf(Vector tv, LiquorBottle gin){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=bottleDistance(tv.pos,gin.glass,drinkSide);


    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass

    float drinkTop=tv.pos.y-gin.glass.center.y;

    drinkTop-=gin.glass.baseHeight*gin.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    return min(cup,drink);
}




void setData(inout Path path, LiquorBottle gin){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=bottleDistance(path.tv.pos,gin.glass,drinkSide);


    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass

    float drinkTop=path.tv.pos.y-gin.glass.center.y;

    drinkTop-=gin.glass.baseHeight*gin.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    if(dist<5.*EPSILON){
        setTheData(cup,drinkSide,drinkTop,path.tv,path.dat,gin);
    }

}


