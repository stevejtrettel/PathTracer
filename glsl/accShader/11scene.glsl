
//-------------------------------------------------
//The OBJECTS
//-------------------------------------------------


//global variables which are the names of the possible objects in the scene
Sphere light1;
Sphere light2;
Sphere light3;
Sphere light4;
Cylinder light5;
Cylinder light6;

Sphere ball1;
Sphere ball2;
Sphere ball3;

Plane wall1;
Plane wall2;
Plane wall3;
Plane wall4;
Plane wall5;



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


LightBulb bulb1;
LightBulb bulb2;
LightBulb bulb3;

Cylinder cord;
Cylinder cord2;

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
    
    color=vec3(255./255., 147./255., 41./255.);
       // vec3(1.,0.6,0.4);
    intensity=5.;
    
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

    
     //----------- FILAMENT LIGHT-------------------------
    
    light5.center=Point(vec3(6,1,6));
    light5.radius=0.1;
    light5.height=1.;
    light5.rounded=0.1;
    
     color= vec3(255./255., 147./255., 41./255.);
    //color=vec3(0.7,0.7,0.8);
    specularity=0.5;
    roughness=0.5;
    
    
    light5.mat=makeDielectric(color,specularity,roughness);

    color= (vec3(1.)+vec3(255./255., 147./255., 41./255.))/2.;
       // vec3(1.,0.6,0.4);
    intensity=50.;
    
    light5.mat.emitColor=color*intensity;
    
    
    
              
     //----------- FILAMENT LIGHT-------------------------
    
    light6.center=Point(vec3(10,2,-2));
    light6.radius=0.1;
    light6.height=1.;
    light6.rounded=0.1;
    
     color= vec3(255./255., 147./255., 41./255.);
    //color=vec3(0.7,0.7,0.8);
    specularity=0.5;
    roughness=0.5;
    
    
    light6.mat=makeDielectric(color,specularity,roughness);

    color= (vec3(1.)+vec3(255./255., 147./255., 41./255.))/2.;
       // vec3(1.,0.6,0.4);
    intensity=100.;
    
    light6.mat.emitColor=color*intensity;
    
    
    
    
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
    
    color= vec3(255./255.,86./255.,47./255.);
    //0.7*vec3(0.3,0.2,0.6);
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

    ball3.mat=makeGlass(1.*vec3(0.3,0.05,0.2),1.3);
    
    
    
    
    
    
    
    
    
    
    //----------- WALL 1 -------------------------
    normal=vec3(0,1,0);
    offset=1.6;
    
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
    bottle.thickness=0.1;
    bottle.rounded=0.2;
    bottle.smoothJoin=0.3;
    bottle.center=Point(vec3(6,0.2,-4.5));
    bottle.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
    bottle.bump=1.;

    
    
    
    
    //-------- DRINK COLORS -----------------
    
        vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));

        vec3 redAbsorb=vec3(0.2,1.,0.6);
    
        //vec3 purpleAbsorb=vec3(0.1,0.8,0.1);
    
    
    
    
    //-------- GIN BOTTLE ----------------
   
    gin.glass=bottle;
    gin.glass.center.coords=vec3(6,0.2,-4.5);
    gin.glass.baseRadius=1.25;
    gin.glass.baseHeight=1.5;
    gin.glass.thickness=0.1;
    gin.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
    gin.drink=makeGlass(0.3*vec3(0.1,0.05,0.),1.3,0.99);
    gin.fill=0.;
    gin.glass.bump=1.;
    
//    
//    gin2=gin;
//    gin2.glass.center.coords=vec3(7,0.2,-8);
//    
//    
//    
        
    //-------- CAMPARI BOTTLE ----------------
   
    campari.glass=bottle;
    campari.glass.center.coords=vec3(3,2.25,-9);
    campari.glass.baseRadius=1.;
    campari.glass.baseHeight=3.5;
    campari.glass.neckHeight=0.75;
    campari.glass.smoothJoin=0.5;
    campari.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
    campari.drink=makeGlass(2.5*redAbsorb,1.3,0.99);
    campari.fill=0.5;
    campari.glass.bump=0.;
    
