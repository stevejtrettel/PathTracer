

//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------



//facet: the normal the base Fresnel is evaluated against. The smooth geometric
//normal in the legacy roughness model; the per-event jittered microfacet under
//MICROFACET_ROUGHNESS (sampled in scatter(), which shares it with the
//reflect/refract directions — that coupling is the point of the model).
void updateProbabilities( inout Path path, Vector facet ){

    //---- TIER 1: the COAT (docs/material-system.md §3) --------------------
    //an optional white Fresnel lobe ABOVE everything: a zero-thickness lacquer at
    //fixed n = 1.5. Its probability is coat · schlick(1.5), evaluated with the
    //OUTSIDE index ratio regardless of side (the coat is an exterior finish; using
    //the inside ratio would paint coat-TIR on interior glass bounces). Computed
    //before (and independent of) the base-Fresnel gate below, so a plain matte
    //material can still carry a coat. coat == 0 (the default) is a strict no-op.
    path.dat.probCoat = 0.;
    if(path.dat.coat > 0.){
        path.dat.probCoat = path.dat.coat
            * FresnelReflectAmount(1./1.5, path.tv, path.dat.normal, 0., 1.);
    }

    //---- TIER 2: base Fresnel ---------------------------------------------
    //update using Fresnel. Runs for anything with an explicit specular floor OR an
    //index mismatch at the interface. The IOR condition is what gives every
    //dielectric its physical coat with no per-scene bookkeeping: glass is
    //pure-Fresnel (specularChance == 0 — see setGlass), and subsurface materials
    //(makeGlass + refractionChance = 0) have both lobe chances zero yet still
    //present an IOR step, so they Fresnel-reflect ~4% like real wax/skin/glass.
    //Deliberately NOT gated on probRefract: a refractive material with IOR == 1
    //(the Luneburg rim, a dynamic-IOR medium wall where the field reaches 1) is an
    //index-MATCHED interface — physically reflectionless — and Schlick's x^5
    //grazing term does not vanish at n == 1, so running Fresnel there would paint
    //phantom grazing reflections on a seamless boundary. Any real refractive step
    //has IOR != 1 and is covered. Matte materials (walls: IOR == 1, no lobes) skip.
    if(path.dat.probSpecular!=0. || path.dat.IOR!=1.){

        float origSpec=path.dat.probSpecular;

        path.dat.probSpecular = FresnelReflectAmount(path.dat.IOR, path.tv, facet, origSpec, 1.0);

        //--- update diffuse and refract accordingly
        //(origSpec == 1 guard: pure conductors would make this 0/0 — the correct
        //limit is probRefract = 0, and probSpecular is already 1, so skip)
        if(origSpec < 1.){
            float chanceMultiplier = (1.0 - path.dat.probSpecular) / (1.0 - origSpec);
            path.dat.probRefract  *= chanceMultiplier;
        }
        else{
            path.dat.probRefract = 0.;
        }
        path.dat.probDiffuse = 1.-path.dat.probRefract-path.dat.probSpecular;
    }

    //---- the base tiers share what the coat leaves behind ------------------
    if(path.dat.probCoat > 0.){
        float remainder = 1. - path.dat.probCoat;
        path.dat.probSpecular *= remainder;
        path.dat.probRefract  *= remainder;
        path.dat.probDiffuse   = 1. - path.dat.probCoat - path.dat.probSpecular - path.dat.probRefract;
    }

}






#ifdef MICROFACET_ROUGHNESS
//ONE MICROFACET PER EVENT (docs/material-system.md §4): jitter the normal by the
//roughness, then run Fresnel/reflect/refract DETERMINISTICALLY off the jittered
//normal. The jitter distribution IS the material definition — there is no target
//distribution and hence no sampling weight. A facet tilted away from the incident
//ray can't physically be struck: mirror it about the normal axis (same tilt,
//opposite azimuth), falling back to the smooth normal if it still faces away.
Vector sampleFacet(Vector incident, Vector normal, float rough2){
    Vector m = vNormalize(mix(normal, randomVector(incident.pos), rough2));
    if(vDot(incident, m) >= 0.){
        m = vNormalize(sub(multiplyScalar(2.*vDot(m, normal), normal), m));
        if(vDot(incident, m) >= 0.){ m = normal; }
    }
    return m;
}

//keep an outgoing REFLECTION above the geometric surface: a facet-reflected ray
//that dips below the horizon is mirrored back across the surface plane.
Vector aboveHorizon(Vector v, Vector normal){
    if(vDot(v, normal) < 0.){ return vReflect(v, normal); }
    return v;
}
#endif


