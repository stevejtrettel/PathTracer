


//if you hit an object which is not part of a compound, one side is the object (material) and the other side is air
//set your local data appropriately
void setObjectInAir(inout localData dat, float dist, Vector normal, Material mat){

    //set the material
    dat.isSky=false;
    dat.mat=mat;

    if(dist<0.){
        //normal is inwward pointing;
        dat.normal=negate(normal);
        //IOR is current/enteing
        dat.IOR=mat.IOR/1.;

        dat.reflectAbsorb=mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
    }

    else{
        //normal is outward pointing;
        dat.normal=normal;
        //IOR is current/enteing
        dat.IOR=1./mat.IOR;

        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=mat.absorbColor;

    }

}







//-------------------------------------------------
// The NEW FUNCTIONS
//-------------------------------------------------


void updateFromVolume(inout Path path){
    path.light *= exp(-path.absorb*path.distance);
}


void updateFromSurface(inout Path path){
    // add in emissive lighting
    path.pixel += path.light*path.dat.mat.emitColor ;

    // update the colorMultiplier
    //only do if not refractive (those taken care of with volume)
    if(path.type.refract==0.){
        //color choice depends on specular or diffuse
        path.light *= (path.type.specular==1.)?path.dat.mat.specularColor:path.dat.mat.diffuseColor;
    }
}



void updateFromSky(inout Path path){
    //vec3 skyColor=skyTex(path.tv.dir);
    vec3 skyColor=vec3(0.5);
    path.pixel +=path.light*skyColor;
    path.keepGoing=false;
}



void focusCheck(inout Path path){
    if(abs(path.distance-focalLength)<0.5&&focusHelp){
        path.pixel+=vec3(1.,0.,0.);
    }
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



