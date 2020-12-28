






//-------------------------------------------------
//The OBJECTS
//-------------------------------------------------


//global variables which are the names of the possible objects in the scene
Sphere light1;
Sphere light2;
Sphere light3;
Sphere light4;

Sphere ball1;
Sphere ball2;
Sphere ball3;

Plane wall1;
Plane wall2;
Plane wall3;


Ring ring1;


Lens lens1;

Prism prism1;

Octahedron oct1;
Octahedron oct2;

Permutohedron perm1;

Cocktail glass1;
Cylinder drink1;


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
    float length;
    float width;
    
    
    //----------- LIGHT 1 -------------------------
    light1.center=Point(vec3(7,1,-5));
    light1.radius=0.7;
    
    color= vec3(1.,.6,0.4);
    intensity=100.;
    
    light1.mat=makeLight(color,intensity);

    
    
    
        
    //----------- LIGHT 2 -------------------------
    light2.center=Point(vec3(0,0,-8));
    light2.radius=0.5;
    
    color= vec3(1.,0.6,0.4);
    intensity=40.;
    
    light2.mat=makeLight(color,intensity);

    
    
            
    //----------- LIGHT 3 -------------------------
    light3.center=Point(1.25*vec3(0,2,-4));
    light3.radius=0.6;
    
    color= vec3(1.,0.6,0.4);
    intensity=5.;
    
    light3.mat=makeLight(color,intensity);

    
    
    
    
            
    //----------- LIGHT 4 -------------------------
    light4.center=Point(vec3(3,0,-2));
    light4.radius=0.2;
    
    color= vec3(1.,0.6,0.4);
    intensity=10.;
    
    light4.mat=makeLight(color,intensity);

    
    
    
    
    
    
    
    
    //----------- BALL 1 -------------------------
    ball1.center=Point(vec3(0,1.,-5.4));
    ball1.radius=2.;
    
    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;
    
    ball1.mat= makeMetal(color,specularity,roughness);
    //ball1.mat=makeGlass(vec3(0.1),1.53);

    
    
    
    //----------- BALL 2 -------------------------
    ball2.center=Point(vec3(0,0,4));
    ball2.radius=0.55;
    
    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    
    ball2.mat=makeDielectric(color,specularity,roughness);

    //absorb=vec3(0.3,0.05,0.2);
    //ball2.mat=makeGlass(absorb,2.3);
    
    
    
    
    //----------- BALL 3 -------------------------
    ball3.center=Point(vec3(0.7,-0.,-1.5));
    ball3.radius=0.6;
    
    color= 0.1*vec3(0.7,0.1,0.2);
    specularity=0.4;
    roughness=0.1;
    
    //ball3.mat=makeMetal(color,specularity,roughness);

    ball3.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.3);
    
    
    
    
    
    
    
    
    
    
    //----------- WALL 1 -------------------------
    normal=vec3(0,1,0);
    offset=3.25;
    
    //color=vec3(0.5,0.9,0.5);
     color= vec3(.2);
    specularity=0.0;
    roughness=0.5;
    
    setPlane(wall1,normal,offset);
    wall1.mat=makeDielectric(color,specularity,roughness);

    

   // wall1.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.3,0.6);
    
    
    
    
    //----------- WALL 2 -------------------------
    normal=vec3(0,0,1);
    offset=10.;
    
    //color=vec3(0.9,0.5,0.5);
     color= vec3(0.2);
    //color=vec3(0.7,0.7,0.8);
    specularity=0.0;
    roughness=0.5;
    
    setPlane(wall2,normal,offset);
    wall2.mat=makeDielectric(color,specularity,roughness);

    
    
    
    
    
    
     //----------- WALL 3 -------------------------
    normal=vec3(-1,0,0);
    //normal=vec3(1,0,0);
    offset=5.;
    //offset=5.;
    
   // color=vec3(0.7,0.7,0.8);
    color= vec3(0.2);
    //color=vec3(0.5,0.9,0.5);
    specularity=0.05;
    roughness=0.5;
    
    setPlane(wall3,normal,offset);
    wall3.mat=makeDielectric(color,specularity,roughness);

    

    
    
    
    
    
    
    //----------- RING 1 -------------------------
    
    
    ring1.center=vec3(0,-0.2,0);
    ring1.radius=1.;
    ring1.tubeRad=0.1;
    ring1.stretch=0.2;
    
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
    
    
    
        
    //----------- PRISM 1 -------------------------
    
    
    center=vec3(2.,0.,-1.);
    width=1.;
    length=2.;
    
    prism1.center=center;
    prism1.width=width;
    prism1.length=length;
    prism1.mat= makeGlass(vec3(0.),1.5,0.999);
    
    
    
    
    
    
    
    
    //----------- OCTAHEDRON 1 -------------------------
    
    center=vec3(0.);
    
    oct1.center=center;
    oct1.side=1.;
    oct1.mat= makeGlass(vec3(0.),1.5,0.999);
    
    
    //----------- PERMUTOHEDRON -------------------------
    
    center=vec3(0,0,-4.);
    
    perm1.center=center;
    perm1.side=3.;
   // perm1.mat= makeGlass(vec3(0.),2.43,0.999);
    
    color=vec3(0.6,0.6,0.1);
    specularity=0.5;
    roughness=0.0;
    perm1.mat=makeMetal(color,specularity,roughness);
    
    
    
    
    //----------- COCKTAIL 1 -------------------------
    
    glass1.center=vec3(0.,0.,-4.);
    glass1.radius=1.;
    glass1.height=2.;
    glass1.rounded=0.1;
    glass1.base=1.;
    
    glass1.mat= makeGlass(0.3*vec3(0.3,0.05,0.2),1.5,0.99);
    
    
    drink1.center=vec3(0.,-1.,-4.);
    drink1.radius=1.;
    drink1.height=1.;
    drink1.rounded=0.1;
    
    drink1.mat= makeGlass(0.85*vec3(0.2,0.5,0.5),1.3,0.99);
    
    
    
    
}













