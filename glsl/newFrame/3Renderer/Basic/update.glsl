


//if you hit an object which is not part of a compound, one side is the object (material) and the other side is air
//set your local data appropriately

void setObjectInAir(inout localData dat, float dist, Vector normal, Material mat){

    //set the material
    dat.isSky=false;
    dat.mat=mat;

    if(side<0.){
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
// The LIGHTING FUNCTIONS
//-------------------------------------------------

void volumeColor(inout Path path,localData dat){
    path.light *= exp(-path.absorb*path.distance);
}




void surfaceColor(inout Path path,localData dat){

    // add in emissive lighting
    path.pixel += path.light*dat.mat.emitColor ;

    // update the colorMultiplier
    //only do if not refractive (those taken care of with volume)
    if(path.type.refract==0.){
        //color choice depends on specular or diffuse
        path.light *= (path.type.specular==1.)?dat.mat.specularColor:dat.mat.diffuseColor;
    }

}


void skyColor(inout Path path,inout localData dat){
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

