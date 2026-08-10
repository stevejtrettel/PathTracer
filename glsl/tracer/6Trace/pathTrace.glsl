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
//(a RR_START delay — skip roulette for the first bounces to smooth dark-wall
//speckle — was built and REVERTED Aug 2026: with 0.1-albedo walls and expensive
//marching, it tripled the cost of most primary paths and glass scenes converged
//visibly slower at equal wall-clock. Bounce-0 roulette is load-bearing here.)


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

        //probabilistically kill rays; past maxBounces, wind the path down
        roulette(path, bounceIndex < maxBounces ? 1. : RR_TAIL);

        if(!path.keepGoing){ break; }

    }

    return path.pixel;

}
