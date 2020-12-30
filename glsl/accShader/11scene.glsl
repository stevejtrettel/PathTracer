
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


Cylinder cyl1;

Bottle bottle;

CocktailGlass cGlass;

//
//Ring ring1;
//
//
//Lens lens1;
//
//Prism prism1;
//
//Octahedron oct1;
//Octahedron oct2;
//
//Permutohedron perm1;
//
//Cocktail glass1;
//Cylinder drink1;
//
//
//Negroni negroni;
//Negroni negroni2;
//
//ConeCup cone;
//ConeCup cone2;
//
//
//Bottle bottle;
//Bottle gin;
//Bottle campari;
//Bottle vermouth;
//
//FullBottle fullBottle;
//FullBottle ginBottle;
//FullBottle campariBottle;
//FullBottle vermouthBottle;

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
    light1.center=Point(vec3(15,3,-5));
    light1.radius=2.;
    
    color=  vec3(255./255., 197./255., 143./255.);
    intensity=50.;
    
    light1.mat=makeLight(color,intensity);

    
    
    
        
    //----------- LIGHT 2 -------------------------
    light2.center=Point(vec3(0,15.5,-5));
    light2.radius=3.;
    
    color= vec3(255./255., 147./255., 41./255.);
       // vec3(1.,0.6,0.4);
    intensity=3.;
    
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
    ball3.center=Point(vec3(0.,0.,-2));
    ball3.radius=0.6;
    
    color= 0.1*vec3(0.7,0.1,0.2);
    specularity=0.4;
    roughness=0.1;
    
    //ball3.mat=makeMetal(color,specularity,roughness);

    ball3.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.3);
    
    
    
    
    
    
    
    
    
    
    //----------- WALL 1 -------------------------
    normal=vec3(0,1,0);
    offset=1.7;
    
    //color=vec3(0.5,0.9,0.5);
     color= vec3(.2);
    specularity=0.0;
    roughness=0.1;
    
    setPlane(wall1,normal,offset);
    wall1.mat=makeDielectric(color,specularity,roughness);

    

   // wall1.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.3,0.6);
    
    
    
    
    //----------- WALL 2 -------------------------
    normal=vec3(0,0,1);
    offset=19.;
    
    //color=vec3(0.9,0.5,0.5);
     color= vec3(0.2);
    //color=vec3(0.7,0.7,0.8);
    specularity=0.0;
    roughness=0.;
    
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

    

    
    
      
     //----------- CYLINDER 1 -------------------------
    
    cyl1.center=Point(vec3(0,0,-5));
    cyl1.radius=1.;
    cyl1.height=2.;
    cyl1.rounded=0.2;
    cyl1.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.3);
    
    
    
    
    
    //-------- BOTTLE ----------------
   
    bottle.baseHeight=2.5;
    bottle.baseRadius=1.;
    bottle.neckHeight=1.75;
    bottle.neckRadius=0.3;
    bottle.thickness=0.2;
    bottle.center=Point(vec3(5,1.5,-8));
    bottle.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);

    
    
    //-------- COCKTAIL GLASD----------------
    
    cGlass.center=Point(vec3(0,0.3,-2));
    cGlass.radius=0.75;
    cGlass.height=1.5;
    cGlass.thickness=0.2;
    cGlass.base=0.5;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);

    
    
    
