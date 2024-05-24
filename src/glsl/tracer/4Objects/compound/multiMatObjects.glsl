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


bool inDrink( Vector tv, Cocktail cocktail){

    float drinkSide;

    //tells us if we are inside the cup and below the waterline:
    float cup = cocktailGlassDistance(tv.pos, cocktail.glass, drinkSide);

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop = tv.pos.y-cocktail.glass.center.y-cocktail.glass.height/3.;

    //distance to drink is intersection of inside dist and this top
    float drink = max(drinkSide, drinkTop);

    return drink<0.;

}



//overload of sdf for the cocktail struct
float sdf( Vector tv, Cocktail cocktail){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup = cocktailGlassDistance(tv.pos, cocktail.glass, drinkSide);

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop = tv.pos.y-cocktail.glass.center.y-cocktail.glass.height/3.;

    //distance to drink is intersection of inside dist and this top
    float drink = max(drinkSide, drinkTop);

    //make the total distance:
    float dist = min( abs(cup), abs(drink) );

    return min(cup, drink);
}



//overload of set data
void setData(inout Path path, Cocktail cocktail){

    float drinkSide;

    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=cocktailGlassDistance(path.tv.pos,cocktail.glass,drinkSide);

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop=path.tv.pos.y-cocktail.glass.center.y-cocktail.glass.height/3.;

    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);

    //make the total distance:
    float dist=min(abs(cup),abs(drink));

    Vector normal;
    float eps=AT_THRESH;



    if(abs(cup)<AT_THRESH){
        //----if we hit the cup
        //normal is automatically from the cup (or its negation)
        normal=normalVec(path.tv,cocktail.glass);

        if(cup>0.){
            //if we hit the cup from outside its glass
            //but did we hit it near the drink?
            if(abs(drink)>eps||drinkTop>0.){
                //we hit the cup from the air, far from the drink
                setObjectInAir(path.dat,false,normal,cocktail.cup);
            }
            else{
                //we hit the cup from inside the drink
                //cup is dominant material
                path.dat.normal=normal;
                setMaterialInterface(path.dat,cocktail.drink,cocktail.cup,cocktail.drink);
            }

        }
        else{
            //we hit the cup from inside the its own glass
            if(abs(drink)>eps){
                //we are exiting the glass into the air
                setObjectInAir(path.dat,true,normal,cocktail.cup);

            }
            else{
                //we are exiting the glass into the drink
                //drink is dominant material
                path.dat.normal=negate(normal);
                setMaterialInterface(path.dat,cocktail.cup,cocktail.drink,cocktail.drink);
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
        setObjectInAir(path.dat,insideMat,normal,cocktail.drink);
    }

}












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
    float foamThickness = 1.3;



    //compute the new isotropic scattering coefficient depending on point of entry:
    //its going to be the original, plus an exponentially decreasing term with characeterist width
    float scatterDifference = 1.-beer.drink.isotropicScatter;
    float foamScatter = beer.drink.isotropicScatter + scatterDifference * exp(-pow(abs(drinkTop/foamThickness),3.));
    float foamFreePath = beer.drink.meanFreePath*(1.+3.*exp(-pow(abs(drinkTop/foamThickness),3.)));
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












//-------------------------------------------------
// The LAYEERDONUT sdf
//-------------------------------------------------

struct LayerDonutBottle{
    DonutBottle inner;
    DonutBottle outer;
    //Sphere outer;
};



//overload of sdf for the cocktail struct
float sdf( Vector tv, LayerDonutBottle donut){

    float innerDist = sdf(tv, donut.inner);
    float outerDist = sdf(tv, donut.outer);

    //make the total distance:
    float dist = min( abs(innerDist), abs(outerDist));

    return dist;
}



//overload of set data
void setData(inout Path path, LayerDonutBottle donut){

    Vector normal;

    float innerDist = sdf(path.tv, donut.inner);
    float outerDist = sdf(path.tv, donut.outer);

    if(abs(outerDist)<abs(innerDist)) {
        //----if we hit the outer shell

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, donut.outer);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (inside) {
            setObjectInAir(path.dat, true, normal, donut.outer.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, donut.outer.mat);
        }

    }

    else {
        //----if we hit the inner shell

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, donut.inner);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the colored material and going into the clear
        if (inside) {
            setMaterialInterface(path.dat, donut.inner.mat, donut.outer.mat, donut.inner.mat);
        }

        else {
            //if we are ingoing: we are leaving the clear material and going into the colored
            setMaterialInterface(path.dat, donut.outer.mat, donut.inner.mat, donut.inner.mat);
        }

    }

}









