//-------------------------------------------------
// MULTI-MATERIAL OBJECTS
// a multi-material object is built using multiple basic/compound objects
//-------------------------------------------------






//-------------------------------------------------
// The COCKTAIL sdf
//-------------------------------------------------

struct Cocktail{
    CocktailGlass glass;
    Material cup;
    Material drink;
    float fill;
};



//we already have a cocktail glass struct
//this includes a function for the glass distance and normal
//but we still need the drink distance and normal



void setTheData(float cup, float drinkSide,float drinkTop, Vector tv, inout localData dat,Cocktail cocktail){

    float eps=2.*EPSILON;
    float drink=max(drinkSide,drinkTop);
    dat.renderMaterial=true;

    //------------------------------------------------
    if(abs(cup)<eps){
        //if we hit the cup (the main option)
        //the normal will be this or its negation
        dat.normal=cocktailGlassNormal(tv,cocktail.glass);

        //whether we are in the drink or not, will use the glass as the interacting material
        dat.surfDiffuse=cocktail.cup.diffuseColor;
        dat.surfSpecular=cocktail.cup.specularColor;
        dat.surfEmit=cocktail.cup.emitColor;
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
        dat.surfEmit=cocktail.drink.emitColor;
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









float cocktailSDF(Path path, Cocktail cocktail){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=cocktailGlassDistance(path.tv.pos.coords,cocktail.glass,drinkSide);

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop=path.tv.pos.coords.y-cocktail.glass.center.coords.y-cocktail.glass.height/3.;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    return min(cup,drink);
}


void setCocktailData(inout Path path, Cocktail cocktail){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=cocktailGlassDistance(path.tv.pos.coords,cocktail.glass,drinkSide);

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop=path.tv.pos.coords.y-cocktail.glass.center.coords.y-cocktail.glass.height/3.;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));


    if(dist<5.*EPSILON){
        setTheData(cup,drinkSide,drinkTop,path.tv,path.dat,cocktail);
    }

}


























//-------------------------------------------------
// The LIQUOR BOTTLE sdf
//-------------------------------------------------

struct LiquorBottle{
    Bottle glass;
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
        dat.normal=bottleNormal(tv,cocktail.glass);

        //whether we are in the drink or not, will use the glass as the interacting material
        dat.surfDiffuse=cocktail.cup.diffuseColor;
        dat.surfSpecular=cocktail.cup.specularColor;
        dat.surfEmit=cocktail.cup.emitColor;
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
        dat.surfEmit=cocktail.drink.emitColor;
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








float liquorBottleSDF(Path path, LiquorBottle gin){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=bottleDistance(path.tv.pos.coords,gin.glass,drinkSide);


    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass

    float drinkTop=path.tv.pos.coords.y-gin.glass.center.coords.y;

    drinkTop-=gin.glass.baseHeight*gin.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    return min(cup,drink);
}




void setLiquorBottleData(inout Path path, LiquorBottle gin){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=bottleDistance(path.tv.pos.coords,gin.glass,drinkSide);


    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass

    float drinkTop=path.tv.pos.coords.y-gin.glass.center.coords.y;

    drinkTop-=gin.glass.baseHeight*gin.fill;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    if(dist<5.*EPSILON){
        setTheData(cup,drinkSide,drinkTop,path.tv,path.dat,gin);
    }

}




