
//-------------------------------------------------
// The BEER sdf
//-------------------------------------------------

struct Beer{
    Pint glass;
    Material cup;
    Material drink;
    float fill;
};


float beerHeightInCup = 1.3;


bool inDrink( Vector tv, Beer beer){

    float drinkSide;

    //tells us if we are inside the cup and below the waterline:
    //pintDistance works in the glass's local frame; rescale distances to world
    float cup = beer.glass.frame.scale * pintDistance(toLocal(beer.glass.frame, tv.pos), beer.glass, drinkSide);
    drinkSide *= beer.glass.frame.scale;

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop = tv.pos.y-beer.glass.frame.pos.y-beer.glass.height/beerHeightInCup;

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
    //pintDistance works in the glass's local frame; rescale distances to world
    float cup = beer.glass.frame.scale * pintDistance(toLocal(beer.glass.frame, tv.pos), beer.glass, drinkSide);
    drinkSide *= beer.glass.frame.scale;

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop = tv.pos.y-beer.glass.frame.pos.y-beer.glass.height/beerHeightInCup;

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
    //pintDistance works in the glass's local frame; rescale distances to world
    float cup=beer.glass.frame.scale * pintDistance(toLocal(beer.glass.frame, path.tv.pos),beer.glass,drinkSide);
    drinkSide *= beer.glass.frame.scale;

    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop=path.tv.pos.y-beer.glass.frame.pos.y-beer.glass.height/beerHeightInCup;
    float foamThickness = 0.4;



    //compute the new isotropic scattering coefficient depending on point of entry:
    //its going to be the original, plus an exponentially decreasing term with characeterist width
    float scatterDifference = 1.-beer.drink.isotropicScatter;
    float foamScatter = beer.drink.isotropicScatter + scatterDifference * exp(-pow(abs(drinkTop/foamThickness),5.));
    float foamFreePath = beer.drink.meanFreePath*(1.+3.*exp(-pow(abs(drinkTop/foamThickness),10.)));
    // float beerTop = path.tv.pos.y-beer.glass.frame.pos.y-beer.glass.height/2.+0.2;

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







