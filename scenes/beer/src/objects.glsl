//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/pint.glsl
#include ../../../glsl/objects/multiMaterial/beer.glsl

//set the names of objects contained in the scene
Pint pint;
Beer beer;

void buildObjects(){

    pint.frame=makeFrame(vec3(-1,1.3,-2));
    pint.height=2.;
    pint.base=0.75;
    pint.flare=1.5;
    pint.thickness=0.01;
    pint.rounded=0.;
    pint.mat=makeGlass(0.2*vec3(0.3,0.05,0.2),1.5,0.95);


    beer.glass=pint;
    beer.cup=beer.glass.mat;
    beer.drink=makeGlass(2.5*vec3(0.03,0.15,0.9),1.2,0.99);
    beer.drink.refractionChance=0.;
    beer.drink.subSurface=true;
    beer.drink.meanFreePath=0.1;
    beer.drink.isotropicScatter=0.;
    //alternate: beer.drink.roughness=0.9;

}



//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    return dist;
}

float sdf_Objects( Vector tv ){

    float dist=maxDist;
    dist=min( dist, sdf(tv, beer) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv,beer);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, beer);
}



