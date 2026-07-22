//-------------------------------------------------
// INTERACTIONS  (docs/material-system.md §2)
// Surfaces are boundaries between media. setInteraction() is the ONE function
// that fills LocalData from (Surface, medium in front, medium beyond); the
// wrappers below cover the three ways a scene presents an interface:
//   setObjectInAir      — an object bounded by open air (the common case)
//   setSurfaceInMat     — a thin two-sided surface floating in one material
//   setMaterialInterface— inside one material, hitting another (liquid/glass)
// The IOR ratio always comes from the two media (dispersed per-side by iorAt);
// air is just the default Medium.
//-------------------------------------------------


//normal must face the incident ray; front = the medium the ray is in now
//(reflections stay in it), back = the medium beyond (transmissions enter it).
void setInteraction(inout LocalData dat, Surface surf, Medium front, Medium back, Vector normal, float side){
    dat.renderMaterial=true;
    dat.isSky=false;
    dat.side=side;
    dat.normal=normal;
    dat.surf=surf;

    dat.IOR=iorAt(front.ior)/iorAt(back.ior);

    dat.reflectAbsorb=front.absorb;
    dat.reflectEmit=front.emit;
    dat.refractAbsorb=back.absorb;
    dat.refractEmit=back.emit;
    dat.mfp=back.mfp;
    dat.blur=back.blur;
}


void setObjectInAir(inout LocalData dat, bool inside, Vector normal, Material mat){

    Medium air; initMedium(air);

    if(inside){
        setInteraction(dat, mat.surf, mat.interior, air, negate(normal), -1.);
    }
    else{
        setInteraction(dat, mat.surf, air, mat.interior, normal, 1.);
    }

    dat.renderMaterial=mat.render;
}


//a thin two-sided surface living inside an ambient material: both sides leave
//into the same medium, so the interface is index-matched (IOR ratio 1).
void setSurfaceInMat(inout LocalData dat, float side, Vector normal, Material surf, Material mat){

    Vector n=normal;
    if(side<0.){ n=negate(normal); }

    setInteraction(dat, surf.surf, mat.interior, mat.interior, n, side);

    dat.renderMaterial=surf.render;
}


//inside one material, running into another: the DOMINANT material supplies the
//surface response, the two volumes supply the physics. The caller sets
//dat.normal (facing the ray) and dat.side BEFORE this call — old contract kept.
void setMaterialInterface(inout LocalData dat, Material current, Material neighbor, Material dominant){
    setInteraction(dat, dominant.surf, current.interior, neighbor.interior, dat.normal, dat.side);
}


//-------------------------------------------------
// MATERIAL FIELDS (docs/material-fields.md)
// re-apply a freshly sampled Material at the current hit, reusing the
// normal/side the standard setData already computed — the sanctioned way for a
// scene to vary material data over a surface. Object-in-air hits only;
// multi-material objects resample before their own setMaterialInterface.
//-------------------------------------------------

void applyMaterial(inout Path path, Material mat){
    bool isInside = (path.dat.side < 0.);
    //dat.normal is stored facing the ray (flipped when inside); recover the
    //geometric one (if/else, not ?: — GLSL ES has no ternary on struct types)
    Vector geomNormal = path.dat.normal;
    if(isInside){ geomNormal = negate(path.dat.normal); }
    setObjectInAir(path.dat, isInside, geomNormal, mat);
}
