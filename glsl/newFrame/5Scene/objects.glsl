//-------------------------------------------------
// OBJECTS OF THE SCENE
// describes the SDF / tracing function for the objects of the scene
//-------------------------------------------------




//-------------------------------------------------
//Defining the Objects
//-------------------------------------------------


//set the names of global variables for the walls here:
Sphere ball1, ball2, ball3;
Bottle bottle, bottle2;
CocktailGlass cGlass;
Cocktail negroni;
LiquorBottle gin,campari;
Pint pint;
Beer beer;
Cone cone,cone2,cone3;


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
    bottle.center=vec3(-1,0.4,1);
    bottle.bump=0.5;
    bottle.mat=makeGlass(0.1*vec3(0.3,0.05,0.08),1.5,0.99);

    bottle.mat.diffuseColor=vec3(0.8);
    bottle.mat.absorbColor=vec3(0.2,0.2,0.05);
    bottle.mat.refractionChance=0.;
    bottle.mat.subSurface=true;
    bottle.mat.meanFreePath=0.05;
    bottle.mat.roughness=0.5;

    //set up the bounding sphere
    bottle.boundingBox.center=bottle.center;
    bottle.boundingBox.radius=bottle.baseHeight+bottle.neckHeight+0.5;



    //-------- BOTTLE ----------------

    bottle2.baseHeight=1.5;
    bottle2.baseRadius=0.5;
    bottle2.neckHeight=1.;
    bottle2.neckRadius=0.2;
    bottle2.thickness=0.02;
    bottle2.rounded=0.1;
    bottle2.smoothJoin=0.3;
    bottle2.center=vec3(0,0.6,0);
    bottle2.bump=0.;
    bottle2.mat=makeGlass(0.1*vec3(0.3,0.05,0.08),1.5,0.99);

    bottle2.mat.diffuseColor=0.8*vec3(0.5,0.5,0.9);
    //0.7*vec3(0.3,0.2,0.6);
    bottle2.mat.absorbColor=8.*vec3(0.5,0.5,0.0);
    bottle2.mat.refractionChance=0.;
    bottle2.mat.subSurface=true;
    bottle2.mat.meanFreePath=0.1;
    bottle2.mat.roughness=1.;





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

    cGlass.center=vec3(1.5,0.1,-2);
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    //-------- NEGRONI ----------------
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

//    negroni.drink=makeGlass(vec3(0.),1.2,0.99);
//    negroni.drink.refractionChance=0.0;
//    negroni.drink.subSurface=true;
//    negroni.drink.meanFreePath=0.1;
//    negroni.drink.roughness=0.4;

    //----------PINT GLASS----------
    pint.center=vec3(-1,1.2,-2);
    pint.height=2.;
    pint.base=0.5;
    pint.flare=1.5;
    pint.thickness=0.03;
    pint.rounded=0.;
    pint.mat=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);

    //-------- BEER ----------------
    beer.glass=pint;
    beer.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);


    //    negroni.drink.diffuseColor=vec3(1.);
    //    negroni.drink.absorbColor=vec3(0.);
    //    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    //    negroni.drink.refractionChance=0.;
    //    negroni.drink.subSurface=true;
    //    negroni.drink.meanFreePath=0.05;
    //    negroni.drink.roughness=1.;

    beer.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    //0.5*vec3(0.02,0.02,0.06)
    //beer.drink.refractionChance=0.0;
    //beer.drink.subSurface=true;
    //beer.drink.meanFreePath=0.4;
    //beer.drink.roughness=0.5;


//    beer.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
//
//    beer.drink.diffuseColor=vec3(1);
//    beer.drink.absorbColor=vec3(0);
//    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
//    beer.drink.refractionChance=0.;
//    beer.drink.subSurface=true;
//    beer.drink.meanFreePath=0.1;
//    beer.drink.roughness=0.9;


    //-------- TRUNCATED CONE ----------------
    cone.center=vec3(1,0.8,-3);
    cone.height=1.5;
    cone.base=0.5;
    cone.flare=1.5;

    cone.mat=makeGlass(vec3(0),1.2,0.99);
    cone.mat.refractionChance=0.0;
    cone.mat.subSurface=true;
    cone.mat.meanFreePath=0.05;
    cone.mat.roughness=0.25;



    //-------- TRUNCATED CONE ----------------
    cone2.center=vec3(1,0.8,-1);
    cone2.height=1.5;
    cone2.base=0.5;
    cone2.flare=1.5;

    cone2.mat=makeGlass(vec3(0),1.2,0.99);
    cone2.mat.refractionChance=0.0;
    cone2.mat.subSurface=true;
    cone2.mat.meanFreePath=0.05;
    cone2.mat.roughness=0.85;


    //BEER COLOR vec3(0.02,0.02,0.06)

    //-------- TRUNCATED CONE ----------------
    cone3.center=vec3(1,0.8,1);
    cone3.height=1.5;
    cone3.base=0.5;
    cone3.flare=1.5;

    cone3.mat=makeGlass(vec3(0),1.2,0.99);
    cone3.mat.refractionChance=0.0;
    cone3.mat.subSurface=true;
    cone3.mat.meanFreePath=0.05;
    cone3.mat.roughness=1.;


//    cone.mat=makeGlass(vec3(0.),1.2,0.99);
//    cone.mat.diffuseColor=(vec3(1.)-10.*vec3(0.02,0.02,0.06));
//    cone.mat.refractionChance=0.0;
//    cone.mat.subSurface=true;
//    cone.mat.meanFreePath=0.1;
//    cone.mat.roughness=1.;


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

    dist=min( dist, sdf(tv, bottle) );

    //dist=min( dist, sdf(tv, bottle2) );

    //dist=min( dist, sdf(tv, beer) );

    //dist=min( dist, sdf(tv, cone) );

    //dist=min( dist, sdf(tv, cone2) );

    //dist=min( dist, sdf(tv, cone3) );

    dist=min( dist, sdf(tv, negroni) );

    return dist;
}








int objID=0;
void setObjID( Vector tv ){
//    objID=0;
//    if(inside(tv, bottle)){
//        objID=1;
//    }
//    if(inside(tv, bottle2)){
//        objID=2;
//    }
}


//will go in the objects file; tells us if we are inside an object of interest
bool inside_Object( Vector tv ){

    bool jar=inside(tv, bottle);
//
return jar;
    //bool milk=inDrink(tv, beer);
   // bool juice=inDrink(tv, negroni);
    //return juice;
//bool inBeer= inDrink(tv, beer);
//    return jar||milk||juice;
//bool inCone= inside(tv, cone);
   // bool inCone2= inside(tv, cone2);
    //bool inCone3= inside(tv, cone3);
    //return inCone||inCone2||inCone3;
//return inside(tv, bottle)||inside(tv, bottle2);
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

      setData(path, bottle);
   // setData(path, bottle2);

      //setData(path, beer);
     //   setData(path, cone);
  //  setData(path, cone2);
  //  setData(path, cone3);
     setData(path, negroni);

}