//    
//    
//    
//    //----------- RING 1 -------------------------
//    
//    
//    ring1.center=vec3(0,-0.2,0);
//    ring1.radius=1.;
//    ring1.tubeRad=0.1;
//    ring1.stretch=0.2;
//    
//    color=vec3(0.7,0.7,0.2);
//    specularity=0.8;
//    roughness=0.05;
//    
//    
//        
//    ring1.mat=makeMetal(color,specularity,roughness);
//    
//    
//    
//    
//    
//    
//    //----------- LENS 1 -------------------------
//    
//    
//    center=vec3(1,0,-3.);
//    radius=1.;
//    thickness=0.3;
//    axis=vec3(0,0,1);
//    
//    //set the parameters R, c1, c2
//    setLens(lens1,radius,thickness,center,axis);
//    
//    lens1.mat= makeGlass(vec3(0.1,0.0,0.2),2.3,0.999);
//    
//    
//    
//        
//    //----------- PRISM 1 -------------------------
//    
//    
//    center=vec3(2.,0.,-1.);
//    width=1.;
//    length=2.;
//    
//    prism1.center=center;
//    prism1.width=width;
//    prism1.length=length;
//    prism1.mat= makeGlass(vec3(0.),1.5,0.999);
//    
//    
//    
//    
//    
//    
//    
//    
//    //----------- OCTAHEDRON 1 -------------------------
//    
//    center=vec3(0.,0,-4.);
//    
//    oct1.center=center;
//    oct1.side=2.;
//    oct1.mat= makeGlass(vec3(0.),1.5,0.999);
//    
//    
//    //----------- PERMUTOHEDRON -------------------------
//    
//    center=vec3(0,0,-4.);
//    
//    perm1.center=center;
//    perm1.side=3.;
//   // perm1.mat= makeGlass(vec3(0.),2.43,0.999);
//    
//    color=vec3(0.6,0.6,0.1);
//    specularity=0.5;
//    roughness=0.0;
//    perm1.mat=makeMetal(color,specularity,roughness);
//    
//    
//    
//    
//    //----------- COCKTAIL 1 -------------------------
//    
//    glass1.center=vec3(0.,0.,-4.);
//    glass1.radius=1.;
//    glass1.height=2.;
//    glass1.rounded=0.1;
//    glass1.base=1.;
//    
//    glass1.mat= makeGlass(0.3*vec3(0.3,0.05,0.2),1.5,0.99);
//    
//    
//    drink1.center=vec3(0.,-1.,-4.);
//    drink1.radius=1.;
//    drink1.height=1.;
//    drink1.rounded=0.1;
//    
//    drink1.mat= makeGlass(0.85*vec3(0.2,0.5,0.5),1.3,0.99);
//    
//    
//    
//    
//         //-------- DRINK COLORS -----------------
//    
//    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
//    
//    vec3 redAbsorb=vec3(0.,1.,0.5);
//    
//    
//    
//    
//    //-------- NEGRONI-----------------
//    
//    negroni.center=vec3(1.5,0,-2.5);
//    negroni.radius=0.75;
//    negroni.height=1.5;
//    negroni.thickness=0.1;
//    negroni.base=0.3;
//    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.99);
//    //negroni.drink=makeGlass(0.75*vec3(0.,1.,0.5),1.3,0.99);
//    negroni.drink=makeGlass(2.*(brownAbsorb+0.25*redAbsorb),1.3,0.99);
//    
//    //-------- NEGRONI-----------------
//    
//    negroni2.center=vec3(-6,-0.,-8);
//    negroni2.radius=0.5;
//    negroni2.height=1.5;
//    negroni2.thickness=0.1;
//    negroni2.base=0.4;
//    negroni2.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.99);
//    negroni2.drink=makeGlass(0.1*vec3(0.5,0.2,0.),1.3,0.99);
//    
//    
//    
//    
//    //-------- CONE CUP ----------------
//    
//    //these parameters are a bit fucked up: need to fix height vs thickness, and swap radii
//    cone.height=3.5;
//    cone.rBase=2.;
//    cone.rTop=1.5;
//    cone.thickness=5.;
//    cone.center=vec3(-5,0,-6);
//    cone.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
//    
//    
//    //these parameters are a bit fucked up: need to fix height vs thickness, and swap radii
//    cone2.height= 3.5;
//    cone2.rBase=2.;
//    cone2.rTop=1.5;
//    cone2.thickness=5.;
//    cone2.center=vec3(-3,0,-10);
//    
//    
//    color= vec3(0.1,0.1,0.1);
//    specularity=0.6;
//    roughness=0.2;
//    
//    //cone2.mat= makeMetal(color,specularity,roughness);
//    
//     cone2.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
//    
//    
//    
//    
//    
//    
//    
//        

    
//    
// 
//    
//    //---- gin bottle
//    //start by copying the above
//    gin=bottle;
//    gin.center+=vec3(1,0.2,1.5);
//    gin.mat=makeGlass(0.25*vec3(0.1,0.05,0.),1.3,0.99);
//    ginBottle.bottle=gin;
//    ginBottle.fill=1.4;
//    ginBottle.drink=makeGlass(0.3*vec3(0.1,0.05,0.),1.3,0.99);
//        
//        
//    //start by copying the above
//    vermouth=bottle;
//    //change some things
//    vermouth.center+=vec3(-5,0.3,0);
//    vermouth.mainRadius=0.6;
//    vermouth.neckRadius=0.2;
//    vermouth.mat.absorbColor=0.05*brownAbsorb;
//        
//    vermouthBottle.bottle=vermouth;
//    vermouthBottle.fill=0.2;
//    vermouthBottle.drink=makeGlass(2.*brownAbsorb,1.3,0.99);
//        
//        
//    
//    //start by copying the above
//    campari=bottle;
//    //change some things
//    campari.center+=vec3(-2,2,-3);
//    campari.mat.absorbColor*=0.2;
//    campari.mainRadius=0.75;
//    campari.mainHeight=4.5;
//    campari.neckHeight=1.;
//    
//    campariBottle.bottle=campari;
//    campariBottle.fill=1.;
// campariBottle.drink=makeGlass(2.5*vec3(0.2,1.,0.6),1.3,0.99);
//        
//        
//            
//        
//        
//        
//    
//    
//    //----full bottle
//    //use the bottle above
//    fullBottle.bottle=bottle;
//    fullBottle.drink=makeGlass(2.*(vec3(1.)-vec3(204./255.,142./255.,105./255.)),1.3,0.99);
//    
//    
}




