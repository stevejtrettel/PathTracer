//-------------------------------------------------
// PATH-TRACING
// this is the main path tracing loop
//  used in main.glsl
//-------------------------------------------------


vec3 pathTrace(Path path){

    for (int bounceIndex = 0; bounceIndex < maxBounces; ++bounceIndex)
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

        //probabilistically kill rays
        roulette(path);

        if(!path.keepGoing){ break; }

    }

    return path.pixel;

}
