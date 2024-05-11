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
    color=vec3(0.05);
    //0.4*vec3(171,203,240)/255.;
    //vec3(0.4);
    specularity=0.;
    roughness=0.1;


    //----------- THE FLOOR -------------------------
    orientation.pos=vec3(0,-0.75,0);
    //vec3(0,-1,0);
    orientation.dir=vec3(0,1,0);

    //color= 0.1*vec3(107,152,250)/255.;
    //vec3(0.03);
    //0.2*vec3(0.8,0.8,0.4);
    //vec3(0.1);
    bottomWall.orientation=orientation;
    bottomWall.mat=makeDielectric(color,0.0,roughness);

    bottomWall.mat=makeDielectric(color,0.0,roughness);
    bottomWall.mat.specularColor=vec3(0.75);
    bottomWall.mat.specularChance=0.0;
    //0.05;
    bottomWall.mat.refractionChance=0.;

    //----------- THE CEILING -------------------------
    orientation.pos=vec3(0,14,0);
    orientation.dir=vec3(0,-1,0);


    topWall.orientation=orientation;
    //topWall.mat=makeDielectric(color,0.0,roughness);
   /// vec3(1,0.6,0.4)

    topWall.mat=makeLight(vec3(1,1,1),5.*extra4);
    //color =vec3(1);
    topWall.mat=makeDielectric(color,0.0,0.5);
    topWall.mat.specularColor=vec3(0.75);
//    topWall.mat.specularChance=0.;
//    0.075;
//   topWall.mat.refractionChance=0.;


    //----------- THE FRONT -------------------------
    orientation.pos=vec3(0,0,-12);
    orientation.dir=vec3(0,0,1);

   // color= 0.1*vec3(107,152,250)/255.;
    //0.3*vec3(170,150,80)/255.;
    //0.1*vec3(107,152,250)/255.;
    //=vec3(0.1);
    frontWall.orientation=orientation;
    //need a "make mirror" command
    frontWall.mat=makeDielectric(color,0.0,roughness);
    frontWall.mat.specularColor=vec3(0.75);
    frontWall.mat.specularChance=0.0;
    //0.075;
    frontWall.mat.refractionChance=0.;
    //frontWall.mat=makeLight(vec3(1,1,1),3.*extra4);


    //----------- THE BACK -------------------------
    orientation.pos=vec3(0,0,30);
    orientation.dir=vec3(0,0,-1);

   // color= vec3(0.75);
    //vec3(1,.5,0.5);
    //=vec3(107,152,250)/255.;
    backWall.orientation=orientation;
    backWall.mat=makeDielectric(color,0.0,roughness);
    backWall.mat.specularColor=vec3(0.75);
    backWall.mat.specularChance=0.;
    //0.075;

   //backWall.mat=makeLight(vec3(1,1,1),15.*extra4);

    //----------- THE LEFT -------------------------
    orientation.pos=vec3(-20,0,0);
    orientation.dir=vec3(1,0,0);

  //  color=0.1*vec3(107,152,250)/255.;
    //0.5*vec3(250,229,147)/255.;
    leftWall.orientation=orientation;
    leftWall.mat=makeDielectric(color,0.0,roughness);
    leftWall.mat.specularChance=0.5;
    //leftWall.mat=makeLight(vec3(1,1,1),5.*extra4);


    //----------- THE RIGHT -------------------------
    orientation.pos=vec3(6.5,0,0);
    orientation.dir=vec3(-1,0,0);

   // color= 0.3*vec3(107,152,250)/255.;
    //0.15*vec3(240,106,86)/255.;
    //0.4*vec3(0.8,0.8,0.4);
    //0.15*vec3(240,106,86)/255.;
    //0.2*vec3(240,126,106)/255.;
   // color=0.2*vec3(107,152,250)/255.;
    //color=0.2*vec3(107,152,250)/255.;
    //vec3(0.1);
    rightWall.orientation=orientation;
    rightWall.mat=makeDielectric(color,0.0,roughness);

   rightWall.mat=makeDielectric(color,0.0,roughness);
   rightWall.mat.specularColor=vec3(0.75);
    rightWall.mat.specularChance=0.00;
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