//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(Path path, inout localData dat){

    float dist=maxDist;
    
    //just choose the objects you want to include!
    
    
    //------the lights
    
    dist=min(dist,sphereSDF(path,light1,dat));
    
 dist=min(dist,sphereSDF(path,light2,dat));
    
  //  dist=min(dist,sphereSDF(path,light3,dat));
    
   // dist=min(dist,sphereSDF(tv,light4,dat));
    
    
    //------the balls
    
   // dist=min(dist,sphereSDF(path,ball1,dat));
    
    //dist=min(dist,sphereSDF(tv,ball2,dat));
    
    //dist=min(dist,sphereSDF(path,ball3,dat));
    
    
    
    //------the walls 
    dist=min(dist,planeSDF(path,wall1,dat));
    
    dist=min(dist,planeSDF(path,wall2,dat));
   
    //dist=min(dist,planeSDF(tv,wall3,dat));
   
    
    
    
    //------cylinders
    
   // dist=min(dist,cylinderSDF(path,cyl1,dat));
    
    //-------a ring
    
   // dist=min(dist,ringSDF(tv,ring1,dat));
    
    
    
    
    //-------a lens
    
    //dist=min(dist,lensSDF(tv,lens1,dat));
    
    //-------a prism
    
    //dist=min(dist,prismSDF(tv,prism1,dat));
    
    
    //-------an octahedron
    
    //dist=min(dist,octahedronSDF(path,oct1,dat));
    
    
    
    //-------an cocktail glass
    
    //dist=min(dist,cocktailSDF(path,glass1,dat));
        
  //  dist=min(dist,cylinderSDF(path.tv,drink1,dat));
    
    
        
    //-------a permutohedron
    
  //  dist=min(dist,permutohedronSDF(tv,perm1,dat));
    
    
    //-------DRINKS
    
  // dist=min(dist,negroniSDF(path,negroni,dat));
    
   // dist=min(dist,negroniSDF(path,negroni2,dat));
    
    
  //  dist=min(dist,coneCupSDF(path,cone,dat));
    
    //dist=min(dist,coneCupSDF(path,cone2,dat));
    
    
    
    //-------BOTTLES
    
    
    dist=min(dist,bottleSDF(path,bottle,dat));
    
    dist=min(dist,cocktailGlassSDF(path,cGlass,dat));
    
     //dist=min(dist,fullBottleSDF(path,fullBottle,dat));
    
     // dist=min(dist,fullBottleSDF(path,ginBottle,dat));
     // dist=min(dist,fullBottleSDF(path,vermouthBottle,dat));
         // dist=min(dist,fullBottleSDF(path,campariBottle,dat));
    return dist;
}




