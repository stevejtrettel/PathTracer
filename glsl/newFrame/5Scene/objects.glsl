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
    bottle.thickness=0.05;
    bottle.rounded=0.1;
    bottle.smoothJoin=0.3;
    bottle.center=vec3(2,0.75,-2);
    bottle.bump=0.5;
    bottle.mat=makeGlass(vec3(0.3,0.05,0.08),1.5,0.99);


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

    cGlass.center=vec3(-2,0.1,-1);
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    //-------- NEGRONI ----------------
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);



}






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

    //dist=min( dist, sdf(tv, gin) );

    //ist=min( dist, sdf(tv, negroni) );

    return dist;
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

    //setData(path, gin);

    //setData(path, negroni);

}