//-------------------------------------------------
// The GLASS VARIETY sdf
//-------------------------------------------------

struct GlassVariety{
    Variety surf;
    Variety glass;
};

GlassVariety createGlassVariety(Variety surf, Material glassMat, float thickness){

    GlassVariety obj;
    obj.surf = surf;
    obj.glass.center=surf.center;
    obj.glass.size=surf.size;
    obj.glass.boundingSphere = surf.boundingSphere+2.*thickness;
    obj.glass.inside=surf.inside+thickness;
    obj.glass.outside = surf.outside+thickness;
    obj.glass.smoothing = surf.smoothing;
    obj.glass.mat = glassMat;

    return obj;
}



//overload of sdf for the cocktail struct
float sdf( Vector tv, GlassVariety var){

    float innerDist = sdf(tv, var.surf);
    float outerDist = sdf(tv, var.glass);

    //make the total distance:
    float dist = min( abs(innerDist), abs(outerDist));

    return dist;
}



//overload of set data
void setData(inout Path path, GlassVariety var){

    Vector normal;

    float innerDist = sdf(path.tv, var.surf);
    float outerDist = sdf(path.tv, var.glass);

    if(abs(outerDist)<abs(innerDist)) {
        //----if we hit the outer shell

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, var.glass);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (inside) {
            setObjectInAir(path.dat, true, normal, var.glass.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, var.glass.mat);
        }

    }

    else {
        //----if we hit the inner shell

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, var.surf);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the colored material and going into the clear
        if (inside) {
            path.dat.normal=negate(normal);
            setMaterialInterface(path.dat, var.surf.mat, var.glass.mat, var.surf.mat);
        }

        else {
            path.dat.normal=normal;
            //if we are ingoing: we are leaving the clear material and going into the colored
            setMaterialInterface(path.dat, var.glass.mat, var.surf.mat, var.surf.mat);
        }

    }

}




//-------------------------------------------------
// The GLASS MARBLE sdf
//-------------------------------------------------


struct GlassMarble{
    Variety innerVar;
    Variety outerVar;
    Sphere glass;
};

GlassMarble createGlassMarble(Variety surf, Material outerMat, Material glassMat ){

    float thickness = 0.04;

    GlassMarble obj;
    obj.innerVar = surf;

    obj.outerVar.center = surf.center;
    obj.outerVar.size = surf.size;
    obj.outerVar.boundingSphere = 0.75*surf.boundingSphere;
    obj.outerVar.inside = surf.inside;
    obj.outerVar.outside = surf.outside+thickness;
    obj.outerVar.smoothing = surf.smoothing;
    obj.outerVar.mat = outerMat;

    obj.glass = Sphere(surf.center, 1.2*surf.boundingSphere,glassMat);
    return obj;

}


//overload of sdf for the cocktail struct
float sdf( Vector tv, GlassMarble marble){

    float innerDist = sdf(tv, marble.innerVar);
    float outerDist = sdf(tv, marble.outerVar);
    float glassDist = sdf(tv, marble.glass);

    //make the total distance:
    float dist = min(abs(glassDist), min( abs(innerDist), abs(outerDist)));

    return dist;
}



