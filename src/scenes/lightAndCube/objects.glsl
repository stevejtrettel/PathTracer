//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

Sphere EH;
Box box;
Bunny bunny;

void buildObjects(){

    box.center = vec3(5,-2,3);
    box.sides = vec3(2.);

    vec3 color= vec3(0.9,0.9,0.5);
    float specularity=0.5;
    float roughness=0.2;
    box.mat= makeMetal(color,specularity,roughness);

    vec3 pinkScatter = vec3(0.25,0.65,0.7);
    vec3 greenGlass = vec3(0.3,0.05,0.2);

    bunny.center=vec3(5,-2,3);
    bunny.scale=2.;

    bunny.mat=makeGlass(greenGlass,1.5,0.95);

    bunny.mat.refractionChance=0.;
    bunny.mat.subSurface=true;
    bunny.mat.meanFreePath=0.5*extra2;
    bunny.mat.isotropicScatter=extra;
    bunny.mat.roughness=0.0;

    //make the bunny glow
    bunny.mat.diffuseColor=vec3(1);
    bunny.mat.absorbColor=vec3(0.1);
    bunny.mat.emitColor =  1.*extra2*vec3(1.,0.15,0.);
    bunny.mat.surfaceEmit =  1.*extra3*vec3(0.75,0.25,0.);

}



//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------
bool render_Objects=true;


//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

    float dist=maxDist;
    dist=min( dist, sdf(tv, bunny) );
    return dist;

}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
   // return false;
    return inside(tv,bunny);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){

    setData(path, bunny);
    if(length(path.tv.pos)<1.){
        path.keepGoing=false;
        path.light=vec3(0);
        path.pixel=vec3(0);
    }
}



