//-------------------------------------------------
// WALLS OF THE SCENE
//-------------------------------------------------


//set the names of the walls:
Plane bottomWall, topWall, leftWall, rightWall, backWall, frontWall;


void buildWalls(){

    Vector orientation;
    vec3 color=0.5*vec3(171,203,240)/255.;//sky blue
    float specularity=0.;
    float roughness=0.1;

    //----------- THE FLOOR -------------------------
    orientation.pos=vec3(0,-5,0);
    orientation.dir=vec3(0,1,0);
    bottomWall.orientation=orientation;
    color =0.5*vec3(171,203,240)/255.;//sky blue
    bottomWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE CEILING -------------------------
    orientation.pos=vec3(0,15,0);
    orientation.dir=vec3(0,-1,0);
    topWall.orientation=orientation;
    topWall.mat=makeLight(vec3(1,1,1),1.*extra4);


    //----------- THE FRONT -------------------------
    orientation.pos=vec3(0,0,-15);
    orientation.dir=vec3(0,0,1);
    frontWall.orientation=orientation;
    color=0.5*vec3(77, 143, 74)/255.;//greenish
    frontWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE BACK -------------------------
    orientation.pos=vec3(0,0,15);
    orientation.dir=vec3(0,0,-1);
    backWall.orientation=orientation;
    color=0.5*vec3(168, 58, 50)/255.;//reddish
    backWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE LEFT -------------------------
    orientation.pos=vec3(-15,0,0);
    orientation.dir=vec3(1,0,0);
    leftWall.orientation=orientation;
    color=0.5*vec3(209, 163, 56)/255.;//yellowish
    leftWall.mat=makeDielectric(color,0.0,roughness);



    //----------- THE RIGHT -------------------------
    orientation.pos=vec3(15,0,0);
    orientation.dir=vec3(-1,0,0);
    rightWall.orientation=orientation;
    color=0.5*vec3(116, 66, 138)/255.;//purpleish
    rightWall.mat=makeDielectric(color,0.0,roughness);

}



//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------

bool render_Walls=true;


//-------------------------------------------------
//Finding the Walls
//-------------------------------------------------


float sdf_Walls(Vector tv ){

    float dist=maxDist;
    dist=min(dist, sdf(tv, bottomWall));
    dist=min(dist, sdf(tv, topWall));
    dist=min(dist, sdf(tv, frontWall));
    dist=min(dist, sdf(tv, backWall));
    dist=min(dist, sdf(tv, leftWall));
    dist=min(dist, sdf(tv, rightWall));

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
