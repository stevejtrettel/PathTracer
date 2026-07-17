//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/cocktailGlass.glsl
#include ../../../glsl/objects/multiMaterial/cocktail.glsl

//set the names of objects contained in the scene
CocktailGlass cGlass;
Cocktail negroni;


void buildObjects(){

    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 clearGlass = vec3(0.3,0.05,0.05);

    cGlass.frame=makeFrame(vec3(-1.,-0.15,-1.2));
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    //note: the Cocktail object only reads .cup/.drink; glass.mat is unused by the library
    cGlass.mat=makeGlass(0.1*clearGlass,1.5,0.99);

    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

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
    dist=min( dist, sdf(tv, negroni) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, negroni);
}



