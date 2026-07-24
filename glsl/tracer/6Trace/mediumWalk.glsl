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
    path.pixel += path.light * path.medium.emit * dl;
    path.light  *= exp(-path.medium.absorb * dl);
}


//one leg of the walk: scatter through the interior until the ray crosses the
//boundary (leaving it ON the surface, still inside) or dies. Applying Beer's
//law per step makes throughput decay with depth, so roulette culls rays the
//medium would have absorbed anyway — unbiased, only wasted deep-ray work saved.
void walkInterior(inout Path path, float mfp, float blur){

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

    for (int i = 0; i < scatterSteps; i++){

        //choose the scatter direction (normalized so the step below travels
        //exactly flowDist) and an exponential flight of mean mfp
        randomDir=randomVector(temp.pos);
        temp=vNormalize(mix(temp,randomDir,rough));
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
            flow(tv,flowDist-EPSILON/2.);
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

    for(int walkTry = 0; walkTry < 8; walkTry++){

        walkInterior(path, mfp, blur);
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
            //trapped on the very last try: terminate (rare) rather than force
            //an exit through a possibly-TIR interface
            if(walkTry == 7){ path.keepGoing = false; return; }
            //reflect back inside and keep walking; the exit data's reflect
            //side IS the interior (aboveHorizon keeps the bounce inward)
            path.tv = aboveHorizon(vReflect(path.tv, facet), path.dat.normal);
            nudge(path.tv, path.dat.normal, 5.*EPSILON);
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
            nudge(path.tv, path.dat.normal, -5.*EPSILON);
            path.subSurface = false;
            return;
        }
    }
}

#endif   //SCENE_SUBSURFACE
