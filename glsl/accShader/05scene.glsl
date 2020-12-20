






//-------------------------------------------------
//The OBJECTS
//-------------------------------------------------


//global variables which are the names of the possible objects in the scene
Sphere light1;
Sphere light2;

Sphere ball1;
Sphere ball2;
Sphere ball3;


//
EucPlane wall1;
EucPlane wall2;
EucPlane wall3;



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
    vec3 absorb;
    float thickness;
    vec3 axis;
    Point center;
    float radius;
    
    
    //----------- LIGHT 1 -------------------------
    light1.center.coords=vec3(1.,0.,1.);
    light1.radius=.5;
    
    color= vec3(1.,0.6,0.4);
    intensity=20.;
    
    light1.mat=makeLight(color,intensity);

    
    
    
        
    //----------- LIGHT 2 -------------------------
    light2.center.coords=vec3(0,0,1);
    light2.radius=0.5;
    
    color= vec3(1.,0.6,0.4);
    intensity=80.;
    
    light2.mat=makeLight(color,intensity);

    
    
    
    
    
    
    
    
    //----------- BALL 1 -------------------------
    ball1.center.coords=vec3(-2,-1,-1);
    ball1.radius=1.;
    
    color= 0.7*vec3(0.9,0.9,0.5);
    specularity=0.2;
    roughness=0.;
    
    ball1.mat= makeMetal(color,specularity,roughness);
    //ball1.mat=makeGlass(vec3(0.1),1.53);

    
    
    
    //----------- BALL 2 -------------------------
    ball2.center.coords=vec3(-.5,0.2,-1.);
    ball2.radius=0.55;
    
    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.1;
    roughness=0.1;
    
    ball2.mat=makeDielectric(color,specularity,roughness);

    //absorb=vec3(0.3,0.05,0.2);
    //ball2.mat=makeGlass(absorb,2.3);
    
    
    
    
    //----------- BALL 3 -------------------------
    ball3.center.coords=vec3(2,0.,-1.);
    ball3.radius=0.6;
    
    color= 0.7*vec3(0.7,0.1,0.2);
    specularity=0.1;
    roughness=0.1;
    
    ball3.mat=makeMetal(color,specularity,roughness);

    //ball3.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),2.3);
    
    
    
   
    //----------- WALL 1 -------------------------
    wall1.height=-1.;
    wall1.sign=1.;
    
    color=vec3(0.1,0.2,0.35);
    specularity=0.;
    roughness=0.2;
    
    wall1.mat=makeDielectric(color,specularity,roughness);

 
    //----------- WALL 2 -------------------------
    wall2.height=2.;
    wall2.sign=-1.;
    
    color=vec3(0.8,0.33,0.);
    specularity=0.;
    roughness=0.5;
    
    wall2.mat=makeDielectric(color,specularity,roughness);

    
//    
//    
//    
//    
//    
//     //----------- WALL 3 -------------------------
//    normal=vec3(-1,0,0);
//    //normal=vec3(1,0,0);
//    offset=5.;
//    //offset=5.;
//    
//    color=vec3(0.5,0.9,0.5);
//    specularity=0.;
//    roughness=0.5;
//    
//    setPlane(wall3,normal,offset);
//    wall3.mat=makeDielectric(color,specularity,roughness);
//
//    
//
//    
//    
//

    
}










//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(Vector tv, inout localData dat){

    float dist=maxDist;
    
    //just choose the objects you want to include!
    
    
    //------the lights
    
    //dist=min(dist,sphereSDF(tv,light1,dat));
    
    dist=min(dist,sphereSDF(tv,light2,dat));
    
    
    //------the balls
    
   // dist=min(dist,sphereSDF(tv,ball1,dat));
  //  
   // dist=min(dist,sphereSDF(tv,ball2,dat));
    
  //  dist=min(dist,sphereSDF(tv,ball3,dat));
    
    
    
    //------the walls 
//    
    dist=min(dist,EucPlaneSDF(tv,wall1,dat));
//    
    dist=min(dist,EucPlaneSDF(tv,wall2,dat));
//    
//    dist=min(dist,planeSDF(tv,wall3,dat));
//    
//    

    
    
    return dist;
}




