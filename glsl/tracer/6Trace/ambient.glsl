//-------------------------------------------------
// AMBIENT MEDIUM  (docs/material-system.md §5)
// open air as a scattering medium: fog, god rays, halos. A scene opts in with
//     #define SCENE_AMBIENT_MEDIUM
//     float ambientMFP();      //scatter mean free path of open air
//     float ambientBlur();     //phase width: 0 = forward, 1 = isotropic
//     vec3  ambientAbsorb();   //Beer extinction of open air (1/length)
//     vec3  ambientEmit();     //volume emission of open air (1/length)
// (the functions may read scene knobs). Engine default: vacuum — the whole
// transport below compiles away, same hook pattern as indexField.
//
// ambientTransport() is called by stepForward with the marched distance to the
// next surface: each leg competes an exponential free flight against it; a
// shorter flight ends the leg in a SCATTER event (absorb/emit over the leg,
// phase-blended new direction, roulette) and we march again. It returns the
// final leg's distance, with the ray moved to that leg's start. Legs starting
// inside an object are left alone — interiors keep their own media.
//-------------------------------------------------


float ambientTransport(inout Path path, float distance){

#ifndef SCENE_AMBIENT_MEDIUM
    return distance;   //vacuum: the surface wins every leg
#else

    for(int leg = 0; leg < 64; leg++){
        if(inside_Object(path.tv)){ return distance; }

        float flight = randomExponential(ambientMFP());
        if(flight >= distance){ break; }        //the surface wins this leg

        //scatter event: move there, picking up absorption + emission
        flow(path.tv, flight);
        path.pixel += path.light * ambientEmit() * flight;
        path.light *= exp(-ambientAbsorb() * flight);

        float blur = ambientBlur()*ambientBlur();
        path.tv = vNormalize(mix(path.tv, randomVector(path.tv.pos), blur));

        roulette(path);
        if(!path.keepGoing){ return 0.; }

        //march the new direction to the next surface
        distance = raytrace( path.tv, maxDist );
        distance = raymarch( path.tv, distance );
    }

    //absorption + emission over the final leg to the surface
    float last = min(distance, maxDist);
    path.pixel += path.light * ambientEmit() * last;
    path.light *= exp(-ambientAbsorb() * last);

    return distance;
#endif

}
