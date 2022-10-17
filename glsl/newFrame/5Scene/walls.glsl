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
    color=vec3(0.7);
    //0.4*vec3(171,203,240)/255.;
    //vec3(0.4);
    specularity=0.;
    roughness=0.1;


    //----------- THE FLOOR -------------------------
    orientation.pos=vec3(0,-3.1,0);
    //vec3(0,-1,0);
    orientation.dir=vec3(0,1,0);

    color=vec3(0.1);
    bottomWall.orientation=orientation;
    bottomWall.mat=makeDielectric(color,0.0,roughness);

    bottomWall.mat=makeDielectric(color,0.0,roughness);
    bottomWall.mat.specularColor=vec3(0.75);
    bottomWall.mat.specularChance=0.05;
    bottomWall.mat.refractionChance=0.;

    //----------- THE CEILING -------------------------
    orientation.pos=vec3(0,14,0);
    orientation.dir=vec3(0,-1,0);


    topWall.orientation=orientation;
    //topWall.mat=makeDielectric(color,0.0,roughness);
   /// vec3(1,0.6,0.4)
    topWall.mat=makeLight(vec3(1,1,1),0.1);


    //----------- THE FRONT -------------------------
    orientation.pos=vec3(0,0,-5);
    orientation.dir=vec3(0,0,1);

    color=vec3(0.1);
    frontWall.orientation=orientation;
    //need a "make mirror" command
    frontWall.mat=makeDielectric(color,0.0,roughness);
    frontWall.mat.specularColor=vec3(0.75);
    frontWall.mat.specularChance=0.075;
    frontWall.mat.refractionChance=0.;


    //----------- THE BACK -------------------------
    orientation.pos=vec3(0,0,30);
    orientation.dir=vec3(0,0,-1);

    color=0.5*vec3(107,152,250)/255.;
    backWall.orientation=orientation;
    backWall.mat=makeDielectric(color,0.0,roughness);
    backWall.mat.specularColor=vec3(0.75);
    backWall.mat.specularChance=0.075;


    //----------- THE LEFT -------------------------
    orientation.pos=vec3(-20,0,0);
    orientation.dir=vec3(1,0,0);

    color=0.5*vec3(250,229,147)/255.;
    leftWall.orientation=orientation;
    leftWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE RIGHT -------------------------
    orientation.pos=vec3(5,0,0);
    orientation.dir=vec3(-1,0,0);

    //color=0.4*vec3(240,126,106)/255.;
    color=vec3(0.1);
    rightWall.orientation=orientation;
    rightWall.mat=makeDielectric(color,0.0,roughness);

   rightWall.mat=makeDielectric(color,0.0,roughness);
   rightWall.mat.specularColor=vec3(0.75);
    rightWall.mat.specularChance=0.075;
    rightWall.mat.refractionChance=0.;

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
