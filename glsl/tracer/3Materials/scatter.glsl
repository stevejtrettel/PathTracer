//-------------------------------------------------
// SCATTER — the event tree  (docs/material-system.md §3)
//
//     r ~ U[0,1)
//     ├─ COAT      white reflection off the lacquer     P = coat·schlick(1.5)
//     ├─ SPECULAR  tinted reflection (F0 whitening)     P = (1-Pc)·F
//     ├─ TRANSMIT  cross into the medium beyond         P = (1-Pc)(1-F)·transmit
//     └─ DIFFUSE   cosine hemisphere (dense-interior shortcut)
//
// One microfacet per event (§4): the normal is jittered ONCE by the roughness
// and Fresnel/reflect/refract all run deterministically off the jittered
// normal — the jitter distribution IS the material definition, so there are no
// sampling weights anywhere. The lobe probabilities ARE the lobes' energy
// fractions (F comes from the interface's index ratio, floored by the artistic
// gloss knob), so the throughput only ever picks up tints in updateFromSurface.
// Dividing by a probability here would double-count lobe energy.
//-------------------------------------------------


//a facet tilted away from the incident ray can't physically be struck: mirror
//it about the normal axis (same tilt, opposite azimuth), falling back to the
//smooth normal if it still faces away.
Vector sampleFacet(Vector incident, Vector normal, float rough2){
    Vector m = vNormalize(mix(normal, randomVector(incident.pos), rough2));
    if(vDot(incident, m) >= 0.){
        m = vNormalize(sub(multiplyScalar(2.*vDot(m, normal), normal), m));
        if(vDot(incident, m) >= 0.){ m = normal; }
    }
    return m;
}

//keep an outgoing reflection above the geometric surface: mirror a ray that
//dipped below the horizon back across the surface plane.
Vector aboveHorizon(Vector v, Vector normal){
    if(vDot(v, normal) < 0.){ return vReflect(v, normal); }
    return v;
}


void scatter( inout Path path ){

    //unrendered materials: pass straight through into the medium beyond
    if(!path.dat.renderMaterial){
        path.type=3;
        path.absorb=path.dat.refractAbsorb;
        path.emit=path.dat.refractEmit;
        path.subSurface=false;
        flow(path.tv, 10.*EPSILON);
        return;
    }

    Surface surf=path.dat.surf;
    Vector normal=path.dat.normal;

    //the microfacet this event strikes — shared by the Fresnel probability and
    //the reflect/refract directions (that coupling is the model: soft jittered
    //grazing highlights, facet-TIR ground-glass edges)
    float rough2=surf.roughness*surf.roughness;
    Vector facet=sampleFacet(path.tv, normal, rough2);

    //---- the probabilities -------------------------------------------------
    float probCoat=0.;
    if(surf.coat>0.){
        probCoat=surf.coat*FresnelReflectAmount(1./1.5, path.tv, normal, 0., 1.);
    }
    //base Fresnel runs only for a gloss floor or a real index step: an
    //index-MATCHED interface (IOR == 1, e.g. the Luneburg rim or a thin surface)
    //is physically reflectionless, and Schlick's x^5 grazing term does not
    //vanish at n == 1 — running it there would paint phantom reflections.
    float F=0.;
    if(surf.gloss!=0. || path.dat.IOR!=1.){
        F=FresnelReflectAmount(path.dat.IOR, path.tv, facet, surf.gloss, 1.);
    }
    float probSpecular=(1.-probCoat)*F;
    float probTransmit=(1.-probCoat)*(1.-F)*surf.transmit;
    //diffuse takes the remainder

    //---- select the event --------------------------------------------------
    float random=randomFloat();
    Vector diffuseDir=vNormalize(add(normal, randomVector(path.tv.pos)));
    Vector newDir;

    if(random < probCoat){

        //COAT: a white reflection off the lacquer's own facet. Reuses type=2,
        //so make the specular tint white — the coat has no color of its own.
        path.type=2;
        path.absorb=path.dat.reflectAbsorb;
        path.emit=path.dat.reflectEmit;
        path.subSurface=false;

        path.dat.surf.specular=vec3(1.);

        Vector coatFacet=sampleFacet(path.tv, normal, surf.coatRoughness*surf.coatRoughness);
        newDir=aboveHorizon(vReflect(path.tv, coatFacet), normal);

    }

    else if(random < probCoat+probSpecular){

        //SPECULAR: the reflection carries the surface's specular colour (a
        //metal's F0) head-on and whitens toward total reflection at grazing —
        //per-channel Schlick against the struck facet. A no-op for
        //white-specular materials; this is what makes gold gold.
        path.type=2;
        path.absorb=path.dat.reflectAbsorb;
        path.emit=path.dat.reflectEmit;
        path.subSurface=false;

        float cosI=clamp(-vDot(path.tv, facet), 0., 1.);
        float gz=pow(1.-cosI, 5.);
        path.dat.surf.specular=mix(path.dat.surf.specular, vec3(1.), gz);

        newDir=vReflect(path.tv, facet);
        //MULTI-BOUNCE (§6b): a reflection that dips below the horizon struck
        //the side of a groove — let it strike another facet (picking up the
        //tint again) instead of mirroring it out. Rough metals SATURATE
        //instead of graying. Bounded; mirrored out if still trapped.
        for(int k=0; k<3; k++){
            if(vDot(newDir, normal) >= 0.){ break; }
            path.light *= path.dat.surf.specular;
            newDir=vReflect(newDir, sampleFacet(newDir, normal, rough2));
        }
        newDir=aboveHorizon(newDir, normal);

    }

    else if(random < probCoat+probSpecular+probTransmit){

        //TRANSMIT: cross into the medium beyond, refracting through the same
        //facet the Fresnel saw (facet-TIR cannot reach this branch — the same
        //facet fed F, which returns 1 under TIR and forces the specular tier).
        //If that medium scatters, the walk runs next (pathTrace/mediumWalk).
        path.type=3;
        path.absorb=path.dat.refractAbsorb;
        path.emit=path.dat.refractEmit;
        path.subSurface=(path.dat.mfp < 0.99*maxDist);

        newDir=vRefract(path.tv, facet, path.dat.IOR);
        //an extreme facet tilt can refract back above the geometric horizon:
        //mirror it below
        if(vDot(newDir, normal) > 0.){ newDir=vReflect(newDir, normal); }

    }

    else{

        //DIFFUSE: the analytic shortcut for an interior too dense to walk
        path.type=1;
        path.absorb=path.dat.reflectAbsorb;
        path.emit=path.dat.reflectEmit;
        path.subSurface=false;

        newDir=diffuseDir;

    }

    //----set the new vector and push off the surface
    path.tv=newDir;
    flow(path.tv, 10.*EPSILON);

}
