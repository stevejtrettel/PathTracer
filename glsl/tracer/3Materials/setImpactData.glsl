void setObjectInAir(inout LocalData dat, bool inside, Vector normal, Material mat){

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
    dat.coat=mat.coat;
    dat.coatRoughness=mat.coatRoughness;
    dat.transmitTint=mat.transmitTint;

    //record the side for later resampling (applyMaterial): -1 inside, +1 outside
    //(same convention as setSurfaceInMat's side argument)
    dat.side = inside ? -1. : 1.;

    if(inside){
        //we are inside
        dat.normal=negate(normal);
        //IOR is current/entering (wavelength-dependent when dispersing; air side = 1)
        dat.IOR=iorAt(mat.IOR)/1.;
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
        //IOR is current/entering (wavelength-dependent when dispersing; air side = 1)
        dat.IOR=1./iorAt(mat.IOR);
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=mat.absorbColor;
        dat.reflectEmit=vec3(0.);
        dat.refractEmit=mat.emitColor;
        dat.subSurface=mat.subSurface;
        dat.meanFreePath=mat.meanFreePath;
        dat.isotropicScatter=mat.isotropicScatter;
    }

}



//-------------------------------------------------
// MATERIAL FIELDS (see docs/material-fields.md)
// re-apply a freshly sampled Material at the current hit, reusing the
// normal/side the standard setData already computed. This is the sanctioned way
// for a scene to make material data vary over a surface: after setData(path,obj),
// sample/override any fields of a Material as a function of position (and, under
// dispersion, waveLength) and hand it here — all the interface bookkeeping
// (two-sidedness, flipped normal, IOR ratio, volume handoff) stays in
// setObjectInAir. Object-in-air hits only; multi-material objects resample
// before their own setMaterialInterface call instead.
//-------------------------------------------------

void applyMaterial(inout Path path, Material mat){
    bool isInside = (path.dat.side < 0.);
    //dat.normal is stored back-facing (flipped when inside); recover the geometric one
    //(if/else, not ?: — GLSL ES has no ternary on struct types)
    Vector geomNormal = path.dat.normal;
    if(isInside){ geomNormal = negate(path.dat.normal); }
    setObjectInAir(path.dat, isInside, geomNormal, mat);
}



void setSurfaceInMat(inout LocalData dat, float side, Vector normal, Material surf,Material mat){

    dat.side=side;

    //set the material
    dat.renderMaterial=surf.render;
    dat.isSky=false;
    dat.surfEmit=surf.surfaceEmit;
    dat.surfRoughness=surf.roughness;
    dat.probDiffuse=1.-surf.specularChance-surf.refractionChance;
    dat.probSpecular=surf.specularChance;
    dat.probRefract=surf.refractionChance;
    dat.coat=surf.coat;
    dat.coatRoughness=surf.coatRoughness;
    dat.transmitTint=surf.transmitTint;

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
void setMaterialInterface(inout LocalData dat, Material current, Material neighbor, Material dominant ){

    dat.renderMaterial=true;

    //-----SURFACE PROPERTIES -------------------

    //set probabilities using the DOMINANT MATERIAL
    dat.probSpecular=dominant.specularChance;
    dat.probRefract=dominant.refractionChance;
    dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;
    dat.coat=dominant.coat;
    dat.coatRoughness=dominant.coatRoughness;
    dat.transmitTint=dominant.transmitTint;

    //set the surface properties of the dominant material
    dat.surfDiffuse=dominant.diffuseColor;
    dat.surfSpecular=dominant.specularColor;
    dat.surfEmit=dominant.surfaceEmit;
    //note: roughness deliberately comes from the ENTERING material below, not
    //the dominant one. Callers that want the dominant roughness override it
    //after this call (see multiMaterial/bottleLiquid.glsl).


    //------VOLUME PROPERTIES------------------------

    //IOR is current/entering (wavelength-dependent when dispersing)
    dat.IOR=iorAt(current.IOR)/iorAt(neighbor.IOR);

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


