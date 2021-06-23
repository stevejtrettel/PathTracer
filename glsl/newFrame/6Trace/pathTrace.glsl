//-------------------------------------------------
// PATH-TRACING
// this is the main path tracing loop
//  used in main.glsl
//-------------------------------------------------

//vec3 pathTrace(inout Path path){
//
//    maxBounces=50;
//
//    for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
//    {
//
//        // shoot a ray out into the world
//        //when you hit a material, update path.dat accordingly
//        stepForward(path);
//
//        //pick up the colors you accrued along the way
//        //updateFromVolume(path);
//
//        //if you hit the sky: stop
//        if(path.dat.isSky){
//            updateFromSky(path);
//            break;
//        }
//
//        //run the focus helper (if turned on)
//        //focusCheck(path);
//
//        //set probabilities for spec, refract, diffuse
//        //use these probabilities to set the new ray
//        scatter(path);
//
//        //get any color from this surface interaction
//        updateFromSurface(path);
//
//        //probabilistically kill rays
//        //roulette(path);
//
//        //if killed ray, sample the light
//        if(!path.keepGoing){
//            break;
//        }
//
//    }
//
//    return path.pixel;
//
//}

vec3 pathTrace(Path path){

        maxBounces=50;

        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
        {

                stepForward(path);

                // if you hit the sky: stop
                if (path.dat.isSky){
                        updateFromSky(path);
                }

                scatter(path);

                updateFromSurface(path);

                //probabilistically kill rays
                roulette(path);

                if(!path.keepGoing){
                        break;
                }

        }
        return path.pixel;

}
