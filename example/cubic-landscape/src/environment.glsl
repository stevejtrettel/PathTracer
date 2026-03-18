//-------------------------------------------------
// ENVIRONMENT OF THE SCENE
//-------------------------------------------------

bool render_Environment=true;


//set the names of the lights:
Sphere light;
Sphere light2;

//set the names of the walls:
Plane bottomWall, topWall, leftWall, rightWall, backWall, frontWall;



void buildEnvironment(){

    vec3 lightColor;
    float lightIntensity;

    //----------- LIGHT 1 -------------------------
    light.center=vec3(-8,10,2);
    light.radius=0.5;

    lightColor= vec3(1., 0.95, 0.9);
    lightIntensity=400.;
    light.mat=makeLight(lightColor,lightIntensity);

    //----------- LIGHT 2 (left side) -------------------------
    light2.center=vec3(-12,4,-4);
    light2.radius=0.4;
    light2.mat=makeLight(vec3(1.), 300.);

    //------------------------------------
    // THE WALLS
    //------------------------------------

    Vector orientation;
    vec3 color=vec3(0.12, 0.12, 0.14);
    float specularity=0.;
    float roughness=0.1;

    //----------- THE FLOOR -------------------------
    orientation.pos=vec3(0,-3.0,0);
    orientation.dir=vec3(0,1,0);
    bottomWall.orientation=orientation;
    bottomWall.mat=makeDielectric(color,0.0,roughness);

    //----------- THE CEILING -------------------------
    vec3 bounce = vec3(0.85);
    orientation.pos=vec3(0,14,0);
    orientation.dir=vec3(0,-1,0);
    topWall.orientation=orientation;
    topWall.mat=makeDielectric(vec3(0.5),0.0,roughness);


    //----------- THE FRONT (behind camera) -------------------------
    orientation.pos=vec3(0,0,-20);
    orientation.dir=vec3(0,0,1);
    frontWall.orientation=orientation;
    frontWall.mat=makeDielectric(bounce,0.0,roughness);


    //----------- THE BACK -------------------------
    orientation.pos=vec3(0,0,10);
    orientation.dir=vec3(0,0,-1);
    backWall.orientation=orientation;
    backWall.mat=makeDielectric(color,0.0,roughness);


    //----------- THE LEFT -------------------------
    orientation.pos=vec3(-20,0,0);
    orientation.dir=vec3(1,0,0);
    leftWall.orientation=orientation;
    leftWall.mat=makeDielectric(color,0.0,roughness);



    //----------- THE RIGHT -------------------------
    orientation.pos=vec3(20,0,0);
    orientation.dir=vec3(-1,0,0);
    rightWall.orientation=orientation;
    rightWall.mat=makeDielectric(color,0.0,roughness);

}




//-------------------------------------------------
//Finding the Environment
//-------------------------------------------------


float trace_Environment(Vector tv ){

    float dist=maxDist;

    dist = min(dist, trace(tv,light));
    dist = min(dist, trace(tv,light2));

    dist=min(dist, trace(tv, bottomWall));
    dist=min(dist, trace(tv, topWall));
    dist=min(dist, trace(tv, frontWall));
    dist=min(dist, trace(tv, backWall));
    dist=min(dist, trace(tv, leftWall));
    dist=min(dist, trace(tv, rightWall));

    return dist;

}

float sdf_Environment(Vector tv ){

    float dist=maxDist;

    //nothing to raymarch!

    return dist;

}




//-------------------------------------------------
//Setting the Walls Data
//-------------------------------------------------



void setData_Environment( inout Path path ){

    setData(path, light);
    setData(path, light2);

    setData(path, bottomWall);

    setData(path, topWall);

    setData(path, frontWall);

    setData(path, backWall);

    setData(path, leftWall);

    setData(path, rightWall);

}
