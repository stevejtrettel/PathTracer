
Bottle bottle, bottle2;
LiquorBottle gin,campari,vermouth;
DonutBottle donut;
LayerDonutBottle layerDonut;



void buildBottles(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);

    //-------- BOTTLE ----------------

    bottle.baseHeight=1.25;
    bottle.baseRadius=1.;
    bottle.neckHeight=1.;
    bottle.neckRadius=0.3;
    bottle.thickness=0.02;
    bottle.rounded=0.1;
    bottle.smoothJoin=0.3;
    bottle.center=vec3(2,0.48,1);
    bottle.bump=0.5;
    bottle.mat=makeGlass(0.1*vec3(0.3,0.05,0.08),1.5,0.99);

    bottle.mat.diffuseColor=vec3(0.8);
    bottle.mat.absorbColor=vec3(0.2,0.2,0.05);
    bottle.mat.refractionChance=0.;
    bottle.mat.subSurface=true;
    bottle.mat.meanFreePath=0.05;
    bottle.mat.roughness=0.5;

    //set up the bounding sphere
    bottle.boundingBox.center=bottle.center;
    bottle.boundingBox.radius=bottle.baseHeight+bottle.neckHeight+0.5;



    //-------- BOTTLE ----------------

    bottle2.baseHeight=1.35;
    bottle2.baseRadius=0.5;
    bottle2.neckHeight=0.5;
    bottle2.neckRadius=0.2;
    bottle2.thickness=0.05;
    bottle2.rounded=0.1;
    bottle2.smoothJoin=0.3;
    bottle2.center=vec3(1,0.35,-2);
    bottle2.bump=0.;
    bottle2.mat=makeGlass(0.1*vec3(0.3,0.05,0.08),1.5,0.99);


    //-------- GIN BOTTLE ----------------
    gin.glass=bottle;
    gin.glass.baseRadius=1.25;
    gin.glass.baseHeight=1.5;
    gin.glass.thickness=0.1;
    gin.cup=makeGlass(0.5*vec3(0.3,0.05,0.08),1.5,0.92);
    gin.drink=makeGlass(vec3(0.1,0.05,0.),1.3,0.99);
    //makeGlass(0.3*vec3(0.1,0.05,0.),1.3,0.99);
    gin.fill=0.6;
    gin.glass.bump=1.;



    //    //-------- CAMPARI BOTTLE ----------------
    //
    campari.glass=bottle;
    campari.glass.center=vec3(3,2.4,-6);
    campari.glass.baseRadius=1.;
    campari.glass.baseHeight=3.5;
    campari.glass.neckHeight=0.75;
    campari.glass.smoothJoin=0.5;
    campari.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
    campari.drink=makeGlass(2.5*redAbsorb,1.3,0.99);
    campari.fill=0.5;
    campari.glass.bump=0.;


    //-------- VERMOUTH BOTTLE ----------------
    vermouth.glass=bottle;
    vermouth.glass.center=vec3(5,1.32,-3);
    vermouth.glass.baseRadius=0.75;
    vermouth.glass.baseHeight=2.5;
    vermouth.glass.thickness=0.05;
    vermouth.glass.neckHeight=2.25;
    vermouth.glass.smoothJoin=1.5;
    vermouth.cup=makeGlass(0.5*vec3(0.3,0.05,0.08),1.5,0.92);
    vermouth.drink=makeGlass(vec3(0.1,0.05,0.),1.3,0.99);
    //makeGlass(0.3*vec3(0.1,0.05,0.),1.3,0.99);
    vermouth.fill=0.6;
    vermouth.drink=makeGlass(5.*brownAbsorb,1.3,0.99);
    vermouth.glass.bump=1.;






    //----------- TORUS BOTTLE -------------------------
    donut.center=vec3(0,1.,0);
    donut.inner=1.2;
    donut.outer=2.;
    donut.height=2.5;
    donut.base=0.3;
    donut.flare=6.;
    donut.smoothing = 2.75;
    donut.thickness = 0.08;


    donut.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.6,0.99);
    //donut.mat.diffuseColor=0.6*(vec3(1.)-4.*vec3(0.2,0.03,0.0));
    donut.mat.absorbColor= 4.*0.01*vec3(0.2,0.04,0.0);
    donut.mat.emitColor= extra*vec3(0.5,0.1,0.0);
    donut.mat.surfaceEmit=0.5*extra2*vec3(0.3,0.3,0.0);
    donut.mat.specularChance=0.05;
    donut.mat.specularColor=vec3(1.)-donut.mat.absorbColor/3.;
    donut.mat.refractionChance=0.0;
    donut.mat.subSurface=true;
    donut.mat.meanFreePath=0.02;
    donut.mat.isotropicScatter=extra3;
    donut.mat.roughness=0.0;







    layerDonut.inner=donut;
    layerDonut.outer=donut;

    layerDonut.outer.thickness=0.3;
    layerDonut.outer.mat=makeGlass(vec3(0.),1.4);
    layerDonut.outer.mat.specularChance=0.05;

    // zeroMat(layerDonut.outer.mat);
    // layerDonut.outer.mat=makeGlass(vec3(1.),1.5);
    // layerDonut.outer.mat.subSurface=false;
    //layerDonut.outer.thickness=0.2;





}