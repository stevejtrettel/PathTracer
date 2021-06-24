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
    bottle.mat=makeGlass(vec3(0.),1.5,0.99);
    //bottle.mat=makeDielectric(0.7*vec3(0.3,0.2,0.6),0.2,0.2);

    //set up the bounding sphere
    bottle.boundingSphere.center=bottle.center;
    bottle.boundingSphere.radius=bottle.baseHeight+bottle.neckHeight+0.5;

}






//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------


float traceObjects( inout Path path, float stopDist ){

    float dist=stopDist;

    //dist=sphereTrace(path,ball1,dist);

    //dist=sphereTrace(path,ball2,dist);

    dist=sphereTrace(path,ball3,dist);

    return dist;

}



float sdfObjects( inout Path path ){
    return maxDist;
   // return bottleSDF(path,bottle);
}




//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------

void setDataObjects(inout Path path){

    //setSphereData(path, ball1);

    //setSphereData(path, ball2);

    setSphereData(path, ball3);

    //setBottleData(path, bottle);

}
