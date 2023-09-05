//-------------------------------------------------
// OBJECTS OF THE SCENE
// describes the SDF / tracing function for the objects of the scene
//-------------------------------------------------




//-------------------------------------------------
//Defining the Objects
//-------------------------------------------------


//set the names of global variables for the walls here:
Sphere ball1, ball2, ball3;
Bottle bottle, bottle2;
CocktailGlass cGlass;
Cocktail negroni;
LiquorBottle gin,campari;
Pint pint;
Beer beer;
Cone cone,cone2,cone3;
Box table;
Box box;
Bunny bunny;
Gasket gasket;
Torus torus;
DonutBottle donut;
LayerDonutBottle layerDonut;
Kleinian klein;
Variety var;
GlassVariety gVar;
GlassMarble marble;

//this function constructs the objects
void buildObjects(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);

    //----------- BALL 1 -------------------------
    ball1.center=vec3(1,0.3,-2);
    ball1.radius=1.3;

    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;
    ball1.mat= makeMetal(color,specularity,roughness);

    //----------- BALL 2 -------------------------
    ball2.center=vec3(0,-0.5,2);
    ball2.radius=0.55;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    ball2.mat=makeDielectric(color,specularity,roughness);


    //----------- BALL 3 -------------------------
    ball3.center=vec3(0);
    //vec3(1.5,0.6,2);
    ball3.radius=6.6;

    color= 0.1*vec3(0.7,0.1,0.2);
    specularity=0.4;
    roughness=0.1;
    //ball3.mat=makeMetal(color,specularity,roughness);
    ball3.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.5);

    //----------- TABLE  -------------------------
    table.center=vec3(2.,-1.85,0);
    table.sides=vec3(15,0.5,10);
    table.rounded=0.1;

    color= vec3(0.1);
    specularity=0.05;
    roughness=0.2;
    table.mat=makeMetal(color,specularity,roughness);



    //-------- BOTTLE ----------------

    bottle.baseHeight=1.25;
    bottle.baseRadius=1.;
    bottle.neckHeight=1.;
    bottle.neckRadius=0.3;
    bottle.thickness=0.02;
    bottle.rounded=0.1;
    bottle.smoothJoin=0.3;
    bottle.center=vec3(2,0.45,1);
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

    bottle2.mat.diffuseColor=0.3*vec3(0.5,0.5,0.9);
    //0.7*vec3(0.3,0.2,0.6);
    bottle2.mat.absorbColor=2.*vec3(0.5,0.5,0.0);
    bottle2.mat.refractionChance=0.;
    bottle2.mat.subSurface=true;
    bottle2.mat.meanFreePath=0.01;
    bottle2.mat.isotropicScatter=0.5;
    bottle2.mat.roughness=0.2;





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
//    campari.glass=bottle;
//    campari.glass.center.coords=vec3(3,2.25,-9);
//    campari.glass.baseRadius=1.;
//    campari.glass.baseHeight=3.5;
//    campari.glass.neckHeight=0.75;
//    campari.glass.smoothJoin=0.5;
//    campari.cup=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);
//    campari.drink=makeGlass(2.5*redAbsorb,1.3,0.99);
//    campari.fill=0.5;
//    campari.glass.bump=0.;
//
//
//
//
    //-------- COCKTAIL GLASS----------------

    cGlass.center=vec3(-1.,-0.15,-1.2);
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    //-------- NEGRONI ----------------
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

//    negroni.drink=makeGlass(vec3(0.),1.2,0.99);
//    negroni.drink.refractionChance=0.0;
//    negroni.drink.subSurface=true;
//    negroni.drink.meanFreePath=0.1;
//    negroni.drink.roughness=0.4;

    //----------PINT GLASS----------
    pint.center=vec3(-1,1.2,-2);
    pint.height=2.;
    pint.base=0.5;
    pint.flare=1.5;
    pint.thickness=0.03;
    pint.rounded=0.;
    pint.mat=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);

    //-------- BEER ----------------
    beer.glass=pint;
    beer.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);


    //    negroni.drink.diffuseColor=vec3(1.);
    //    negroni.drink.absorbColor=vec3(0.);
    //    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    //    negroni.drink.refractionChance=0.;
    //    negroni.drink.subSurface=true;
    //    negroni.drink.meanFreePath=0.05;
    //    negroni.drink.roughness=1.;

    beer.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    //0.5*vec3(0.02,0.02,0.06)
    //beer.drink.refractionChance=0.0;
    //beer.drink.subSurface=true;
    //beer.drink.meanFreePath=0.4;
    //beer.drink.roughness=0.5;


