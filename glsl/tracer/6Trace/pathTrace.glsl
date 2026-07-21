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
            //do the subsurface scattering:
            //this leaves the ray at a new location and in a new direction,
            //still just outside the surface
            //(subSurfScatter now does the volume emission + absorption per step,
            //so there is no separate updateFromSubSurf pass)
            subSurfScatter(path);

            //reset the absorb color to the orig medium
            path.absorb=path.dat.reflectAbsorb;

            //push off the surface along the normal
            setData_Scene(path);
            nudge(path.tv, path.dat.normal,-5.*EPSILON);
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
