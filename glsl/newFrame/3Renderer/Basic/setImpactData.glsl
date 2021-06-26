void setObjectInAir(inout localData dat, bool inside, Vector normal, Material mat){

    //set the material
    dat.renderMaterial=mat.render;
    dat.isSky=false;
    dat.surfDiffuse=mat.diffuseColor;
    dat.surfSpecular=mat.specularColor;
    dat.surfEmit=mat.emitColor;
    dat.surfRoughness=mat.roughness;
    dat.probDiffuse=1.-mat.specularChance-mat.refractionChance;
    dat.probSpecular=mat.specularChance;
    dat.probRefract=mat.refractionChance;

    if(inside){
        //we are inside
        dat.normal=negate(normal);
        //IOR is current/enteing
        dat.IOR=mat.IOR/1.;
        dat.reflectAbsorb=mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
        dat.subSurface=false;
    }

    else{
        //we are outside
        dat.normal=normal;
        //IOR is current/enteing
        dat.IOR=1./mat.IOR;
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=mat.absorbColor;
        dat.subSurface=mat.subSurface;
    }

}



//if you hit an object which is not part of a compound, one side is the object (material) and the other side is air
//set your local data appropriately
void setObjectInAir(inout localData dat, float side, Vector normal, Material mat){

    //set the material
    dat.renderMaterial=mat.render;
    dat.isSky=false;
    dat.surfDiffuse=mat.diffuseColor;
    dat.surfSpecular=mat.specularColor;
    dat.surfEmit=mat.emitColor;
    dat.surfRoughness=mat.roughness;
    dat.probDiffuse=1.-mat.specularChance-mat.refractionChance;
    dat.probSpecular=mat.specularChance;
    dat.probRefract=mat.refractionChance;

    if(side<0.){
        //we are inside
        dat.normal=negate(normal);
        //IOR is current/enteing
        dat.IOR=mat.IOR/1.;
        dat.reflectAbsorb=mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
        dat.subSurface=false;
    }

    else{
        //we are outside
        dat.normal=normal;
        //IOR is current/enteing
        dat.IOR=1./mat.IOR;
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=mat.absorbColor;
        dat.subSurface=mat.subSurface;
    }

}



void setSurfaceInMat(inout localData dat, float side, Vector normal, Material surf,Material mat){

    //set the material
    dat.renderMaterial=surf.render;
    dat.isSky=false;
    dat.surfEmit=surf.emitColor;
    dat.surfRoughness=surf.roughness;
    dat.probDiffuse=1.-surf.specularChance-surf.refractionChance;
    dat.probSpecular=surf.specularChance;
    dat.probRefract=surf.refractionChance;

    //both sides of surface leave to same ambient material
    dat.reflectAbsorb=mat.absorbColor;
    dat.refractAbsorb=mat.absorbColor;
    dat.IOR=1.;
    dat.subSurface=false;

    if(side<0.){
        //we are inside
        dat.normal=negate(normal);
        dat.surfDiffuse=surf.diffuseColorBack;
        dat.surfSpecular=surf.specularColorBack;
    }

    else{
        //we are outside
        dat.normal=normal;
        dat.surfDiffuse=surf.diffuseColor;
        dat.surfSpecular=surf.specularColor;
    }

}


