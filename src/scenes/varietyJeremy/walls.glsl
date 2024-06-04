
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
    color=vec3(0.02);
    specularity=0.;
    roughness=0.1;


    //----------- THE FLOOR -------------------------
    orientation.pos=vec3(0,-0.75,0);
    orientation.dir=vec3(0,1,0);
    bottomWall.orientation=orientation;
    bottomWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE CEILING -------------------------
    orientation.pos=vec3(0,14,0);
    orientation.dir=vec3(0,-1,0);
    topWall.orientation=orientation;
    topWall.mat=makeLight(vec3(1,1,1),5.*extra4);


    //----------- THE FRONT -------------------------
    orientation.pos=vec3(0,0,-12);
    orientation.dir=vec3(0,0,1);
    frontWall.orientation=orientation;
    frontWall.mat=makeDielectric(color,0.0,roughness);

    //----------- THE BACK -------------------------
    orientation.pos=vec3(0,0,30);
    orientation.dir=vec3(0,0,-1);
    backWall.orientation=orientation;
    backWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE LEFT -------------------------
    orientation.pos=vec3(-20,0,0);
    orientation.dir=vec3(1,0,0);
    leftWall.orientation=orientation;
    leftWall.mat=makeDielectric(color,0.0,roughness);
    leftWall.mat.specularChance=0.5;


    //----------- THE RIGHT -------------------------
    orientation.pos=vec3(6.5,0,0);
    orientation.dir=vec3(-1,0,0);
    rightWall.orientation=orientation;
    rightWall.mat=makeDielectric(color,0.0,roughness);


}



//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------

bool render_Walls=true;


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
