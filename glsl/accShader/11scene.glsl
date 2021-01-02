
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

LiquorBottle gin;
LiquorBottle gin2;
LiquorBottle campari;
LiquorBottle vermouth;
LiquorBottle violet;
LiquorBottle limoncello;


CocktailGlass cGlass;


Cocktail negroni;
Cocktail shotglass;


LightBulb incandescent;


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
    intensity=30.;
    
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
    ball1.center=Point(vec3(-1,0,-4));
    ball1.radius=1.;
    
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
    normal=vec3(1,0,0.2);
    //normal=vec3(1,0,0);
    offset=15.;
    //offset=5.;
    
   // color=vec3(0.7,0.7,0.8);
    color= vec3(0.2);
    //color=vec3(0.5,0.9,0.5);
    specularity=0.0;
    roughness=0.5;
    
    setPlane(wall3,normal,offset);
    wall3.mat=makeDielectric(color,specularity,roughness);

    

    
    
      
     //----------- CYLINDER 1 -------------------------
    
    cyl1.center=Point(vec3(1,0,-4));
    cyl1.radius=1.;
    cyl1.height=1.;
    cyl1.rounded=0.;
    cyl1.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.3);
    
    
    
    
    
    //-------- BOTTLE ----------------
   
    bottle.baseHeight=1.;
    bottle.baseRadius=1.;
    bottle.neckHeight=1.;
    bottle.neckRadius=0.3;
    bottle.thickness=0.2;
    bottle.rounded=0.2;
    bottle.smoothJoin=0.3;
    bottle.center=Point(vec3(5,1.5,-8));
    bottle.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    
    
    
    
    //-------- DRINK COLORS -----------------
    
        vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));

        vec3 redAbsorb=vec3(0.2,1.,0.6);
    
        //vec3 purpleAbsorb=vec3(0.1,0.8,0.1);
    
    
    
    
    //-------- GIN BOTTLE ----------------
   
    gin.glass=bottle;
    gin.glass.center.coords=vec3(6,0.2,-4.5);
    gin.glass.baseRadius=1.25;
    gin.glass.baseHeight=1.5;
    gin.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
    gin.drink=makeGlass(0.3*vec3(0.1,0.05,0.),1.3,0.99);
    gin.fill=0.;
    
    
    gin2=gin;
    gin2.glass.center.coords=vec3(7,0.2,-8);
    
    
    
        
    //-------- CAMPARI BOTTLE ----------------
   
    campari.glass=bottle;
    campari.glass.center.coords=vec3(3,2.25,-9);
    campari.glass.baseRadius=1.;
    campari.glass.baseHeight=3.5;
    campari.glass.neckHeight=0.5;
    campari.glass.smoothJoin=0.5;
    campari.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
    campari.drink=makeGlass(2.5*redAbsorb,1.3,0.99);
    campari.fill=0.5;
    
    
    //-------- CREME DE VIOLET BOTTLE ----------------
    violet=campari;
    violet.glass.center.coords+=vec3(7,0.,2);
    violet.drink=makeGlass(2.*vec3(0.1,0.8,0.1),1.3,0.99);
    
    //-------- LIMONCELLO BOTTLE ----------------
    limoncello=campari;
    limoncello.glass.baseHeight-=1.;
    limoncello.glass.center.coords+=vec3(4,-1,0);
    limoncello.drink=makeGlass(vec3(0.1,0.1,0.8),1.3,0.99);
    
    

    //-------- VERMOUTH BOTTLE ----------------
   
    vermouth.glass=bottle;
    vermouth.glass.center.coords+=vec3(0,1.15,-8);
    vermouth.glass.baseRadius=0.6;
    vermouth.glass.baseHeight=2.5;
    vermouth.glass.neckRadius=0.2;
    vermouth.glass.smoothJoin=0.01;
    vermouth.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
    vermouth.drink=makeGlass(2.*brownAbsorb,1.3,0.99);
    vermouth.fill=0.6;
    
    
    //-------- COCKTAIL GLASS----------------
    
    cGlass.center=Point(vec3(0,-0.5,-5));
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    
    //-------- NEGRONI ----------------
   
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.99);
    negroni.drink=makeGlass(2.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    
    
     //--------SHOTGLASS ----------------
   
    shotglass.glass=cGlass;
    shotglass.glass.center.coords=vec3(-6,-1.5,-8);
    shotglass.glass.radius=0.5;
    shotglass.glass.height=1.;
    shotglass.glass.thickness=0.1;
    shotglass.glass.base=0.4;
    shotglass.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.99);
    shotglass.drink=makeGlass(0.1*vec3(0.5,0.2,0.),1.3,0.99);
    
    
    
    //--------LIGHT BULB ----------------
    
    incandescent.center.coords=vec3(10,2,-2);
    incandescent.bulbRadius=1.;
    incandescent.neckRadius=0.5;
    incandescent.neckLength=1.25;
    incandescent.smoothJoin=0.01;
    incandescent.glass=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.99);
    
  //  incandescent.glass.emitColor=vec3(0.02,0.01,0.);
}