//    //-------- CREME DE VIOLET BOTTLE ----------------
//    violet=campari;
//    violet.glass.center.coords+=vec3(7,0.,2);
//    violet.drink=makeGlass(2.*vec3(0.1,0.8,0.1),1.3,0.99);
//    
//    //-------- LIMONCELLO BOTTLE ----------------
//    limoncello=campari;
//    limoncello.glass.baseHeight-=1.;
//    limoncello.glass.center.coords+=vec3(4,-1,0);
//    limoncello.drink=makeGlass(vec3(0.1,0.1,0.8),1.3,0.99);
//    
//    

    //-------- VERMOUTH BOTTLE ----------------
   
    vermouth.glass=bottle;
    vermouth.glass.center.coords=vec3(8,1.18,-8);
    vermouth.glass.baseRadius=0.6;
    vermouth.glass.baseHeight=2.5;
    vermouth.glass.neckRadius=0.2;
    vermouth.glass.neckHeight=2.;
    vermouth.glass.smoothJoin=1.25;
    vermouth.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
    vermouth.drink=makeGlass(3.*brownAbsorb,1.3,0.99);
    vermouth.fill=0.6;
    vermouth.glass.bump=0.;
    
    //-------- COCKTAIL GLASS----------------
    
    cGlass.center=Point(vec3(2,-0.5,-3));
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    
    //-------- NEGRONI ----------------
   
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.99);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    
    
     //--------SHOTGLASS ----------------
    shotglass.glass=cGlass;
    shotglass.glass.center.coords=vec3(10,-0.5,-3);
    shotglass.glass.radius=0.5;
    shotglass.glass.height=1.;
    shotglass.glass.thickness=0.1;
    shotglass.glass.base=0.4;
    shotglass.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.99);
    shotglass.drink=makeGlass(0.3*vec3(0.15,0.05,0.),1.3,0.99);
    
    
    
    //--------LIGHT BULB ----------------
    
    bulb1.center.coords=vec3(9,4.5,-2);
    bulb1.bulbRadius=1.;
    bulb1.neckRadius=0.5;
    bulb1.neckLength=1.25;
    bulb1.smoothJoin=0.5;
    
    bulb1.filHeight=0.5;
    bulb1.filWidth=0.1;
    bulb1.filRadius=0.05;
    bulb1.filTwisty=20.;
    bulb1.glass=makeGlass(0.1*vec3(0.3,0.025,0.2),1.5,0.99);
    
    bulb1.filament=makeDielectric(color,specularity,roughness);

    color= vec3(255./255., 147./255., 41./255.);
       // vec3(1.,0.6,0.4);
    intensity=300.;
    
    bulb1.filament.emitColor=color*intensity;
    
    
    
        //--------LIGHT BULB ----------------
    
    bulb2.center.coords=vec3(-1,3.5,-6);
    bulb2.bulbRadius=1.75;
    bulb2.neckRadius=0.5;
    bulb2.neckLength=1.25;
    bulb2.smoothJoin=0.5;
    
    bulb2.filHeight=1.2;
    bulb2.filWidth=0.2;
    bulb2.filRadius=0.05;
    bulb2.filTwisty=5.;
    bulb2.glass=makeGlass(0.1*vec3(0.3,0.025,0.2),1.5,0.99);
    
    bulb2.filament=makeDielectric(color,specularity,roughness);

    color= (vec3(1.)+vec3(255./255., 147./255., 41./255.))/2.;
       // vec3(1.,0.6,0.4);
    intensity=500.;
    
    bulb2.filament.emitColor=color*intensity;
    
    
    
    
    //--------LIGHT BULB FILAMENT ----------------
    
    bulb3.center.coords=vec3(6,2,7);
    bulb3.bulbRadius=1.75;
    bulb3.neckRadius=0.5;
    bulb3.neckLength=1.25;
    bulb3.smoothJoin=0.5;
    
    bulb3.filHeight=1.5;
    bulb3.filWidth=0.5;
    bulb3.filRadius=0.2;
    bulb3.filTwisty=7.;
    bulb3.glass=makeGlass(0.1*vec3(0.3,0.025,0.2),1.5,0.99);
    
    bulb3.filament=makeDielectric(color,specularity,roughness);

    color= (vec3(1.)+vec3(255./255., 147./255., 41./255.))/2.;
       // vec3(1.,0.6,0.4);
    intensity=400.;
    
    bulb3.filament.emitColor=color*intensity;
    
    
    
    
    //=====CORD===============
    
    cord.center=Point(vec3(9,6.5,-2));
    
    cord.radius=0.05;
    cord.height=2.5;
    cord.rounded=0.01;
    
    
    color= vec3(0.05);
    specularity=0.05;
    roughness=0.5;

    cord.mat==makeGlass(vec3(0.5),1.5,0.5);

    
    
    
    
    
    
    
    cord2.center=Point(vec3(-1,6.25,-6));
    
    cord2.radius=0.1;
    cord2.height=4.;
    cord2.rounded=0.01;
    
    
    color= vec3(0.05);
    specularity=0.05;
    roughness=0.5;

    cord2.mat==makeGlass(vec3(0.5),1.5,0.5);

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
    
   //  dist=min(dist,sphereSDF(tv,light4,dat));

    
    
    
    //------BALLS
    
//    dist=min(dist,sphereSDF(tv,ball1,dat));
//
//     dist=min(dist,sphereSDF(tv,ball2,dat));
//
//     dist=min(dist,sphereSDF(tv,ball3,dat));
//
//
//
    
    
    //------WALLS
    
   // dist=min(dist,planeSDF(tv,wall1,dat));
    
    dist=min(dist,planeSDF(tv,wall2,dat));
   
   dist=min(dist,planeSDF(tv,wall3,dat));
   

    
    

    
    //-------BOTTLES
//
//    dist=min(dist,liquorBottleSDF(tv,gin,dat));
//
//    dist=min(dist,liquorBottleSDF(tv,campari,dat));
//
//    dist=min(dist,liquorBottleSDF(tv,vermouth,dat));

        
    //-------COCKTAILS

//    dist=min(dist,cocktailSDF(tv,negroni,dat));
//
//    dist=min(dist,cocktailSDF(tv,shotglass,dat));
//
    
    
    //-------LIGHT BULBS
    
//    dist=min(dist,cylinderSDF(tv,cord,dat));
//
//    dist=min(dist,cylinderSDF(tv,cord2,dat));
//
//    dist=min(dist,lightBulbSDF(tv,bulb1,dat));
//
//    dist=min(dist,lightBulbSDF(tv,bulb2,dat));
//
//    dist=min(dist,filamentSDF(tv,bulb3,dat));
//

    
    return dist;
}




