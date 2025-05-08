//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/CocktailGlass.glsl
#include ../../../glsl/objects/shapes/Bottle.glsl
#include ../../../glsl/objects/multiMaterial/Cocktail.glsl
#include ../../../glsl/objects/multiMaterial/BottleLiquid.glsl


//set the names of objects contained in the scene
CocktailGlass cGlass;
Cocktail negroni;
Bottle bottle;
BottleLiquid gin,campari,vermouth;

void buildObjects(){

    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 clearGlass = vec3(0.3,0.05,0.05);

    //-------- BASE COCKTAIL GLASS  ----------------
    cGlass.center=vec3(-1.,-0.15,-1.2);
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*clearGlass,1.5,1.);

    //--------  NEGRONI  ----------------
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);




    //-------- BASE BOTTLE ----------------
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

    //set up the bounding sphere
    bottle.boundingBox.center=bottle.center;
    bottle.boundingBox.radius=bottle.baseHeight+bottle.neckHeight+0.5;


    //-------- GIN BOTTLE ----------------
    gin.glass=bottle;
    gin.glass.baseRadius=1.25;
    gin.glass.baseHeight=1.5;
    gin.glass.thickness=0.1;
    gin.cup=makeGlass(0.5*vec3(0.3,0.05,0.08),1.5,0.92);
    gin.drink=makeGlass(vec3(0.1,0.05,0.),1.3,0.99);
    gin.fill=0.6;
    gin.glass.bump=1.;



     //-------- CAMPARI BOTTLE ----------------
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
    return dist;
}

//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

    float dist=maxDist;
    dist=min( dist, sdf(tv, negroni) );
    dist=min( dist, sdf(tv, gin) );
    dist=min( dist, sdf(tv, campari) );
    dist=min( dist, sdf(tv, vermouth) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, negroni);
    setData(path, gin);
    setData(path, campari);
    setData(path, vermouth);
}



