//-------------------------------------------------
// PATH-TRACING
// this is the main path tracing loop
//  used in main.glsl
//-------------------------------------------------




//-------------------------------------------------
// Internal to this file:
// roulette kills dim rays
//-------------------------------------------------

void roulette(inout Path path){

    // As the light left gets smaller, the ray is more likely to get terminated early.
    // Survivors have their value boosted to make up for fewer samples being in the average.

    float p = max(path.light.r, max(path.light.g, path.light.b));
    if (randomFloat() > p){
        path.keepGoing=false;
    }
    // Add the energy we 'lose' by randomly terminating paths
    path.light *= 1.0f / p;

}










//-------------------------------------------------
// The PATH TRACING LOOP
//-------------------------------------------------



vec3 pathTrace(inout Path path){

    Vector importanceSample;
    localData dat;
    initializeData(dat);
    maxBounces=100;

    for (int bounceIndex = 0; bounceIndex <maxBounces; bounceIndex++)
    {

        // shoot a ray out into the world
        //when you hit a material, update dat accordingly
        path.distance=raymarch(path.tv,dat);

        //if you hit the sky: stop
        if(dat.isSky){
            skyColor(path,dat);
            break;
        }
        if(focusHelp){
            focusCheck(path);
        }
    path.pixel+=debug;
        // pick up any colors absorbed
        // while traveling inside an object:
        volumeColor(path,dat);

        //set probabilities for spec, refract, diffuse
        updateProbabilities(path, dat);

        //use these probabilities to set the new ray
        updateRay(path, dat);


        //update the color from interacting with the surface
        surfaceColor(path,dat);

        //probabilistically kill rays
        roulette(path);

        //if killed ray, sample the light
        if(!path.keepGoing){
            break;
        }

    }

    return path.pixel;

}




//
//vec3 pathTrace(inout Path path){
//
//    maxBounces=50;
//
//    for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
//    {
//
//        // shoot a ray out into the world
//        //when you hit a material, update dat accordingly
//        stepForward(path);
//
//        //pick up the colors you accrued along the way
//        updatePathFromVolume(path);
//
//        //if you hit the sky: stop
//        if(dat.isSky){
//            path.keepGoing=false;
//            skyColor(path);
//            break;
//        }
//
//        if(focusHelp){
//            focusCheck(path);
//        }
//
//        //set probabilities for spec, refract, diffuse
//        updateProbabilities(path);
//
//        //use these probabilities to set the new ray
//        updateRayDirection(path);
//
//        //get any color from this surface interaction
//        updatePathFromSurface(path);
//
//        //probabilistically kill rays
//        roulette(path);
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