//    beer.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
//
//    beer.drink.diffuseColor=vec3(1);
//    beer.drink.absorbColor=vec3(0);
//    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
//    beer.drink.refractionChance=0.;
//    beer.drink.subSurface=true;
//    beer.drink.meanFreePath=0.1;
//    beer.drink.roughness=0.9;



    bunny.center=vec3(0,-0.12,0);
    bunny.scale=2.;
    bunny.mat=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);

        bunny.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.9);

        bunny.mat.diffuseColor=vec3(1);
        bunny.mat.absorbColor=vec3(0.1);
        //vec3(1)-0.9*vec3(0,0.65,0.35);
        bunny.mat.emitColor =  0.4*extra2*vec3(1.,0.15,0.);
        bunny.mat.surfaceEmit =  0.1*extra3*vec3(0.75,0.25,0.);
        //vec3(0.01);
        //vec3(1)-0.9*vec3(0.3,0.2,0.6);
        bunny.mat.refractionChance=0.;
        bunny.mat.subSurface=true;
        bunny.mat.meanFreePath=0.2;
        bunny.mat.isotropicScatter=extra;
        bunny.mat.roughness=0.0;



    //----------- GASKET -------------------------
    gasket.center=vec3(0,1.8,0);
    gasket.radius=1.;

    color= vec3(0.4,0.3,0.2);
    specularity=0.5;
    roughness=0.01;
    gasket.mat= makeMetal(color,specularity,roughness);
   // makeDielectric(color,specularity,roughness);
  //  gasket.mat.surfaceEmit=0.1*vec3(0.02,0.02,0.04);

  //  gasket.mat=makeGlass(vec3(1)-0.9*vec3(0,0.65,0.35),1.2,0.8);



    //----------- BOX  -------------------------
    box.center=vec3(0.,-2.75,0.);
    box.sides=vec3(3,0.25,3);
    box.rounded=0.1;

    color= 0.25*vec3(0.4,0.3,0.2);
    specularity=0.5;
    roughness=0.01;

    zeroMat(box.mat);
    box.mat = makeMetal(color,specularity,roughness);
  //  box.mat = makeGlass(0.5*vec3(0.3,0.05,0.2),1.75,0.95);





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



    klein.center=vec3(-2,0,-3);
    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    //klein.mat=makeDielectric(color,specularity,roughness);

    klein.mat=makeGlass(3.*vec3(0.3,0.05,0.2),1.5,0.95);

    //klein.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

   // klein.mat.diffuseColor=vec3(1);
    //klein.mat.absorbColor=vec3(0.1);
    //vec3(1)-0.9*vec3(0,0.65,0.35);
    //klein.mat.emitColor =  0.4*extra2*vec3(1.,0.15,0.);
    //klein.mat.surfaceEmit =  0.1*extra3*vec3(0.75,0.25,0.);
    //vec3(0.01);
    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    klein.mat.refractionChance=0.;
    klein.mat.subSurface=true;
    klein.mat.meanFreePath=0.5*extra2;
    klein.mat.isotropicScatter=extra;
    klein.mat.roughness=0.04;

    var.center=vec3(0,0.5,0);
    var.size=5.;
    var.inside=0.01;
    var.outside=0.0;
    var.boundingSphere=2.;
    var.smoothing =0.0;

    color= vec3(0.4,0.3,0.2);
    specularity=0.5;
    roughness=0.01;
    //var.mat= makeMetal(color,specularity,roughness);

    var.mat=makeGlass(10.*vec3(0.3,0.05,0.2),1.5,0.95);
    //var.mat=makeGlass(5.*vec3(0.7,0.9,0.9),1.6,0.95);
    var.mat.refractionChance=0.;
    var.mat.subSurface=true;
    var.mat.meanFreePath=0.5*extra2;
    var.mat.isotropicScatter=extra;
    var.mat.roughness=0.4;

    Material glassMat = makeGlass(0.1*vec3(0.3,0.05,0.2),1.3,0.95);
    gVar = createGlassVariety(var,glassMat,0.05);

    Material outerVarMat = makeGlass(5.*vec3(0.05,0.5,0.05),1.4,0.95);

    marble = createGlassMarble(var,outerVarMat, glassMat);
}




















//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------

bool render_Objects=true;



//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------


//copy as many lines of dist=min(dist, trace(tv, NEW_OBJ)), one for each object to be traced
float trace_Objects( Vector tv ){

    float dist=maxDist;

//    dist=min(dist, trace(tv, ball1));

    return dist;

}




//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

   float dist=maxDist;

    dist=min( dist, sdf(tv, var) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
//so, in a multi-material object just put the parts that subsurface scatter.
//PROBLEM: RIGHT NOW DON'T NECESSARILY HAVE A GOOD WAY TO HAVE TWO SCATTERING MATERIALS IN CONTACT?
bool inside_Object( Vector tv ){


    return inside(tv, var);


}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){

    setData(path, var);

}



