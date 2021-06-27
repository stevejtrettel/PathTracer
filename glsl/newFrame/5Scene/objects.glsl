//-------------------------------------------------
// OBJECTS OF THE SCENE
// describes the SDF / tracing function for the objects of the scene
//-------------------------------------------------




//-------------------------------------------------
//Defining the Objects
//-------------------------------------------------


//set the names of global variables for the walls here:
Sphere ball1, ball2, ball3;
Bottle bottle;
CocktailGlass cGlass;
Cocktail negroni;
LiquorBottle gin,campari;
Pint pint;
Beer beer;

//this function constructs the objects
void buildObjects(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);

    //----------- BALL 1 -------------------------
    ball1.center=vec3(1,0.3,-2);
    ball1.radius=1.3;

    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;
    ball1.mat= makeMetal(color,specularity,roughness);

    //----------- BALL 2 -------------------------
    ball2.center=vec3(0,-0.5,2);
    ball2.radius=0.55;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    ball2.mat=makeDielectric(color,specularity,roughness);


    //----------- BALL 3 -------------------------
    ball3.center=vec3(1.5,0.6,2);
    ball3.radius=1.6;

    color= 0.1*vec3(0.7,0.1,0.2);
    specularity=0.4;
    roughness=0.1;
    //ball3.mat=makeMetal(color,specularity,roughness);
    ball3.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.5);



    //-------- BOTTLE ----------------

    bottle.baseHeight=1.25;
    bottle.baseRadius=1.;
    bottle.neckHeight=1.;
    bottle.neckRadius=0.3;
    bottle.thickness=0.02;
    bottle.rounded=0.1;
    bottle.smoothJoin=0.3;
    bottle.center=vec3(1,0.4,-2);
    bottle.bump=0.5;
    bottle.mat=makeGlass(0.1*vec3(0.3,0.05,0.08),1.5,0.99);

    bottle.mat.diffuseColor=0.7*vec3(0.3,0.2,0.6);
    bottle.mat.absorbColor=vec3(0.2,0.2,0.05);
    bottle.mat.refractionChance=0.;
    bottle.mat.subSurface=true;
    bottle.mat.meanFreePath=0.05;
    bottle.mat.roughness=0.5;

    //set up the bounding sphere
    bottle.boundingBox.center=bottle.center;
    bottle.boundingBox.radius=bottle.baseHeight+bottle.neckHeight+0.5;



    //-------- GIN BOTTLE ----------------
    gin.glass=bottle;
    gin.glass.baseRadius=1.25;
    gin.glass.baseHeight=1.5;
    gin.glass.thickness=0.1;
    gin.cup=makeGlass(0.5*vec3(0.3,0.05,0.08),1.5,0.95);
    gin.drink=makeGlass(vec3(0.1,0.05,0.),1.3,0.99);
    //makeGlass(0.3*vec3(0.1,0.05,0.),1.3,0.99);
    gin.fill=0.;
    gin.glass.bump=1.;



//    //-------- CAMPARI BOTTLE ----------------
//
//    campari.glass=bottle;
//    campari.glass.center.coords=vec3(3,2.25,-9);
//    campari.glass.baseRadius=1.;
//    campari.glass.baseHeight=3.5;
//    campari.glass.neckHeight=0.75;
//    campari.glass.smoothJoin=0.5;
//    campari.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
//    campari.drink=makeGlass(2.5*redAbsorb,1.3,0.99);
//    campari.fill=0.5;
//    campari.glass.bump=0.;
//
//
//
//
    //-------- COCKTAIL GLASS----------------

    cGlass.center=vec3(0,0.1,2);
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    //-------- NEGRONI ----------------
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

    negroni.drink.diffuseColor=vec3(1.);
    negroni.drink.absorbColor=vec3(0.);
    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    negroni.drink.refractionChance=0.;
    negroni.drink.subSurface=true;
    negroni.drink.meanFreePath=0.05;
    negroni.drink.roughness=1.;

    //----------PINT GLASS----------
    pint.center=vec3(-2,0.6,-2);
    pint.height=1.5;
    pint.base=0.75;
    pint.flare=1.2;
    pint.thickness=0.1;
    pint.rounded=0.1;
    pint.mat=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);

    //-------- BEER ----------------
    beer.glass=pint;
    beer.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    beer.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

    beer.drink.diffuseColor=vec3(1);
    beer.drink.absorbColor=vec3(0);
    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    beer.drink.refractionChance=0.;
    beer.drink.subSurface=true;
    beer.drink.meanFreePath=0.1;
    beer.drink.roughness=1.;

}





//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------

bool render_Objects=true;



//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

float trace_Objects( Vector tv ){

    float dist=maxDist;

//    dist=min(dist, trace(tv, ball1));
//
//    dist=min(dist, trace(tv, ball2));
//
//    dist=min(dist, trace(tv,ball3));

    return dist;

}





float sdf_Objects( Vector tv ){

   float dist=maxDist;

    //dist=min( dist, sdf(tv, bottle) );

    dist=min( dist, sdf(tv, beer) );

    //dist=min( dist, sdf(tv, negroni) );

    return dist;
}








int objID=0;
void setObjID( Vector tv ){
//    objID=0;
//    if(inside(tv, bottle)){
//        objID=1;
//    }
//    if(inDrink(tv, beer)){
//        objID=2;
//    }
//    if(inDrink(tv, negroni)){
//        objID=3;
//    }
}


//will go in the objects file; tells us if we are inside an object of interest
bool inside_Object( Vector tv ){

//    bool jar=inside(tv, bottle);
//    bool milk=inDrink(tv, beer);
//    bool juice=inDrink(tv, negroni);
//
//    return jar||milk||juice;
//
return inDrink(tv, beer);

//    switch(objID){
//        default: false;
//        case 1: return inside(tv, bottle);
//        case 2: return inDrink(tv, beer);
//        case 3: return inDrink(tv, negroni);
//    }
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){

//    setData(path, ball1);
//
//    setData(path,ball2);
//
//    setData(path, ball3);

      //setData(path, bottle);

      setData(path, beer);

      //setData(path, negroni);

}



