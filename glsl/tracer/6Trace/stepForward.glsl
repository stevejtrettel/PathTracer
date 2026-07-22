//-------------------------------------------------
// STEP FORWARD
// this is the basic step in path tracing
// start from one surface, move to the next intersection point
// and update the data appropriately
//-------------------------------------------------


void stepForward(inout Path path){

    if(inMedium(path.tv.pos)){
        //curved transport: inside a medium (n(x) != 1) the segment to the next
        //surface is a geodesic — the ODE marcher advances path.tv along it. Like the
        //straight branch it sets path.distance + isSky (or keepGoing=false on capture)
        //and leaves the shared segment-end tail below to us. inMedium() is always
        //false for scenes whose indexField()==1, so those are byte-identical.
        odeMarch(path);
        if(!path.keepGoing){ return; }   //captured/absorbed: no surface and no sky
    }
    else{
        //straight transport: raytrace gives the nearest analytic surface as a stop
        //distance, then raymarch the sdf up to it; move to the intersection point.
        float distance = raytrace( path.tv, maxDist );
        distance       = raymarch( path.tv, distance );

#ifdef SCENE_AMBIENT_MEDIUM
        //AMBIENT MEDIUM (docs/material-system.md §5): open air scatters. The
        //scene defines `#define SCENE_AMBIENT_MEDIUM` plus four hook functions
        //(they may read scene knobs):
        //    float ambientMFP();      scatter mean free path of open air
        //    float ambientBlur();     phase width: 0 = forward, 1 = isotropic
        //    vec3  ambientAbsorb();   Beer extinction of open air (1/length)
        //    vec3  ambientEmit();     volume emission of open air (1/length)
        //Each leg competes an exponential free flight against the distance to
        //the next surface; a shorter flight ends the leg in a SCATTER event
        //(absorb/emit over the leg, phase-blended new direction, roulette) and
        //we march again. Object interiors keep their own media: legs starting
        //inside an object are left alone.
        float legTotal = 0.;
        for(int amb = 0; amb < 64; amb++){
            if(inside_Object(path.tv)){ break; }
            float flight = randomExponential(ambientMFP());
            if(flight >= distance){ break; }        //the surface wins this leg

            //scatter event: move there, picking up absorption + emission
            flow(path.tv, flight);
            legTotal   += flight;
            path.pixel += path.light * ambientEmit() * flight;
            path.light *= exp(-ambientAbsorb() * flight);

            float blur = ambientBlur()*ambientBlur();
            path.tv = vNormalize(mix(path.tv, randomVector(path.tv.pos), blur));

            roulette(path);
            if(!path.keepGoing){ return; }

            //march the new direction to the next surface
            distance = raytrace( path.tv, maxDist );
            distance = raymarch( path.tv, distance );
        }
        //absorption + emission over the final leg (open air only)
        if(!inside_Object(path.tv)){
            float leg   = min(distance, maxDist);
            path.pixel += path.light * ambientEmit() * leg;
            path.light *= exp(-ambientAbsorb() * leg);
        }
#endif

        flow(path.tv, distance);
        path.distance  = distance;
#ifdef SCENE_AMBIENT_MEDIUM
        path.distance += legTotal;   //Beer via path.absorb sees the full path (air absorb rides above)
#endif
        path.dat.isSky = (distance > maxDist - 0.1);
    }

    //shared segment-end tail (both transports): accumulate the path length, and set
    //the impact data from the intersection unless we reached the sky.
    path.totalDistance += path.distance;
    if(!path.dat.isSky){ setData_Scene(path); }
}

