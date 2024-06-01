
//-------------------------------------------------
// The BEER sdf
//-------------------------------------------------

struct Beer{
    Pint glass;
    Material cup;
    Material drink;
    float fill;
};

//void setTheData(float cup, float drinkSide,float drinkTop, Vector tv, inout localData dat,Beer beer){
//
//    float eps=2.*EPSILON;
//    float drink=max(drinkSide,drinkTop);
//    dat.renderMaterial=true;
//
//    //------------------------------------------------
//    if(abs(cup)<eps){
//        //if we hit the cup (the main option)
//        //the normal will be this or its negation
//        dat.normal=normalVec(tv,beer.glass);
//
//        //whether we are in the drink or not, will use the glass as the interacting material
//        dat.surfDiffuse=beer.cup.diffuseColor;
//        dat.surfSpecular=beer.cup.specularColor;
//        dat.surfEmit=beer.cup.surfaceEmit;
//        dat.surfRoughness=beer.cup.roughness;
//
//        dat.probSpecular=beer.cup.specularChance;
//        dat.probRefract=beer.cup.refractionChance;
//        dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;
//
//        //if we hit the cup from inside or outside determines direction of normal
//        if(cup>0.){
//            //we hit the cup from outside
//            //the normal stays the same
//            //but did we hit it near the drink?
//            if(abs(drink)>eps||drinkTop>0.){
//                //we are far from drink
//                //dat.materialInterface=false;
//                dat.IOR=1./beer.cup.IOR;
//                dat.reflectAbsorb=vec3(0.);
//                dat.refractAbsorb=beer.cup.absorbColor;
//                dat.subSurface=beer.cup.subSurface;
//                dat.meanFreePath=beer.cup.meanFreePath;
//            }
//            else{
//                //we are inside the drink
//                //dat.materialInterface=true;
//                dat.IOR=beer.drink.IOR/beer.cup.IOR;
//                dat.reflectAbsorb=beer.drink.absorbColor;
//                dat.refractAbsorb=beer.cup.absorbColor;
//                dat.subSurface=beer.cup.subSurface;
//                dat.meanFreePath=beer.cup.meanFreePath;
//            }
//
//        }
//        else{
//            //we hit the cup from inside the glass
//            //normal gets reversed
//            dat.normal=negate(dat.normal);
//            //again, did we hit it near the drink?
//            if(abs(drink)>eps){
//                //we are far from the drink
//                //dat.materialInterface=false;
//                dat.IOR=beer.cup.IOR/1.;
//                dat.reflectAbsorb=beer.cup.absorbColor;
//                dat.refractAbsorb=vec3(0.);
//                dat.subSurface=false;//air
//                dat.meanFreePath=maxDist;
//            }
//            else{
//                //we are entering the drink
//                //RESET PROBABILITIES FROM THE DRINK
//                dat.probSpecular=beer.drink.specularChance;
//                dat.probRefract=beer.drink.refractionChance;
//                dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;
//
//                dat.IOR=beer.cup.IOR/beer.drink.IOR;
//                dat.reflectAbsorb=beer.cup.absorbColor;
//                dat.refractAbsorb=beer.drink.absorbColor;
//                dat.subSurface=beer.drink.subSurface;
//                dat.meanFreePath=beer.drink.meanFreePath;
//                dat.surfRoughness=beer.drink.roughness;
//            }
//        }
//
//    }
//    //------------------------------------------------
//
//
//    //------------------------------------------------
//    else{
//        //if we didn't hit the cup, we hit the liquid's surface
//        dat.surfDiffuse=beer.drink.diffuseColor;
//        dat.surfSpecular=beer.drink.specularColor;
//        dat.surfEmit=beer.drink.surfaceEmit;
//        dat.surfRoughness=beer.drink.roughness;
//
//        dat.probSpecular=beer.drink.specularChance;
//        dat.probRefract=beer.drink.refractionChance;
//        dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;
//
//        //upward normal
//        dat.normal=Vector(tv.pos,vec3(0,1,0));
//        //dat.materialInterface=false;
//
//        //only two options: above or below water line:
//        if(drinkTop>0.){
//            //above the water line
//            dat.IOR=1./beer.drink.IOR;
//            dat.reflectAbsorb=vec3(0.);
//            dat.refractAbsorb=beer.drink.absorbColor;
//            dat.subSurface=beer.drink.subSurface;
//            dat.meanFreePath=beer.drink.meanFreePath;
//            dat.surfRoughness=beer.drink.roughness;
//        }
//        else{
//            //below the water line
//            //reverse the normal
//            dat.normal=negate(dat.normal);
//            dat.IOR=beer.drink.IOR/1.;
//            dat.reflectAbsorb=beer.drink.absorbColor;
//            dat.refractAbsorb=vec3(0.);
//            dat.subSurface=false;//entering air
//            dat.meanFreePath=maxDist;
//        }
//
//    }
//    //------------------------------------------------
//}

