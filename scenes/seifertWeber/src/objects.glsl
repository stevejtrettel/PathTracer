//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/shapes/hypDod.glsl
#include ../../../glsl/objects/shapes/hypCoxCube.glsl
#include ../../../glsl/objects/multiMaterial/poincareMarble.glsl


//set the names of objects contained in the scene
HypDod dod,dodE;
PoincareMarble poin;
HypCoxCube cube;


void buildObjects(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);

    dod = buildHypDod();

    dod.mat=makeGlass(6.*(brownAbsorb+0.25*redAbsorb),1.5,0.97);
    dod.frame = makeFrame(vec3(1.5,-0.5,2.25));
    //alternate materials:
    //dod.mat = makeMetal(color,specularity,roughness);
    //    dod.mat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,sssDensity);
    //    dod.mat.refractionChance=0.;
    //    dod.mat.subSurface=true;
    //    dod.mat.meanFreePath=0.5*sssDensity;
    //    dod.mat.isotropicScatter=sssScatter;
    //    dod.mat.roughness=0.04;


    //built but not currently rendered (kept as an alternate)
    dodE = buildHypDod(0.4);
    dodE.frame = makeFrame(vec3(-2,-0.5,2));
    //dod.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    dodE.mat=makeGlass(20.*(0.5*brownAbsorb+0.5*redAbsorb),1.5,0.95);
    dodE.mat.refractionChance=0.;
    dodE.mat.subSurface=true;
    dodE.mat.meanFreePath=0.5*sssDensity;
    dodE.mat.isotropicScatter=sssScatter;
    dodE.mat.roughness=0.04;

    //alternate materials:
    //dod.mat=makeGlass(20.*(0.5*brownAbsorb+0.5*redAbsorb),1.5,0.95);
    //dod.mat.refractionChance=0.;
    //dod.mat.subSurface=true;
    //dod.mat.meanFreePath=0.5*sssDensity;
    //dod.mat.isotropicScatter=sssScatter;
    //dod.mat.roughness=0.04;
    //

    Material dodMat = makeGlass(30.*(brownAbsorb+0.25*redAbsorb),2.5,0.95);
    Material glassMat = makeGlass(0.2*vec3(0.3,0.05,0.2),1.5,0.99);
    poin = createPoincareMarble(dodMat, glassMat);

    //alternate materials:
    //    poin.dod.mat.refractionChance=0.;
    //    poin.dod.mat.subSurface=true;
    //    poin.dod.mat.meanFreePath=0.5*sssDensity;
    //    poin.dod.mat.isotropicScatter=sssScatter;
    //    poin.dod.mat.roughness=0.04;


    //built but not currently rendered (kept as an alternate)
    cube = buildCoxCube(3.);
    //alternate materials:
    //makeMetal(color,specularity,roughness);
    //cube.mat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,sssDensity);
    cube.mat=makeGlass(20.*(vec3(1)-vec3(0.6,0.1,0.5)),1.5,0.95);
    cube.mat.refractionChance=0.;
    cube.mat.subSurface=true;
    cube.mat.meanFreePath=0.5*sssDensity;
    cube.mat.isotropicScatter=sssScatter;
    cube.mat.roughness=0.04;


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
    dist=min( dist, sdf(tv, dod) );
    dist=min( dist, sdf(tv, poin) );
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
    setData(path,poin);
    setData(path, dod);
}

//no curved-light medium in this scene (n === 1 everywhere: straight transport).
//A medium scene overrides this with its effective refractive index field.
float indexField(vec3 p){ return 1.; }
