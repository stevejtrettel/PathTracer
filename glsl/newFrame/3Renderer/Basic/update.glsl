


//if you hit an object which is not part of a compound, one side is the object (material) and the other side is air
//set your local data appropriately
void setObjectInAir(inout localData dat, float side, Vector normal, Material mat){

    //set the material
    dat.isSky=false;
    dat.surfDiffuse=mat.diffuseColor;
    dat.surfEmit=mat.emitColor;
    dat.probDiffuse=1.-mat.specularChance;
    dat.probSpecular=mat.specularChance;

    if(side<0.){
        //we are inside
        dat.normal=negate(normal);
//        //IOR is current/enteing
//        dat.IOR=mat.IOR/1.;
    }

    else{
        //normal is outward pointing;
        dat.normal=normal;
//        //IOR is current/enteing
//        dat.IOR=1./mat.IOR;
    }

}







//-------------------------------------------------
// The NEW FUNCTIONS
//-------------------------------------------------


void updateFromVolume(inout Path path){
   // path.light *= exp(-path.absorb*path.distance);
}


void updateFromSurface(inout Path path){

    //add in emissive lighting
    path.pixel += path.light * path.dat.surfEmit;

    //only do if not a refracive path
    path.light *= path.dat.surfDiffuse;
    //path.light *= (path.type.specular)?path.dat.mat.specularColor:path.dat.mat.diffuseColor;

}



void updateFromSky(inout Path path){
    if(path.dat.isSky){
        vec3 skyColor = skyTex(path.tv.dir);
        //vec3 skyColor=vec3(0.5);
        path.pixel += path.light*skyColor;
        path.keepGoing = false;
    }
}



void focusCheck(inout Path path){
//    if(abs(path.distance-focalLength)<0.5&&focusHelp){
//        path.pixel+=vec3(1.,0.,0.);
//    }
}



void roulette(inout Path path){

    // As the light left gets smaller, the ray is more likely to get terminated early.
    // Survivors have their value boosted to make up for fewer samples being in the average.

    float p = L1_Norm(path.light);
    if (randomFloat() > p){
        path.keepGoing=false;
    }
    // Add the energy we 'lose' by randomly terminating paths
    path.light *= 1.0f / p;
}



