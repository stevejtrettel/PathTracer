//-------------------------------------------------
// WALLS OF THE SCENE
// describes the SDF / tracing function for the walls bounding the scene
//-------------------------------------------------




//-------------------------------------------------
//Defining the Walls
//-------------------------------------------------


//set the names of global variables for the walls here:
Plane wall1, wall2, wall3, wall4, wall5, wall6;

//this function constructs the objects
void buildWalls(){

    vec3 color,normal;
    float specularity, roughness, offset;

    //-----------GENERAL FOR THE WALLS -------------------------
    color=vec3(0.4);
    specularity=0.;
    roughness=0.;


    //----------- WALL 1 -------------------------
    normal=vec3(0,1,0);
    offset=1.5;

    setPlane(wall1,normal,offset);
    wall1.mat=makeDielectric(color,0.05,roughness);


    //----------- WALL 2 -------------------------
    normal=vec3(0,0,1);
    offset=10.;

    setPlane(wall2,normal,offset);
    wall2.mat=makeDielectric(color,specularity,roughness);
    wall2.mat.specularColor=vec3(0.75);
    wall2.mat.specularChance=1.;
    wall2.mat.refractionChance=0.;


    //----------- WALL 3 -------------------------
    normal=vec3(1,0,0);
    offset=10.;

    setPlane(wall3,normal,offset);
    wall3.mat=makeDielectric(color,specularity,roughness);



    //----------- WALL 4 -------------------------
    normal=vec3(0,-1,0);
    offset=10.;

    setPlane(wall4,normal,offset);
    //wall4.mat=makeDielectric(color,specularity,roughness);
    wall4.mat=makeLight(vec3(1,0.6,0.4),0.25);

    //----------- WALL 5 -------------------------
    normal=vec3(0,0,-1);
    offset=5.;

    setPlane(wall5,normal,offset);
    wall5.mat=makeDielectric(color,specularity,roughness);



    //----------- WALL 6 -------------------------
    normal=vec3(-1,0,0);
    offset=10.;

    setPlane(wall6,normal,offset);
    wall6.mat=makeDielectric(color,specularity,roughness);


}






//-------------------------------------------------
//Finding the Walls
//-------------------------------------------------


float traceWalls(inout Path path,float stopDist){

    float dist=stopDist;

    dist=planeTrace(path,wall1,dist);

    dist=planeTrace(path,wall2,dist);

    dist=planeTrace(path,wall3,dist);

    dist=planeTrace(path,wall4,dist);

    dist=planeTrace(path,wall5,dist);

    dist=planeTrace(path,wall6,dist);

    return dist;

}




//-------------------------------------------------
//Setting the Walls Data
//-------------------------------------------------



void setDataWalls(inout Path path){

    setPlaneData(path,wall1);

    setPlaneData(path,wall2);

    setPlaneData(path,wall3);

    setPlaneData(path,wall4);

    setPlaneData(path,wall5);

    setPlaneData(path,wall6);

}
