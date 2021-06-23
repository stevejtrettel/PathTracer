


//if you hit an object which is not part of a compound, one side is the object (material) and the other side is air
//set your local data appropriately
void setObjectInAir(inout localData dat, float side, Vector normal, Material mat){

    //set the material
    dat.isSky=false;
    dat.materialInterface=false;

    dat.distanceTraveled=distance;
    dat.surfaceColor=mat.diffuseColor;

    if(side<0.){
        //normal is inwward pointing;
        path.dat.normal=negate(normal);
        //IOR is current/enteing
        path.dat.IOR=mat.IOR/1.;

        path.dat.reflectAbsorb=mat.absorbColor;
        path.dat.refractAbsorb=vec3(0.);
    }

    else{
        //normal is outward pointing;
        path.dat.normal=normal;
        //IOR is current/enteing
        path.dat.IOR=1./mat.IOR;

        path.dat.reflectAbsorb=vec3(0.);
        path.dat.refractAbsorb=mat.absorbColor;

    }

}





void initializeData(localData dat){
    dat.isSky=false;
    dat.isLight=false;
    dat.materialInterface=false;

    dat.distanceTraveled=0.;
    dat.surfaceColor=vec3(0.);
    dat.surfaceEmit=vec3(0.);
    dat.currentAbsorb=vec3(0.);
    dat.currentEmit=vec3(0.);
    dat.neighborAbsorb=vec3(0.);
    dat.neighborEmit=vec3(0.);
    dat.IOR=1.;
    dat.reflectionChance=0.;
    dat.refractionChance=1.;
    dat.diffuseChance=0.;
}




















//-------------------------------------------------
// The LIGHTING FUNCTIONS
//-------------------------------------------------

void volumeColor(inout Path path){
    path.light *= exp(-path.absorb*path.distance);
}




void surfaceColor(inout Path path){

    // add in emissive lighting
    path.pixel += path.light*path.dat.mat.emitColor ;

    // update the colorMultiplier
    //only do if not refractive (those taken care of with volume)
    //if(!path.type.refract){
        //color choice depends on specular or diffuse
        path.light *= path.type.specular?path.dat.mat.specularColor:path.dat.mat.diffuseColor;
  //  }

}


void skyColor(inout Path path){
    vec3 skyColor=skyTex(path.tv.dir);
    //vec3 skyColor=0.1*checkerTex(path.tv.dir);
    //vec3 skyColor=vec3(0.05);
    path.pixel +=path.light*skyColor;
}


//-------------------------------------------------
// The FOCUS CHECK
//-------------------------------------------------

void focusCheck(inout Path path){

    if(abs(path.distance-focalLength)<0.5){
        path.pixel+=vec3(1.,0.,0.);
    }

}

