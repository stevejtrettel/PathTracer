//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Variety var;
GlassVariety gVar;

void buildObjects(){

    vec3 pinkScatter = vec3(0.25,0.65,0.7);

    var.center=vec3(-2,1.5,-2);
    var.size=2.;
    var.inside=0.0075;
    var.outside=0.00;
    var.boundingSphere=2.;
    var.smoothing =0.15;

    var.mat=makeGlass(30.*pinkScatter,1.5,0.99);
    var.mat.refractionChance=0.;
    var.mat.subSurface=true;
    var.mat.meanFreePath=0.2*extra2;
    var.mat.isotropicScatter=extra;
    var.mat.roughness=0.7;

    Material glassMat = makeGlass(0.25*vec3(0.3,0.05,0.2),1.1,0.99);
    float glassThickness=0.05;
    gVar = createGlassVariety(var,glassMat,glassThickness);

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
    dist=min( dist, sdf(tv, gVar) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return inside(tv, gVar.surf);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, gVar);
}



