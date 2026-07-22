//-------------------------------------------------
// SUB SURFACE SCATTERING
// this function maybe conceptually belongs in the '3MATERIALS' folder
// as it updates a path before the next bounce.  But it needs the sdfs....
//-------------------------------------------------

float bisect_Scatter(Vector tv, float dt){
    float dist=0.;
    //you are inside, but flowing by dt is outside
    float testDist=dt;
    Vector temp;

    //16 halvings, not 10: the precision is dt/2^N, and dt is a full exponential
    //step — at mean free paths near 1 a 10-halving exit could land farther from
    //the surface than AT_THRESH, so the follow-up setData found no surface at
    //the exit point (stale LocalData, garbage bounce). 16 keeps the landing
    //inside AT_THRESH for any step this tracer can take.
    for(int i=0;i<16;i++){

        //divide the step size in half
        testDist=testDist/2.;

        //test flow by that amount:
        temp=tv;
        flow(temp, dist+testDist);
        //if you are still inside, add the dist
        if(inside_Object(temp)){
            dist+=testDist;
        }
        //if not, then don't add: divide in half and try again

    }
    return dist;
}


//emission + Beer's-law absorption picked up over a segment of length dl of the walk
//(the volume-rendering step). Guarded by volumeActive at the call sites, so a pure-
//scattering medium skips it entirely.
void absorbEmit(inout Path path, float dl){
    path.pixel += path.light * path.emit * dl;
    path.light  *= exp(-path.absorb * dl);
}


void subSurfScatter(inout Path path){

    int scatterSteps=1000;
    float depth=0.;
    float flowDist;

    //set the vector we will carry along for the ride
    Vector tv=path.tv;
    Vector temp=path.tv;
    Vector randomDir;

    //parameters of the random walk
    float rough=path.dat.isotropicScatter*path.dat.isotropicScatter;
    float mfp = path.dat.meanFreePath;

    //absorption/emission are constant through the walk, so decide ONCE whether this
    //medium has any volume interaction. For a pure-scattering medium (absorb=emit=0)
    //the per-step Beer's law is exp(-0)=1 — pure waste — and roulette can't cull
    //anyway, so skip all of it and let the walk terminate by exiting the object.
    bool volumeActive = length(path.absorb) > 1e-4 || length(path.emit) > 1e-4;


    //do the subsurface scattering for the surface we are at
    for (int i = 0; i < scatterSteps; i++){

        //choose the direction of scatter. normalize the blend so the step below
        //travels exactly flowDist along a UNIT direction — otherwise |dir|<1 makes
        //the effective mean free path shrink (and depend on isotropicScatter, which
        //should be an independent knob). Matches scatter() in scatterPath.glsl.
        randomDir=randomVector(temp.pos);
        temp=vNormalize(mix(temp,randomDir,rough));
        //update tv's direction
        tv=temp;
        //choose the distance to flow: exponential dist with mean free path mfp
        flowDist=randomExponential(mfp);

        //do a trial flow of this distance, in given direction
        flow(temp,flowDist);

        //if we have left the object
        if(!inside_Object(temp)){
            //tv is behind it, temp is in front: bisect to the boundary distance
            flowDist=bisect_Scatter(tv,flowDist);
            //pick up emission + absorption over this last (partial) segment
            if(volumeActive){ absorbEmit(path, flowDist); }
            //flow slightly farther so you get out, and land back on the surface
            flow(tv,flowDist-EPSILON/2.);
            path.tv=tv;
            path.distance=depth+flowDist;
            path.numScatters=float(i);
            path.subSurface=false;
            return;
        }

        //still inside: advance, then pick up emission + absorption over this segment.
        //Applying Beer's law HERE (per step) rather than once at the end makes
        //throughput decay as the walk goes deeper, so roulette below culls rays the
        //medium would have absorbed anyway. Unbiased: the per-step exp(-absorb*dl)
        //product equals a single exp(-absorb*total), and roulette boosts survivors —
        //so the mean is unchanged, only wasted deep-ray work is saved.
        tv=temp;
        depth+=flowDist;
        if(volumeActive){ absorbEmit(path, flowDist); }

        //kill off rays (now meaningful throughout: light has decayed with depth)
        roulette(path);
        if(!path.keepGoing){
            break;
        }

    }

    //we got stuck inside the material
    path.numScatters=float(scatterSteps);
    path.distance=depth;
    path.keepGoing=false;
}