void scatter( inout Path path){

    if(path.dat.renderMaterial){

        //the normal (outward facing at the surface we are at)
        Vector normal=path.dat.normal;

        //------useful parameters--------
        float rough2=path.dat.surfRoughness * path.dat.surfRoughness;

#ifdef MICROFACET_ROUGHNESS
        //the microfacet this event strikes: shared by the Fresnel probabilities
        //and the reflect/refract directions below, which is what couples rough
        //Fresnel to rough geometry (soft jittered grazing highlights, facet-TIR
        //ground-glass edges). The coat samples its own facet in its branch.
        Vector facet=sampleFacet(path.tv, normal, rough2);
        updateProbabilities(path, facet);
#else
        //legacy: Fresnel always sees the smooth normal
        updateProbabilities(path, normal);
#endif

        //random number we will use to select ray type
        float random=randomFloat();

        //----- useful vectors in the following computation ----------
        Vector randomDir=randomVector(path.tv.pos);
        Vector diffuseDir=vNormalize(add(normal, randomDir));
        Vector newDir;

        if (random<path.dat.probCoat){

            //its a COAT ray: a WHITE specular reflection off the lacquer, blurred
            //by the coat's own roughness (not the base material's). Reusing
            //type=2 means updateFromSurface tints by surfSpecular — so set that
            //to white here: the coat has no color of its own.
            path.type=2;
            path.absorb=path.dat.reflectAbsorb;
            path.emit=path.dat.reflectEmit;
            path.subSurface=false;

            path.dat.surfSpecular=vec3(1.);

            float coatRough2=path.dat.coatRoughness*path.dat.coatRoughness;
#ifdef MICROFACET_ROUGHNESS
            //the coat strikes its OWN facet, jittered by coatRoughness (satin
            //finishes: a matte lacquer over a polished base, or vice versa).
            //Its Fresnel probability above used the smooth normal — the coat
            //jitter blurs direction only.
            Vector coatFacet=sampleFacet(path.tv, normal, coatRough2);
            newDir=vReflect(path.tv, coatFacet);
            newDir=aboveHorizon(newDir, normal);
#else
            newDir=vReflect(path.tv, normal);
            newDir=vNormalize(mix(newDir, diffuseDir, coatRough2));
#endif

        }

        else if (random<path.dat.probCoat+path.dat.probSpecular){

            //its a specular ray
            path.type=2;
            path.absorb=path.dat.reflectAbsorb;
            path.emit=path.dat.reflectEmit;
            path.subSurface=false;

            //CONDUCTOR FRESNEL TINT: the reflection carries the surface's specular
            //colour (a metal's F0) head-on and whitens toward total reflection at
            //grazing — per-channel Schlick, using the incidence angle against the
            //struck normal (path.tv is still the incident ray here). A no-op for
            //white-specular materials (glass, plastic); this is what makes gold gold.
#ifdef MICROFACET_ROUGHNESS
            float cosI = clamp(-vDot(path.tv, facet), 0., 1.);
#else
            float cosI = clamp(-vDot(path.tv, normal), 0., 1.);
#endif
            float gz = pow(1.-cosI, 5.);
            path.dat.surfSpecular = mix(path.dat.surfSpecular, vec3(1.), gz);

#ifdef MICROFACET_ROUGHNESS
            newDir=vReflect(path.tv, facet);
            //MULTI-BOUNCE (§6b): a reflection that dips below the horizon struck
            //the side of a groove — instead of mirroring it out (which loses the
            //inter-facet bounces), let it strike another facet: pick up the
            //specular tint again and reflect again. This is what makes rough
            //metals SATURATE instead of graying. Bounded; mirrored out if still
            //trapped after the last bounce.
            for(int k=0;k<3;k++){
                if(vDot(newDir, normal) >= 0.){ break; }
                path.light *= path.dat.surfSpecular;
                Vector m2=sampleFacet(newDir, normal, rough2);
                newDir=vReflect(newDir, m2);
            }
            newDir=aboveHorizon(newDir, normal);
#else
            newDir=vReflect(path.tv, normal);
            newDir=vNormalize(mix(newDir, diffuseDir,rough2));
#endif

        }

        else if (random<path.dat.probCoat+path.dat.probSpecular+path.dat.probRefract){

            //its a refractive ray
            path.type=3;
            path.absorb=path.dat.refractAbsorb;
            path.emit=path.dat.refractEmit;
            path.subSurface=false;

#ifdef MICROFACET_ROUGHNESS
            //refract THROUGH the same facet the Fresnel saw — real ground glass,
            //not a blend toward inverted-Lambert. Facet-TIR can't reach this
            //branch (the same facet fed Fresnel, which returns 1 under TIR and
            //forces the specular tier), but an extreme facet tilt can refract
            //the ray back above the geometric horizon: mirror it below.
            newDir=vRefract(path.tv, facet, path.dat.IOR);
            if(vDot(newDir, normal) > 0.){ newDir=vReflect(newDir, normal); }
#else
            newDir=vRefract(path.tv, normal, path.dat.IOR);
            newDir=vNormalize(mix(newDir, negate(diffuseDir),rough2));
#endif

        }

        else {

            //its a diffuse ray

            //if the material subsurface scatters, enter it
            if(path.dat.subSurface){
                path.subSurface=true;
                path.type=3;//we are entering material
                path.absorb=path.dat.refractAbsorb;
                path.emit=path.dat.refractEmit;
                newDir=vRefract(path.tv, normal, path.dat.IOR);
            }

            else{
                //just reflect off in a random direction
                path.type=1;
                path.absorb=path.dat.reflectAbsorb;
                path.emit=path.dat.reflectEmit;
                newDir=diffuseDir;
            }

        }


        //NO 1/probability boost here: the lobe probabilities ARE the lobes' energy
        //fractions (updateProbabilities sets probSpecular to the Fresnel reflectance,
        //and the others share what remains), so the sampling weight and the lobe
        //energy cancel exactly — the throughput picks up only the lobe's colour in
        //updateFromSurface. Dividing by the probability double-counts the lobe energy
        //(a 1/F ~ 20x boost per specular event: glass glows white). The old uncapped
        //roulette happened to renormalize any throughput > 1 and masked this.

        //----set the new vector and push off the surface
        path.tv=newDir;
        flow(path.tv,10.*EPSILON);

    }

    else{
        //if we do not render the material:

        //we are passing through: so "refraction"
        path.type=3;
        path.absorb=path.dat.refractAbsorb;
        path.emit=path.dat.refractEmit;
        path.subSurface=false;

        //move ahead along our (unchanged) ray
        flow(path.tv,10.*EPSILON);
    }

}