//-------------------------------------------------
// MEDIUM WALK  (docs/material-system.md §5)
//
// COMPILED ONLY WHEN THE SCENE SAYS SO. A scene whose regions are all ballistic
// (every mfp == maxDist) can never enter this file, so it declares nothing and
// the whole walk — plus the insideOf() dispatcher it needs — vanishes from the
// shader. Scenes that do scatter set `defines: ['SCENE_SUBSURFACE']` in their
// settings and supply:
//
//     bool insideOf(int id, vec3 p);   is p inside region `id`?
//
// which the generator emits per region with only the nested-region exclusions
// that region actually has (usually none). That is much cheaper than a general
// regionAt() scan, and this is its hottest caller: once per scatter step, and
// sixteen times per boundary crossing in bisect_Scatter.
//-------------------------------------------------
#ifdef SCENE_SUBSURFACE
//-------------------------------------------------
// transport through a scattering interior: a random walk with exponential
// free paths, per-step Beer absorption + volume emission, and Fresnel/TIR at
// the boundary FROM INSIDE — with the Fresnel probability an exiting ray
// reflects back in and keeps walking (the internal trapping real wax and jade
// have), else it refracts out. As mfp -> maxDist the walk limits to the
// ballistic glass path. Entered from pathTrace() when a transmit event lands
// in a medium with mfp < maxDist (see scatter.glsl).
//-------------------------------------------------


//distance to the boundary along tv: you are inside, flowing by dt is outside.
//16 halvings, not 10: the precision is dt/2^N and dt is a full exponential
//step, so at mean free paths near 1 a 10-halving exit could land farther from
//the surface than AT_THRESH — the follow-up setData then found no surface.
float bisect_Scatter(Vector tv, float dt, int region){
    float dist=0.;
    float testDist=dt;
    Vector temp;

    for(int i=0;i<16;i++){
        //divide the step size in half and test a flow by that amount
        testDist=testDist/2.;
        temp=tv;
        flow(temp, dist+testDist);
        //still inside: keep the half-step; else halve again
        if(insideOf(region, temp.pos)){
            dist+=testDist;
        }
    }
    return dist;
}


//emission + Beer's-law absorption picked up over a segment of length dl of the
//walk. Guarded by volumeActive at the call sites, so a pure-scattering medium
//skips it entirely.
void absorbEmit(inout Path path, float dl){
    //emission integrated against the absorption along the segment (see
    //updateFromVolume): e(1-exp(-s dl))/s, not e*dl at the leg's starting
    //throughput, which overcounts once s*dl is not small
    vec3 s = path.medium.absorb;
    vec3 T = exp(-s * dl);
    path.pixel += path.light * mix(path.medium.emit*dl, path.medium.emit*(1.-T)/max(s, vec3(1e-6)), step(vec3(1e-6), s));
    path.light  *= T;
}


//one leg of the walk: scatter through the interior until the ray crosses the
//boundary (leaving it ON the surface, still inside) or dies. Applying Beer's
//law per step makes throughput decay with depth, so roulette culls rays the
//medium would have absorbed anyway — unbiased, only wasted deep-ray work saved.
void walkInterior(inout Path path, float mfp, float blur, float surfaceBlur){

    int scatterSteps=1000;
    float depth=0.;
    float flowDist;

    Vector tv=path.tv;
    Vector temp=path.tv;
    Vector randomDir;

    float rough=blur*blur;

    //absorption/emission are constant through the walk: decide ONCE whether
    //this medium has any volume interaction
    bool volumeActive = length(path.medium.absorb) > 1e-4 || length(path.medium.emit) > 1e-4;

    //SURFACE BLUR: one extra scatter right at the boundary, before the first
    //flight — a thin scattering skin over the uniform interior, which sends
    //some light straight back out near where it came in, barely absorbed (the
    //milky sheen). 0 = none. surfaceBlur = blur reproduces the old
    //scatter-first walk exactly (same random draws, same order).
    if(surfaceBlur > 0.){
        temp=vNormalize(mix(temp, randomVector(temp.pos), surfaceBlur*surfaceBlur));
    }

    for (int i = 0; i < scatterSteps; i++){

        //FLY FIRST, then scatter: each leg starts along the direction the path
        //arrived with (refracted in at the surface, or reflected back in off
        //it), and blur acts at the scattering vertex. Scattering at the entry
        //point instead threw that direction away — up to half of all entering
        //rays (blur 1) headed straight back out — so the "ballistic limit" as
        //mfp -> maxDist was not the glass path it should be.
        tv=temp;
        flowDist=randomExponential(mfp);
        flow(temp,flowDist);

        //crossed the boundary: bisect to it and stop this leg just inside.
        //"the boundary" is THIS region's — not "any object's". A region nested
        //inside another (a core in a glass ball) has to tell its own wall from
        //the one enclosing it, which is what insideOf() encodes per region.
        if(!insideOf(path.region, temp.pos)){
            flowDist=bisect_Scatter(tv,flowDist,path.region);
            if(volumeActive){ absorbEmit(path, flowDist); }
            flow(tv,flowDist-GEO_EPS/2.);
            path.tv=tv;
            path.distance=depth+flowDist;
            path.numScatters=float(i);
            return;
        }

        //still inside: advance and pick up emission + absorption
        tv=temp;
        depth+=flowDist;
        if(volumeActive){ absorbEmit(path, flowDist); }

        roulette(path);
        if(!path.keepGoing){ return; }

        //scatter at this vertex (normalized so the next flight travels
        //exactly flowDist)
        randomDir=randomVector(temp.pos);
        temp=vNormalize(mix(temp,randomDir,rough));

    }

    //we got stuck inside the material
    path.numScatters=float(scatterSteps);
    path.distance=depth;
    path.keepGoing=false;
}


