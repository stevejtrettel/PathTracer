//-------------------------------------------------
// UPDATING THE PATH COLOR
// after each bounce these pick up color/attenuation from the medium
// just traversed, the surface just hit, or the sky. Called from
// pathTrace() in 6Trace/pathTrace.glsl.
//-------------------------------------------------


void updateFromVolume(inout Path path){

    //a glowing medium adds light all along the segment, each bit of it dimmed by
    //the absorption between there and here: e(1-exp(-s d))/s, which is e*d as
    //s -> 0. (Scattering media bill their interior legs in the walk; this is
    //everything else — glass, the air, the last leg through fog.)
    if(length(path.medium.emit)>0.0001){
        vec3 s = path.medium.absorb;
        vec3 e = path.medium.emit;
        vec3 glow = mix(e*path.distance, e*(1.-exp(-s*path.distance))/max(s, vec3(1e-6)), step(vec3(1e-6), s));
        path.pixel += path.light * glow;
    }

    vec3 beersLaw = path.medium.absorb*path.distance;

    if(length(beersLaw)>0.0001){
        path.light *= exp( -beersLaw );
    }
}


//light given off by the surface just hit. Added BEFORE scatter(): the lobe choice
//can change the throughput (a rough metal's multi-bounce tints it) and a
//transmit into a scattering interior skips updateFromSurface entirely, and
//neither should touch what the surface itself emits toward us.
void emitFromSurface(inout Path path){
    if(path.dat.render && length(path.dat.surf.emit)>0.001){
        path.pixel += path.light * path.dat.surf.emit;
    }
}


void updateFromSurface(inout Path path){

    //only do this if we are actually rendering the material
    if(path.dat.render){

        //(emission was added before scatter: see emitFromSurface)

        //pick up the chosen lobe's tint — the ONLY place throughput changes at
        //a surface (the probabilities already carried the energy fractions).
        //Crossing rays pick up transmitTint: white (a no-op) for volumes, where
        //Beer's law owns the color; set on THIN surfaces (lampshades, leaves).
        if (path.type == 1){
            path.light *=  path.dat.surf.diffuse;
        }
        if (path.type == 2){
            path.light *=  path.dat.surf.specular;
        }
        if (path.type == 3){
            path.light *=  path.dat.surf.transmitTint;
        }

    }

}



void updateFromSky(inout Path path){
    if(path.dat.isSky){
        vec3 skyColor = getSky(path.tv.dir);
        path.pixel += path.light*skyColor;
        path.keepGoing = false;
    }
}



void roulette(inout Path path, float scale){

    // As the light left gets smaller, the ray is more likely to get terminated early.
    // Survivors have their value boosted to make up for fewer samples being in the average.

    // scale (0,1] forces survival below what the throughput alone would give — any
    // value is unbiased, since the boost divides by the same p. pathTrace passes
    // RR_TAIL past maxBounces to wind deep paths down instead of truncating them;
    // everyone else passes 1.

    // p MUST be capped at 1: survival probability is min(|light|,1), and the unbiased
    // boost is 1/that. Dividing by an uncapped p>1 (which never terminates) silently
    // DELETES energy — invisible while throughput stays <=1, but spectral tints start
    // near 4 in their dominant channel, so every spectral path was losing most of its
    // weight at the first roulette (wavelength-dependently: band centres lost most).
    float p = scale * min(LInf_Norm(path.light), 1.);
    if (randomFloat() > p){
        path.keepGoing = false;
    }
    // Add the energy we 'lose' by randomly terminating paths
    if(p>0.001){
        path.light *= 1. / p;
    }
}

void roulette(inout Path path){ roulette(path, 1.); }
