






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


Lens lens1;




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
    vec3 center;
    float radius;
    
    
    //----------- LIGHT 1 -------------------------
    light1.center=vec3(0.7,1.3,-1.5);
    light1.radius=0.2;
    
    color= vec3(1.,0.6,0.4);
    intensity=40.;
    
    light1.mat=makeLight(color,intensity);

    
    
    
        
    //----------- LIGHT 2 -------------------------
    light2.center=vec3(3,0,1);
    light2.radius=0.2;
    
    color= vec3(1.,0.6,0.4);
    intensity=60.;
    
    light2.mat=makeLight(color,intensity);

    
    
    
    
    
    
    
    
    //----------- BALL 1 -------------------------
    ball1.center=vec3(0,-0.1,-2.);
    ball1.radius=0.5;
    
    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;
    
    ball1.mat= makeMetal(color,specularity,roughness);
    //ball1.mat=makeGlass(vec3(0.1),1.53);

    
    
    
    //----------- BALL 2 -------------------------
    ball2.center=vec3(-1.,-0.43,-1.6);
    ball2.radius=0.55;
    
    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    
    ball2.mat=makeDielectric(color,specularity,roughness);

    //absorb=vec3(0.3,0.05,0.2);
    //ball2.mat=makeGlass(absorb,2.3);
    
    
    
    
    //----------- BALL 3 -------------------------
    ball3.center=vec3(0.7,-0.,-1.5);
    ball3.radius=0.6;
    
    color= 0.1*vec3(0.7,0.1,0.2);
    specularity=0.4;
    roughness=0.1;
    
    //ball3.mat=makeMetal(color,specularity,roughness);

    ball3.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),2.3);
    
    
    
    
    
    
    
    
    
    
    //----------- WALL 1 -------------------------
    normal=vec3(0,1,0);
    offset=1.;
    
    color=vec3(1.,0.7,0.7);
    specularity=0.;
    roughness=0.2;
    
    setPlane(wall1,normal,offset);
    wall1.mat=makeDielectric(color,specularity,roughness);

    

    
    
    
    //----------- WALL 2 -------------------------
    normal=vec3(0,0,1);
    offset=5.;
    
    color=vec3(0.7,0.7,0.8);
    specularity=0.;
    roughness=0.5;
    
    setPlane(wall2,normal,offset);
    wall2.mat=makeDielectric(color,specularity,roughness);

    
    
    
    
    
    
     //----------- WALL 3 -------------------------
    normal=vec3(-1,0,0);
    //normal=vec3(1,0,0);
    offset=5.;
    //offset=5.;
    
    color=vec3(0.5,0.9,0.5);
    specularity=0.;
    roughness=0.5;
    
    setPlane(wall3,normal,offset);
    wall3.mat=makeDielectric(color,specularity,roughness);

    

    
    
    
    
    
    
    //----------- RING 1 -------------------------
    
    
    ring1.center=vec3(0.3,-0.75,-.6);
    ring1.radius=0.3;
    ring1.tubeRad=0.02;
    ring1.stretch=0.05;
    
    color=vec3(0.7,0.7,0.2);
    specularity=0.8;
    roughness=0.05;
    
    ring1.mat=makeMetal(color,specularity,roughness);
    
    
    
    
    
    
    //----------- LENS 1 -------------------------
    
    
    center=vec3(1,0,-3.);
    radius=1.;
    thickness=0.3;
    axis=vec3(0,0,1);
    
    //set the parameters R, c1, c2
    setLens(lens1,radius,thickness,center,axis);
    
    lens1.mat= makeGlass(vec3(0.1,0.0,0.2),2.3,0.999);
    
}










//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(Vector tv, inout localData dat){

    float dist=maxDist;
    
    //just choose the objects you want to include!
    
    
    //------the lights
    
    dist=min(dist,sphereSDF(tv,light1,dat));
    
    dist=min(dist,sphereSDF(tv,light2,dat));
    
    
    //------the balls
    
    dist=min(dist,sphereSDF(tv,ball1,dat));
    
    dist=min(dist,sphereSDF(tv,ball2,dat));
    
    dist=min(dist,sphereSDF(tv,ball3,dat));
    
    
    
    //------the walls 
    
    dist=min(dist,planeSDF(tv,wall1,dat));
    
    dist=min(dist,planeSDF(tv,wall2,dat));
    
    dist=min(dist,planeSDF(tv,wall3,dat));
    
    
    
    //-------a ring
    
    //dist=min(dist,ringSDF(tv,ring1,dat));
    
    
    
    
    //-------a lens
    
    //dist=min(dist,lensSDF(tv,lens1,dat));
    
    
    
    
    return dist;
}




