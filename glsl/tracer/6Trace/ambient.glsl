//-------------------------------------------------
// AMBIENT MEDIUM  (docs/material-system.md §5)
// open air as a scattering medium: fog, god rays, halos. Open air is region
// ID_NONE, so its medium is just mediumOf(ID_NONE) — the ONE medium the scene
// gives open air (a scene sets `ambient:`, the emitter makes mediumOf return it
// for ID_NONE and derives SCENE_AMBIENT_MEDIUM). There is no separate ambient
// vocabulary: this reads the SAME `path.medium` the interior walk does — which,
// while a ray travels open air, IS that ID_NONE medium. Engine default: vacuum,
// so the whole transport compiles away and no-ambient scenes are byte-identical.
//
// ambientTransport() is called by stepForward with the marched distance to the
// next surface: each leg competes an exponential free flight against it; a
// shorter flight ends the leg in a SCATTER event (absorb/emit over the leg,
// phase-blended new direction, roulette) and we march again. It returns the
// final leg's distance, with the ray moved to that leg's start. Legs starting
// inside an object are left alone (the regionAt != ID_NONE guard) — interiors
// keep their own media, which is what path.medium already holds there.
//-------------------------------------------------


float ambientTransport(inout Path path, float distance){

#ifndef SCENE_AMBIENT_MEDIUM
    return distance;   //vacuum: the surface wins every leg
#else

    //the open-air medium the ray is travelling: path.medium == mediumOf(ID_NONE)
    //whenever regionAt(pos) == ID_NONE (the guard below keeps us there)
    for(int leg = 0; leg < 64; leg++){
        if(regionAt(path.tv.pos) != ID_NONE){ return distance; }

        float flight = randomExponential(path.medium.mfp);
        if(flight >= distance){ break; }        //the surface wins this leg

        //scatter event: move there, picking up absorption + emission
        flow(path.tv, flight);
        path.pixel += path.light * path.medium.emit * flight;
        path.light *= exp(-path.medium.absorb * flight);

        float blur = path.medium.blur*path.medium.blur;
        path.tv = vNormalize(mix(path.tv, randomVector(path.tv.pos), blur));

        roulette(path);
        if(!path.keepGoing){ return 0.; }

        //march the new direction to the next surface
        distance = raytrace( path.tv, maxDist );
        distance = raymarch( path.tv, distance );
    }

    //absorption + emission over the final leg to the surface
    float last = min(distance, maxDist);
    path.pixel += path.light * path.medium.emit * last;
    path.light *= exp(-path.medium.absorb * last);

    return distance;
#endif

}
