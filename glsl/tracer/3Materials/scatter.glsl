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


//an orthonormal tangent pair for n (branch on the dominant axis for stability)
void tangentFrame(vec3 n, out vec3 t1, out vec3 t2){
    vec3 a = abs(n.x) > 0.9 ? vec3(0,1,0) : vec3(1,0,0);
    t1 = normalize(cross(n, a));
    t2 = cross(n, t1);
}

//the microfacet: GAUSSIAN-distributed slopes (the naive Beckmann). Peaked at
//the smooth normal with soft tails, so a light's reflection reads as a bright
//core with falloff — a uniform-direction jitter instead gives a plateau of
//tilts, which renders as a flat DISK of highlight with a hard edge. The 1/2
//compensates reflection's angle-doubling, keeping the roughness knob near the
//old model's visual scale.
//A facet tilted away from the incident ray can't physically be struck: mirror
//it about the normal axis (same tilt, opposite azimuth), falling back to the
//smooth normal if it still faces away.
Vector sampleFacet(Vector incident, Vector normal, float rough2){
    if(rough2 < 1e-5){ return normal; }

    vec3 t1; vec3 t2;
    tangentFrame(normal.dir, t1, t2);
    vec2 slope = 0.5*rough2*randomGaussian2D();
    Vector m = Vector(normal.pos, normalize(normal.dir + slope.x*t1 + slope.y*t2));

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

//reflectance of a thin film (index nf, thickness d in nm): two-beam Airy
//interference between the front- and back-boundary reflections. Under hero-
//wavelength spectral this ray's waveLength picks out one λ, and accumulation
//integrates the rainbow; with spectral off (λ pinned mid-band) the bands are
//angle-only. d = 0 gives R = 0 — a vanishing film reflects nothing.
float thinFilmReflect(float cosI, float nf, float d){
    float sin2 = (1. - cosI*cosI)/(nf*nf);          //Snell: angle inside the film
    float cosF = sqrt(max(1. - sin2, 0.));
    float r0 = (nf - 1.)/(nf + 1.);  r0 *= r0;      //one boundary's reflectance
    float R  = r0 + (1. - r0)*pow(1. - cosI, 5.);
    float lambda = mix(700., 380., waveLength);     //this ray's wavelength, nm
    float phi = 4.*PI*nf*d*cosF/lambda;             //optical path difference
    return clamp(2.*R*(1. - cos(phi)) / (1. + R*R - 2.*R*cos(phi)), 0., 1.);
}


void scatter( inout Path path ){

    //unrendered materials: pass straight through into the medium beyond
    if(!path.dat.render){
        path.type=3;
        path.medium=path.dat.back;
        path.region=path.dat.backID;
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
    float ratio=iorRatio(path.dat);
    float F=0.;
    if(surf.gloss!=0. || ratio!=1.){
        F=FresnelReflectAmount(ratio, path.tv, facet, surf.gloss, 1.);
    }
    //a thin film REPLACES the base Fresnel: interference decides the specular
    //share. On a thin surface (IOR ratio 1) it is the only reflectance; over
    //an opaque base it iridizes the highlights (oil slick on asphalt).
    if(surf.film>0.){
        float cosI=clamp(-vDot(path.tv, facet), 0., 1.);
        F=thinFilmReflect(cosI, surf.filmIOR, surf.film);
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
        path.medium=path.dat.front;
        path.region=path.dat.frontID;
        path.subSurface=false;

        path.dat.surf.specular=vec3(1.);

        float coatRough2=surf.coatRoughness*surf.coatRoughness;
        Vector coatFacet=sampleFacet(path.tv, normal, coatRough2);
        newDir=aboveHorizon(vReflect(path.tv, coatFacet), normal);
        newDir=vNormalize(mix(newDir, diffuseDir, coatRough2*coatRough2));

    }

    else if(random < probCoat+probSpecular){

        //SPECULAR: the reflection carries the surface's specular colour (a
        //metal's F0) head-on and whitens toward total reflection at grazing —
        //per-channel Schlick against the struck facet. A no-op for
        //white-specular materials; this is what makes gold gold.
        path.type=2;
        path.medium=path.dat.front;
        path.region=path.dat.frontID;
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
        //CONVERGE TO DIFFUSE: as roughness -> 1 the facet picture hands the
        //direction to the cosine hemisphere — a maximally rough surface is
        //matte. rough^4 leaves the peaked highlight untouched at low/mid
        //roughness.
        newDir=vNormalize(mix(newDir, diffuseDir, rough2*rough2));

    }

    else if(random < probCoat+probSpecular+probTransmit){

        //TRANSMIT: cross into the medium beyond, refracting through the same
        //facet the Fresnel saw (facet-TIR cannot reach this branch — the same
        //facet fed F, which returns 1 under TIR and forces the specular tier).
        //If that medium scatters, the walk runs next (pathTrace/mediumWalk).
        path.type=3;
        path.medium=path.dat.back;
        path.region=path.dat.backID;
        path.subSurface=(path.dat.back.mfp < 0.99*maxDist);

        newDir=vRefract(path.tv, facet, ratio);
        //an extreme facet tilt can refract back above the geometric horizon:
        //mirror it below
        if(vDot(newDir, normal) > 0.){ newDir=vReflect(newDir, normal); }
        //converge to Lambert TRANSMISSION at roughness 1 (translucent paper)
        newDir=vNormalize(mix(newDir, negate(diffuseDir), rough2*rough2));

    }

    else{

        //DIFFUSE: the analytic shortcut for an interior too dense to walk
        path.type=1;
        path.medium=path.dat.front;
        path.region=path.dat.frontID;
        path.subSurface=false;

        newDir=diffuseDir;

    }

    //----set the new vector and push off the surface
    path.tv=newDir;
    flow(path.tv, 10.*EPSILON);

}
