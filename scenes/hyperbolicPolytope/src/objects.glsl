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
    vec3 whiskey=vec3(0.18,0.43,0.62);

    dod = buildHypDod();

    dod.mat=makeGlass(6.*(brownAbsorb+0.25*redAbsorb),1.5,0.97);
    dod.center = vec3(1.5,-0.5,2.25);
    //dod.mat = makeMetal(color,specularity,roughness);
    //    dod.mat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,extra2);
    //    dod.mat.refractionChance=0.;
    //    dod.mat.subSurface=true;
    //    dod.mat.meanFreePath=0.5*extra2;
    //    dod.mat.isotropicScatter=extra;
    //    dod.mat.roughness=0.04;


    dodE = buildHypDod(0.4);
    dodE.center = vec3(-2,-0.5,2);
    //dod.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    dodE.mat = makeDielectric(vec3(0.5,0.2,0.4),specularity,roughness);
    dodE.mat=makeGlass(20.*(0.5*brownAbsorb+0.5*redAbsorb),1.5,0.95);
    dodE.mat.refractionChance=0.;
    dodE.mat.subSurface=true;
    dodE.mat.meanFreePath=0.5*extra2;
    dodE.mat.isotropicScatter=extra;
    dodE.mat.roughness=0.04;

    //dod.mat=makeGlass(20.*(0.5*brownAbsorb+0.5*redAbsorb),1.5,0.95);
    //dod.mat.refractionChance=0.;
    //dod.mat.subSurface=true;
    //dod.mat.meanFreePath=0.5*extra2;
    //dod.mat.isotropicScatter=extra;
    //dod.mat.roughness=0.04;
    //

    Material dodMat = makeGlass(30.*(brownAbsorb+0.25*redAbsorb),2.5,0.95);
    Material glassMat = makeGlass(0.2*vec3(0.3,0.05,0.2),1.5,0.99);
    poin = createPoincareMarble(dodMat, glassMat);

    //    poin.dod.mat.refractionChance=0.;
    //    poin.dod.mat.subSurface=true;
    //    poin.dod.mat.meanFreePath=0.5*extra2;
    //    poin.dod.mat.isotropicScatter=extra;
    //    poin.dod.mat.roughness=0.04;


    cube = buildCoxCube(3.);
    //makeMetal(color,specularity,roughness);
    //cube5.mat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,extra2);
    cube.mat=makeGlass(20.*(vec3(1)-vec3(0.6,0.1,0.5)),1.5,0.95);
    cube.mat.refractionChance=0.;
    cube.mat.subSurface=true;
    cube.mat.meanFreePath=0.5*extra2;
    cube.mat.isotropicScatter=extra;
    cube.mat.roughness=0.04;


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
    dist=min( dist, sdf(tv, dod) );
    dist=min( dist, sdf(tv, poin) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
    //return inside(tv,bunny);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path,poin);
    setData(path, dod);
}



