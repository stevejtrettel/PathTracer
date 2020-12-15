






//-------------------------------------------------
//The OBJECTS
//-------------------------------------------------


//global variables which are the names of the possible objects in the scene
Sphere light1;
Sphere light2;

Sphere ball1;
Sphere ball2;
Sphere ball3;

Plane wall1;
Plane wall2;
Plane wall3;


Ring ring1;





//this function assigns all the objects their parameters
void buildScene(){
    
    //some useful variables for setting parameters
    vec3 color;
    float intensity;
    float specularity;
    float roughness;
    float IOR;
    
    vec3 normal;
    float offset;
    
    
    
    
    //----------- LIGHT 1 -------------------------
    light1.center=vec3(-0.2,0.8,-1.5);
    light1.radius=0.2;
    
    color= vec3(1.,0.6,0.4);
    intensity=30.;
    
    light1.mat=makeLight(color,intensity);

    
    
    
        
    //----------- LIGHT 2 -------------------------
    light2.center=vec3(0.0,-0.3,0.8);
    light2.radius=0.2;
    
    color= vec3(1.,0.6,0.4);
    intensity=60.;
    
    light2.mat=makeLight(color,intensity);

    
    
    
    
    
    
    
    
    //----------- BALL 1 -------------------------
    ball1.center=vec3(0,-0.1,-2.);
    ball1.radius=0.5;
    
    color= vec3(0.9,0.9,0.5);
    specularity=0.2;
    roughness=0.4;
    
    //ball1.mat= makeDielectric(color,specularity,roughness);
    ball1.mat=makeGlass(vec3(0.1),1.2);

    
    
    
    //----------- BALL 2 -------------------------
    ball2.center=vec3(-0.8,-0.63,-1.6);
    ball2.radius=0.25;
    
    color= vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.05;
    
    //ball2.mat=makeDielectric(color,specularity,roughness);
        //ball3.mat.refractionChance=0.6;
        ball2.mat=makeGlass(vec3(0.),2.3);
    
    
    
    
    //----------- BALL 3 -------------------------
    ball3.center=vec3(-0.1,-0.7,-1.3);
    ball3.radius=0.15;
    
    color= 0.2*vec3(0.7,0.1,0.2);
    specularity=0.1;
    roughness=0.9;
    
    ball3.mat=makeDielectric(color,specularity,roughness);

   
    
    
    
    
    
    
    
    
    
    
    //----------- WALL 1 -------------------------
    normal=vec3(0,1,0);
    offset=1.;
    
    color=vec3(1.,0.7,0.7);
    specularity=0.1;
    roughness=0.2;
    
    setPlane(wall1,normal,offset);
    wall1.mat=makeDielectric(color,specularity,roughness);

    

    
    
    
    //----------- WALL 2 -------------------------
    normal=vec3(1,0,1);
    offset=5.;
    
    color=vec3(0.7,0.7,0.8);
    specularity=0.1;
    roughness=0.5;
    
    setPlane(wall2,normal,offset);
    wall2.mat=makeDielectric(color,specularity,roughness);

    
    
    
    
    
    
     //----------- WALL 3 -------------------------
    normal=vec3(-1,0,1);
    offset=5.;
    
    color=vec3(0.5,0.9,0.5);
    specularity=0.;
    roughness=0.5;
    
    setPlane(wall3,normal,offset);
    wall3.mat=makeDielectric(color,specularity,roughness);

    

    
    
    
    
    
    
    //----------- RING 1 -------------------------
    
    
    ring1.center=vec3(0.,-0.55,-1.4);
    ring1.radius=0.5;
    ring1.tubeRad=0.02;
    ring1.stretch=0.1;
    
    color=vec3(0.7,0.7,0.2);
    specularity=0.8;
    roughness=0.05;
    
    ring1.mat=makeMetal(color,specularity,roughness);
    
    
    
    
}










//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(Vector tv, inout localData dat){

    float dist=maxDist;
    
    //just choose the objects you want to include!
    
    
    //------the lights
    
    dist=min(dist,sphereSDF(tv,light1,dat));
    
   // dist=min(dist,sphereSDF(tv,light2,dat));
    
    
    //------the balls
    
   dist=min(dist,sphereSDF(tv,ball1,dat));
    
   dist=min(dist,sphereSDF(tv,ball2,dat));
    
  // dist=min(dist,sphereSDF(tv,ball3,dat));
    
    
    
    //------the walls 
    
    dist=min(dist,planeSDF(tv,wall1,dat));
    
   // dist=min(dist,planeSDF(tv,wall2,dat));
    
   // dist=min(dist,planeSDF(tv,wall3,dat));
    
    
    
    //-------a ring
    
    //dist=min(dist,ringSDF(tv,ring1,dat));
    
    
    return dist;
}




