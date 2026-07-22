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
#ifdef SSS_EXIT_FRESNEL
            //EXIT FRESNEL/TIR (docs/material-system.md §5): when the walk reaches
            //the boundary, test the interface FROM INSIDE — with the Fresnel
            //probability the ray reflects back in and the walk resumes (the
            //internal trapping real wax/jade have; TIR included, since the
            //stored IOR is n_in/n_out > 1), else it refracts out. As mfp -> inf
            //this makes the walk limit to the ballistic glass path.
            //
            //The walk's parameters must be CAPTURED here: setData_Scene at the
            //exit point refills dat from the inside branch, which deliberately
            //zeroes meanFreePath/isotropicScatter.
            float walkMfp     = path.dat.meanFreePath;
            float walkScatter = path.dat.isotropicScatter;

            for(int sssTry = 0; sssTry < 8; sssTry++){

                subSurfScatter(path);
                if(!path.keepGoing){ break; }   //absorbed/stuck inside

                //interface data at the exit point: the walk lands just inside
                //the surface, so this is the inside branch — dat.normal faces
                //the arriving ray (inward), dat.IOR = n_inside/n_outside.
                setData_Scene(path);

                float F = FresnelReflectAmount(path.dat.IOR, path.tv, path.dat.normal, 0., 1.);
                if(randomFloat() < F){
                    //trapped on the very last try: terminate (rare — like the
                    //walk's own stuck-inside bailout) rather than forcing an
                    //exit through a possibly-TIR interface
                    if(sssTry == 7){ path.keepGoing = false; break; }
                    //reflect back inside and resume the walk: restore the walk
                    //parameters and the interior absorb/emit (the exit data's
                    //reflect side IS the interior)
                    path.tv = vReflect(path.tv, path.dat.normal);
                    nudge(path.tv, path.dat.normal, 5.*EPSILON);
                    path.absorb = path.dat.reflectAbsorb;
                    path.emit   = path.dat.reflectEmit;
                    path.dat.meanFreePath     = walkMfp;
                    path.dat.isotropicScatter = walkScatter;
                }
                else{
                    //leave: refract at the exit (the physical bend; a no-op in
                    //direction only if the indices match), enter the outside
                    //medium, and push off the surface
                    path.tv = vRefract(path.tv, path.dat.normal, path.dat.IOR);
                    path.absorb = path.dat.refractAbsorb;
                    path.emit   = path.dat.refractEmit;
                    nudge(path.tv, path.dat.normal, -5.*EPSILON);
                    break;
                }
            }
#else
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
#endif
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