//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(Vector tv, inout localData dat){

    float dist=maxDist;
    
    
    
    //------LIGHTS
    
    dist=min(dist,sphereSDF(tv,light1,dat));
    
    dist=min(dist,sphereSDF(tv,light2,dat));
    
    // dist=min(dist,sphereSDF(tv,light3,dat));
    
    // dist=min(dist,sphereSDF(tv,light4,dat));

    
    
    
    //------BALLS
    
    //dist=min(dist,sphereSDF(tv,ball1,dat));
    
    // dist=min(dist,sphereSDF(tv,ball2,dat));
    
    // dist=min(dist,sphereSDF(tv,ball3,dat));
    
    
    
    
    
    //------WALLS
    
    dist=min(dist,planeSDF(tv,wall1,dat));
    
    dist=min(dist,planeSDF(tv,wall2,dat));
   
     dist=min(dist,planeSDF(tv,wall3,dat));
   

    
    
    
    //------CYLINDERS
    
    //dist=min(dist,cylinderSDF(tv,cyl1,dat));
    
  
    
    
    //-------BOTTLES
    
    //dist=min(dist,bottleSDF(tv,bottle,dat));
    
    dist=min(dist,liquorBottleSDF(tv,gin,dat));
//    
//    dist=min(dist,liquorBottleSDF(tv,campari,dat));
//    
//    dist=min(dist,liquorBottleSDF(tv,violet,dat));
//    
//    dist=min(dist,liquorBottleSDF(tv,limoncello,dat));
//    
    //sprinkle in vermouth bottles
//    vermouth.glass.center.coords=vec3(1,1.15,-8);
//    dist=min(dist,liquorBottleSDF(tv,vermouth,dat));
//    
//    
//    vermouth.glass.center.coords=vec3(9,1.15,-12);
//    dist=min(dist,liquorBottleSDF(tv,vermouth,dat));
//    
//     vermouth.glass.center.coords=vec3(-2,1.15,-9);
//    dist=min(dist,liquorBottleSDF(tv,vermouth,dat));
//    
//         vermouth.glass.center.coords=vec3(-4,1.15,-6);
//    dist=min(dist,liquorBottleSDF(tv,vermouth,dat));
//    
//    
        
    //-------COCKTAILS
    
   // dist=min(dist,cocktailGlassSDF(tv,cGlass,dat));
    
    negroni.glass.center.coords=vec3(-1,-0.5,-5);
   // dist=min(dist,cocktailSDF(tv,negroni,dat));
    
   negroni.glass.center.coords+=vec3(3,0,2);
    dist=min(dist,cocktailSDF(tv,negroni,dat));
// 
//    shotglass.glass.center.coords=vec3(10,-0.5,-3);
//    shotglass.drink.absorbColor=vec3(0.1,0.8,0.1);
//    dist=min(dist,cocktailSDF(tv,shotglass,dat));   
//    
//    shotglass.glass.center.coords=vec3(11,-.5,-5);
//    shotglass.drink.absorbColor=0.8*vec3(0.1,0.05,0.);
//    dist=min(dist,cocktailSDF(tv,shotglass,dat));   
//    
    
    
        dist=min(dist,lightBulbSDF(tv,incandescent,dat));
    
    
    
    return dist;
}