void mediumWalk(inout Path path){

    //the walk parameters come from the medium the path is IN — scatter set
    //path.medium = dat.back on the transmit event that got us here. Captured at
    //entry because setData_Scene at the boundary refills dat from the EXIT
    //interface, whose "beyond" is the outside world.
    float mfp =path.medium.mfp;
    float blur=path.medium.blur;
    float surfaceBlur=path.medium.surfaceBlur;

    for(int walkTry = 0; walkTry < 32; walkTry++){

        walkInterior(path, mfp, blur, surfaceBlur);
        if(!path.keepGoing){ return; }   //absorbed or stuck inside

        //interface data at the exit point: the leg ends just inside the
        //surface, so this is the inside view — dat.normal faces the arriving
        //ray, and iorRatio = n_inside/n_outside (TIR-capable)
        setData_Scene(path);

        //the boundary has the surface's FINISH: strike a facet of it, shared
        //by the Fresnel test and both outcomes. This is what separates matte
        //subsurface (wax, clay — rough exit) from polished (jade, porcelain,
        //marble — mirror-smooth exit) with the same interior.
        float exitRough2 = path.dat.surf.roughness*path.dat.surf.roughness;
        Vector facet = sampleFacet(path.tv, path.dat.normal, exitRough2);

        float F = FresnelReflectAmount(iorRatio(path.dat), path.tv, facet, 0., 1.);
        if(randomFloat() < F){
            //trapped by internal reflection. Past 8 tries, wind the path down with
            //roulette (unbiased: survivors are boosted) instead of killing it —
            //the old hard stop at 8 deleted 3-7% of the entering energy, ~27% at
            //ior 2. The last try still stops, after ~0.75^24 of survival.
            if(walkTry == 31){ path.keepGoing = false; return; }
            if(walkTry >= 7){
                roulette(path, 0.75);
                if(!path.keepGoing){ return; }
            }
            //reflect back inside and keep walking; the exit data's reflect
            //side IS the interior (aboveHorizon keeps the bounce inward)
            path.tv = aboveHorizon(vReflect(path.tv, facet), path.dat.normal);
            nudge(path.tv, path.dat.normal, 5.*GEO_EPS);
            path.medium = path.dat.front;
            path.region = path.dat.frontID;
        }
        else{
            //leave: refract at the exit (the physical bend, blurred by the
            //facet), enter the outside medium, and push off the surface
            path.tv = vRefract(path.tv, facet, iorRatio(path.dat));
            if(vDot(path.tv, path.dat.normal) > 0.){ path.tv = vReflect(path.tv, path.dat.normal); }
            path.medium = path.dat.back;
            path.region = path.dat.backID;
            nudge(path.tv, path.dat.normal, -5.*GEO_EPS);
            path.subSurface = false;
            return;
        }
    }
}

#endif   //SCENE_SUBSURFACE