float beerHeightInCup = 1.3;


bool inDrink( Vector tv, Beer beer){

    float drinkSide;

    //tells us if we are inside the cup and below the waterline:
    float cup = pintDistance(tv.pos, beer.glass, drinkSide);

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop = tv.pos.y-beer.glass.center.y-beer.glass.height/beerHeightInCup;

    //distance to drink is intersection of inside dist and this top
    float drink = max(drinkSide, drinkTop);

    return drink<0.;

}


bool inside( Vector tv, Beer beer){
    return inDrink(tv,beer);
}


//overload of sdf for the cocktail struct
float sdf( Vector tv, Beer beer){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup = pintDistance(tv.pos, beer.glass, drinkSide);

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop = tv.pos.y-beer.glass.center.y-beer.glass.height/beerHeightInCup;

    //distance to drink is intersection of inside dist and this top
    float drink = max(drinkSide, drinkTop);

    //make the total distance:
    float dist = min( abs(cup), abs(drink) );

    return min(cup, drink);
}




//overload of set data
void setData(inout Path path, Beer beer){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=pintDistance(path.tv.pos,beer.glass,drinkSide);

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop=path.tv.pos.y-beer.glass.center.y-beer.glass.height/beerHeightInCup;
    float foamThickness = 0.4;



    //compute the new isotropic scattering coefficient depending on point of entry:
    //its going to be the original, plus an exponentially decreasing term with characeterist width
    float scatterDifference = 1.-beer.drink.isotropicScatter;
    float foamScatter = beer.drink.isotropicScatter + scatterDifference * exp(-pow(abs(drinkTop/foamThickness),5.));
    float foamFreePath = beer.drink.meanFreePath*(1.+3.*exp(-pow(abs(drinkTop/foamThickness),10.)));
    // float beerTop = path.tv.pos.y-beer.glass.center.y-beer.glass.height/2.+0.2;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    Vector normal;
    float eps=AT_THRESH;

    if(abs(cup)<AT_THRESH){
        //----if we hit the cup
        //normal is automatically from the cup (or its negation)
        normal=normalVec(path.tv,beer.glass);

        if(cup>0.){
            //if we hit the cup from outside its glass
            //but did we hit it near the drink?
            if(abs(drink)>eps||drinkTop>0.){
                //we hit the cup from the air, far from the drink
                setObjectInAir(path.dat,false,normal,beer.cup);
            }
            else{
                //we hit the cup from inside the drink
                //cup is dominant material
                path.dat.normal=normal;
                setMaterialInterface(path.dat,beer.drink,beer.cup,beer.cup);
            }

        }
        else{
            //we hit the cup from inside the its own glass
            if(abs(drink)>eps){
                //we are exiting the glass into the air
                setObjectInAir(path.dat,true,normal,beer.cup);
            }
            else{
                //we are exiting the glass into the drink
                //drink is dominant material
                path.dat.normal=negate(normal);
                setMaterialInterface(path.dat,beer.cup,beer.drink,beer.drink);

                //set parameters for foam
                path.dat.isotropicScatter = foamScatter;
                path.dat.meanFreePath = foamFreePath;

            }
        }

    }
    //------------------------------------------------
    else if(abs(drink)<AT_THRESH){
        //if we didn't hit the cup, but we hit the liquid's surface
        //normal vector is just pointed straight upward
        normal=Vector(path.tv.pos,vec3(0,1,0));

        //the foam interface is wiggly: let's randomly perturb the normal a bit:
        normal.dir += 0.5*randomUnitVec3();
        normal.dir = normalize(normal.dir);

        //are we coming from above or below the water line?
        //   bool insideMat = drinkTop>0. ? false : true;

        if(drinkTop>0.){
            //coming from above, in the air
            setObjectInAir(path.dat, false, normal, beer.drink);

            //set parameters for foam
            path.dat.isotropicScatter = foamScatter;
            path.dat.meanFreePath = foamFreePath;

        }
        else{
            //coming from below, in the liquid
            setObjectInAir(path.dat, true, normal, beer.drink);
        }

    }

}