//overload of set data
void setData(inout Path path, GlassMarble marble){

    Vector normal;

    float innerDist = sdf(path.tv, marble.innerVar);
    float outerDist = sdf(path.tv, marble.outerVar);
    float glassDist = sdf(path.tv, marble.glass);

    if((abs(glassDist) < abs(outerDist)) && (abs(glassDist) < abs(innerDist)) ){
        //----if we hit the glass outside of the marble:
        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.glass);

        //figure out if we are incoming or outgoing:
        bool insideGlass = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (insideGlass) {
            setObjectInAir(path.dat, true, normal, marble.glass.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, marble.glass.mat);
        }

    }



    else if( abs(outerDist)<abs(innerDist) ) {
        //----if we hit the outer variety, inside the glass
        //the only way to hit the surface of the outer variety is if we are at an outer/glass interface:

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.outerVar);

        //figure out if we are incoming or outgoing:
        bool insideOuterMat = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the variety material and going into the glass
        if (insideOuterMat) {
            path.dat.normal=negate(normal);
            setMaterialInterface(path.dat, marble.outerVar.mat, marble.glass.mat, marble.outerVar.mat);
        }

        else {
            //if we are ingoing: we are leaving the clear glass and going into the variety
            path.dat.normal=normal;
            setMaterialInterface(path.dat, marble.glass.mat, marble.outerVar.mat, marble.outerVar.mat);
        }

    }

    else {
        //----if we hit the inner shell
        // there's two ways to do this: we can be going directly inner/glass
        //or we can be going outer/inner.

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.innerVar);

        //figure out if we are incoming or outgoing:
        bool insideInnerMat = dot(path.tv.dir,normal.dir)>0.;
        //figure out which material interface we are at:
        bool outerMatInterface = inside(path.tv,marble.outerVar);


        if (insideInnerMat) {
            //inside the mat means negate its normal:
            path.dat.normal=negate(normal);

            if(outerMatInterface){
                //if we are outgoing, from inner material to outer
                setMaterialInterface(path.dat, marble.innerVar.mat, marble.outerVar.mat, marble.outerVar.mat);
            }

            else{
                //if we are outgoing, from inner material to glass
                setMaterialInterface(path.dat, marble.innerVar.mat, marble.glass.mat, marble.innerVar.mat);
            }
        }


        else{
            //if we are incoming, do not negate the normal:
            path.dat.normal=normal;

            if(outerMatInterface){
                //from outer to inner
                setMaterialInterface(path.dat, marble.outerVar.mat, marble.innerVar.mat, marble.innerVar.mat);
            }

            else{
                //from glass material to inner
                setMaterialInterface(path.dat, marble.glass.mat, marble.innerVar.mat, marble.innerVar.mat);
            }
        }

    }

}











//-------------------------------------------------
// The POINCARE BALL MARBLE sdf
//-------------------------------------------------


struct PoincareMarble{
    HypDod dod;
    Sphere glass;
};

PoincareMarble createPoincareMarble(Material dodMat, Material glassMat ){

    float thickness = 0.04;

    PoincareMarble obj;
    //obj.dod = buildHypDod();
    obj.dod = buildHypDod(0.4);
    obj.dod.mat = dodMat;

    obj.glass = Sphere(vec3(0,0,0), 1.,glassMat);
    return obj;

}


//overload of sdf for the cocktail struct
float sdf( Vector tv, PoincareMarble marble){

    float innerDist = sdf(tv, marble.dod);
    float glassDist = sdf(tv, marble.glass);

    //make the total distance:
    float dist = min( abs(glassDist), abs(innerDist) );

    return dist;
}



//overload of set data
void setData(inout Path path, PoincareMarble marble){

    Vector normal;

    float innerDist = sdf(path.tv, marble.dod);
    float glassDist = sdf(path.tv, marble.glass);

    if( (abs(glassDist) < abs(innerDist)) ){
        //----if we hit the glass outside of the marble:
        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.glass);

        //figure out if we are incoming or outgoing:
        bool insideGlass = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (insideGlass) {
            setObjectInAir(path.dat, true, normal, marble.glass.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, marble.glass.mat);
        }

    }



    else {
        //----if we hit the outer variety, inside the glass
        //the only way to hit the surface of the outer variety is if we are at an outer/glass interface:

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.dod);

        //figure out if we are incoming or outgoing:
        bool insideOuterMat = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the variety material and going into the glass
        if (insideOuterMat) {
            path.dat.normal=negate(normal);
            setMaterialInterface(path.dat, marble.dod.mat, marble.glass.mat, marble.dod.mat);
        }

        else {
            //if we are ingoing: we are leaving the clear glass and going into the variety
            path.dat.normal=normal;
            setMaterialInterface(path.dat, marble.glass.mat, marble.dod.mat, marble.dod.mat);
        }

    }

}