//decide if we are in the liquid or not:
//bool inLiquid(Vector tv){
//    if(cylinderSDF(tv,drink1,trashDat)<0.){
//        return true;
//    }
//    return false;
//}



//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(Vector tv, inout localData dat){

    float dist=maxDist;
    
    //just choose the objects you want to include!
    
    
    //------the lights
    
    dist=min(dist,sphereSDF(tv,light1,dat));
    
// dist=min(dist,sphereSDF(tv,light2,dat));
    
   // dist=min(dist,sphereSDF(tv,light3,dat));
    
   // dist=min(dist,sphereSDF(tv,light4,dat));
    
    
    //------the balls
    
    dist=min(dist,sphereSDF(tv,ball1,dat));
    
    //dist=min(dist,sphereSDF(tv,ball2,dat));
    
    dist=min(dist,sphereSDF(tv,ball3,dat));
    
    
    
    //------the walls 
    dist=min(dist,planeSDF(tv,wall1,dat));
    
   dist=min(dist,planeSDF(tv,wall2,dat));
   
//dist=min(dist,planeSDF(tv,wall3,dat));
   
    
    //-------a ring
    
   // dist=min(dist,ringSDF(tv,ring1,dat));
    
    
    
    
    //-------a lens
    
    //dist=min(dist,lensSDF(tv,lens1,dat));
    
    //-------a prism
    
    //dist=min(dist,prismSDF(tv,prism1,dat));
    
    
    //-------an octahedron
    
   // dist=min(dist,octahedronSDF(tv,oct1,dat));
    
    
    
    //-------an cocktail glass
    
    //dist=min(dist,cocktailSDF(tv,glass1,dat));
        
    //dist=min(dist,cylinderSDF(tv,drink1,dat));
    
    
        
    //-------a permutohedron
    
  //  dist=min(dist,permutohedronSDF(tv,perm1,dat));
    
    
    
    if(dist>EPSILON){
        
        zeroMat(dat.mat);
    }
    return dist;
}




