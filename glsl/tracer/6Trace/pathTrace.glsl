//-------------------------------------------------
// PATH-TRACING
// this is the main path tracing loop
//  used in main.glsl
//-------------------------------------------------


//THE ROULETTE TAIL: a hard stop at maxBounces DELETES the remaining energy of
//every path still alive there — and throughput roulette never kills clear-glass
//chains (no tint, survival 1), so exactly the deep glass paths arrive at the cap
//at full weight; glass renders visibly dark at low maxBounces (glass kleinBottle
//at 6 vs 32). So the loop runs RR_TAIL_LEN further, with survival forced down by
//RR_TAIL per extra bounce — the 1/p boost in roulette keeps it unbiased: depth
//past the cap is sampled rarely-but-compensated, and the truncated mass falls
//from 100% to RR_TAIL^RR_TAIL_LEN (~3%). Survivor weight grows 1/RR_TAIL per
//tail bounce (≤ ~31×) — cutting residual mass to ε costs max weights ~1/ε in ANY
//roulette scheme. Expected extra cost ≈ 3 bounces, paid only by paths that reach
//the cap. maxBounces keeps its meaning: full-effort depth.
const int   RR_TAIL_LEN = 12;
const float RR_TAIL     = 0.75;

//THE ROULETTE DELAY: no roulette before RR_START. From bounce 0, kills run at
//p = throughput and survivors are boosted back to full strength — so a dark
//wall's indirect light arrives as RARE FULL-WEIGHT samples (albedo 0.1: 90%
//dead after one bounce, the rest at weight 1 = speckle). With no light sampling
//in this tracer, later bounces are the ONLY light those pixels get. Letting the
//throughput accumulate deterministically first trades a little marching (paths
//live ≥ RR_START segments) for frequent-dim samples instead. Unbiased: survival
//probability 1 is legal roulette. 0 restores the old behavior exactly.
const int   RR_START = 2;


vec3 pathTrace(Path path){

    for (int bounceIndex = 0; bounceIndex < maxBounces + RR_TAIL_LEN; ++bounceIndex)
    {
        //move forward until the next intersection, update LocalData
        stepForward(path);

        //pick up color from traveling through the medium we were just in.
        updateFromVolume(path);

        // if you hit the sky: stop
        //(no surface data was set, so do not scatter off of it)
        updateFromSky(path);
        if(!path.keepGoing){ break; }

        //scatter the path off in a new direction
        scatter(path);

#ifdef SCENE_SUBSURFACE
        if(path.subSurface){
            //the transmit event entered a scattering interior: walk it.
            //mediumWalk owns everything — the interior legs, the boundary
            //Fresnel/TIR, and the exit — and leaves the ray just outside.
            mediumWalk(path);
        }
        else{
            //pick up any color from the reflection off surface
            updateFromSurface(path);
        }
#else
        //no region in this scene scatters, so the walk is compiled out entirely
        updateFromSurface(path);
#endif

        //probabilistically kill rays: free flight before RR_START, throughput
        //roulette in the body, wind-down past maxBounces
        if(bounceIndex >= RR_START){
            roulette(path, bounceIndex < maxBounces ? 1. : RR_TAIL);
        }

        if(!path.keepGoing){ break; }

    }

    return path.pixel;

}
