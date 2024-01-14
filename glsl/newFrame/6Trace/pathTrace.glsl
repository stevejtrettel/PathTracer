//-------------------------------------------------
// PATH-TRACING
// this is the main path tracing loop
//  used in main.glsl
//-------------------------------------------------


vec3 pathTrace(Path path){

        maxBounces=50;

        for (int bounceIndex = 0; bounceIndex < maxBounces; ++bounceIndex)
        {
                //move forward until the next intersection, update localData
                stepForward(path);

                //help with focusing
                focusCheck(path);

                //pick up color from traveling through the medium we were just in.
                updateFromVolume(path);

                // if you hit the sky: stop
                updateFromSky(path);

                //scatter the path off in a new direction
                //false=we did not just subsurface scatter
                scatter(path);

                //go through and sample the lights from this location
               // sampleLights(path);

                if(path.subSurface){
                       //do the subsurface scattering:
                        //this leaves the ray at a new location and in a new direction,
                        //still just outside the surface
                        subSurfScatter(path);

                        //update the color from the trajectory
                        updateFromSubSurf(path);

                        //reset the absorb color to the orig medium
                        path.absorb=path.dat.reflectAbsorb;

                        //OPTION 1: JUST FLOW FORWARDS
                        //step forward a bit to get off the surface
                        flow(path.tv,5.*EPSILON);

                        //OPTION 2: USE NORMAL TO PUSH OFF
                        //setData_Scene(path);
                        //nudge(path.tv, path.dat.normal,8.*EPSILON);

                        //OPTION 3: DECIDE WHAT TO DO BY RE-SCATTERING
                        //need the new normal vector
                        //setData_Scene(path);
                       // scatter(path);
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
