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
    wall1.mat=makeDielectric(color,0.0,roughness);


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


float trace_Walls(Vector tv ,float stopDist){

    float dist=stopDist;

    dist=min(dist, trace(tv, wall1));

    dist=min(dist, trace(tv, wall2));

    dist=min(dist, trace(tv, wall3));

    dist=min(dist, trace(tv, wall4));

    dist=min(dist, trace(tv, wall5));

    dist=min(dist, trace(tv, wall6));

    return dist;

}





//-------------------------------------------------
//Setting the Walls Data
//-------------------------------------------------



void setData_Walls( inout Path path ){

    setData(path, wall1);

    setData(path, wall2);

    setData(path, wall3);

    setData(path, wall4);

    setData(path, wall5);

    setData(path, wall6);

}
