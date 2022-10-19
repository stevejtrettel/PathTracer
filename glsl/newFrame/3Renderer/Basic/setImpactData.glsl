void setObjectInAir(inout localData dat, bool inside, Vector normal, Material mat){

    //set the material
    dat.renderMaterial=mat.render;
    dat.isSky=false;
    dat.surfDiffuse=mat.diffuseColor;
    dat.surfSpecular=mat.specularColor;
    dat.surfEmit=mat.surfaceEmit;
    dat.surfRoughness=mat.roughness;
    dat.probDiffuse=1.-mat.specularChance-mat.refractionChance;
    dat.probSpecular=mat.specularChance;
    dat.probRefract=mat.refractionChance;

    if(inside){
        //we are inside
        dat.normal=negate(normal);
        //IOR is current/enteing
        dat.IOR=mat.IOR/1.;
        dat.reflectEmit = mat.emitColor;
        dat.reflectAbsorb=mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
        dat.refractEmit=vec3(0.);
        dat.subSurface=false;
        dat.meanFreePath=maxDist;
        dat.isotropicScatter=0.;
    }

    else{
        //we are outside
        dat.normal=normal;
        //IOR is current/enteing
        dat.IOR=1./mat.IOR;
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=mat.absorbColor;
        dat.reflectEmit=vec3(0.);
        dat.refractEmit=mat.emitColor;
        dat.subSurface=mat.subSurface;
        dat.meanFreePath=mat.meanFreePath;
        dat.isotropicScatter=mat.isotropicScatter;
    }

}



void setSurfaceInMat(inout localData dat, float side, Vector normal, Material surf,Material mat){

    //set the material
    dat.renderMaterial=surf.render;
    dat.isSky=false;
    dat.surfEmit=surf.surfaceEmit;
    dat.surfRoughness=surf.roughness;
    dat.probDiffuse=1.-surf.specularChance-surf.refractionChance;
    dat.probSpecular=surf.specularChance;
    dat.probRefract=surf.refractionChance;

    //both sides of surface leave to same ambient material
    dat.reflectAbsorb=mat.absorbColor;
    dat.refractAbsorb=mat.absorbColor;
    dat.reflectEmit=mat.emitColor;
    dat.refractEmit=mat.emitColor;
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



//inside of one material, but ran into another
void setMaterialInterface(inout localData dat, Material current, Material neighbor, Material dominant ){

    dat.renderMaterial=true;

    //-----SURFACE PROPERTIES -------------------

    //set probabilities using the DOMINANT MATERIAL
    dat.probSpecular=dominant.specularChance;
    dat.probRefract=dominant.refractionChance;
    dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;

    //set the surface properties of the dominant material
    dat.surfDiffuse=dominant.diffuseColor;
    dat.surfSpecular=dominant.specularColor;
    dat.surfEmit=dominant.surfaceEmit;
    //dat.surfRoughness=dominant.roughness;


    //------VOLUME PROPERTIES------------------------

    //IOR is current/enteing
    dat.IOR=current.IOR/neighbor.IOR;

    //subsurface is set by the entering material, as this is where we would scatter
    dat.subSurface=neighbor.subSurface;
    dat.surfRoughness=neighbor.roughness;
    dat.meanFreePath=neighbor.meanFreePath;
    dat.isotropicScatter=neighbor.isotropicScatter;

    dat.reflectAbsorb=current.absorbColor;
    dat.refractAbsorb=neighbor.absorbColor;

    dat.reflectEmit=current.emitColor;
    dat.refractEmit=neighbor.emitColor;

}


