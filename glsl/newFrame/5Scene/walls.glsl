//-------------------------------------------------
// WALLS OF THE SCENE
// describes the SDF / tracing function for the walls bounding the scene
//-------------------------------------------------




//-------------------------------------------------
//Defining the Walls
//-------------------------------------------------


//set the names of global variables for the walls here:
Plane bottomWall,topWall,leftWall,rightWall,backWall,frontWall;

//this function constructs the objects
void buildWalls(){

    Vector orientation;
    vec3 color;
    float specularity, roughness, offset;

    //-----------GENERAL FOR THE WALLS -------------------------
    color=vec3(0.4);
    specularity=0.;
    roughness=0.;


    //----------- THE FLOOR -------------------------
    orientation.pos=vec3(0,-1,0);
    orientation.dir=vec3(0,1,0);

    bottomWall.orientation=orientation;
    bottomWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE CEILING -------------------------
    orientation.pos=vec3(0,9,0);
    orientation.dir=vec3(0,-1,0);

    topWall.orientation=orientation;
    topWall.mat=makeDielectric(color,0.0,roughness);
    //topWall.mat=makeLight(vec3(1,0.6,0.4),0.25);


    //----------- THE FRONT -------------------------
    orientation.pos=vec3(0,0,-5);
    orientation.dir=vec3(0,0,1);

    frontWall.orientation=orientation;
    //need a "make mirror" command
    frontWall.mat=makeDielectric(color,0.0,roughness);
    frontWall.mat.specularColor=vec3(0.75);
    frontWall.mat.specularChance=1.;
    frontWall.mat.refractionChance=0.;


    //----------- THE BACK -------------------------
    orientation.pos=vec3(0,0,5);
    orientation.dir=vec3(0,0,-1);

    backWall.orientation=orientation;
    backWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE LEFT -------------------------
    orientation.pos=vec3(-8,0,0);
    orientation.dir=vec3(1,0,0);

    leftWall.orientation=orientation;
    leftWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE RIGHT -------------------------
    orientation.pos=vec3(5,0,0);
    orientation.dir=vec3(-1,0,0);

    rightWall.orientation=orientation;
    rightWall.mat=makeDielectric(color,0.0,roughness);


}






//-------------------------------------------------
//Finding the Walls
//-------------------------------------------------


float trace_Walls(Vector tv ){

    float dist=maxDist;

    dist=min(dist, trace(tv, bottomWall));

    dist=min(dist, trace(tv, topWall));

    dist=min(dist, trace(tv, frontWall));

    dist=min(dist, trace(tv, backWall));

    dist=min(dist, trace(tv, leftWall));

    dist=min(dist, trace(tv, rightWall));

    return dist;

}





//-------------------------------------------------
//Setting the Walls Data
//-------------------------------------------------



void setData_Walls( inout Path path ){

    setData(path, bottomWall);

    setData(path, topWall);

    setData(path, frontWall);

    setData(path, backWall);

    setData(path, leftWall);

    setData(path, rightWall);

}
