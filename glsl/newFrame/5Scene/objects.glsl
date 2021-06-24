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

//this function constructs the objects
void buildObjects(){

    vec3 color;
    float specularity, roughness;

    //----------- BALL 1 -------------------------
    ball1.center=Point(vec3(-1,0,-2));
    ball1.radius=1.;

    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;
    ball1.mat= makeMetal(color,specularity,roughness);

    //----------- BALL 2 -------------------------
    ball2.center=Point(vec3(0,0,1));
    ball2.radius=0.55;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    ball2.mat=makeDielectric(color,specularity,roughness);


    //----------- BALL 3 -------------------------
    ball3.center=Point(vec3(0.,-0.8,-1));
    ball3.radius=0.6;

    color= 0.1*vec3(0.7,0.1,0.2);
    specularity=0.4;
    roughness=0.1;
    //ball3.mat=makeMetal(color,specularity,roughness);
    ball3.mat=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5);



    //-------- BOTTLE ----------------

    bottle.baseHeight=1.;
    bottle.baseRadius=1.;
    bottle.neckHeight=1.;
    bottle.neckRadius=0.3;
    bottle.thickness=0.1;
    bottle.rounded=0.2;
    bottle.smoothJoin=0.3;
    bottle.center=Point(vec3(3,0,3));
    bottle.bump=1.;
    bottle.mat=makeGlass(0.08*vec3(0.3,0.05,0.2),1.5,0.99);
    //bottle.mat=makeDielectric(0.7*vec3(0.3,0.2,0.6),0.2,0.2);

    //set up the bounding sphere
    bottle.boundingSphere.center=bottle.center;
    bottle.boundingSphere.radius=bottle.baseHeight+bottle.neckHeight+0.5;



    //-------- COCKTAIL GLASS----------------

    cGlass.center=Point(vec3(2,-0.3,-3));
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    //-------- NEGRONI ----------------
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);


}






//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------


float traceObjects( inout Path path, float stopDist ){

    float dist=stopDist;

    dist=sphereTrace(path,ball1,dist);

    dist=sphereTrace(path,ball2,dist);

    //dist=sphereTrace(path,ball3,dist);

    return dist;

}



float sdfObjects( inout Path path ){

   float dist=maxDist;

    dist=min(dist,bottleSDF(path,bottle));

    dist=min(dist,cocktailSDF(path,negroni));

    dist=min(dist,sphereSDF(path,ball3));

    return dist;
}




//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------

void setDataObjects(inout Path path){

    setSphereData(path, ball1);

    setSphereData(path, ball2);

    setSphereData(path, ball3);

    setBottleData(path, bottle);

    setCocktailData(path, negroni);

}
