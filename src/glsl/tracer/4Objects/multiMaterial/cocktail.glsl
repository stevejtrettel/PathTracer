


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

