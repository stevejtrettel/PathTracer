



//-------------------------------------------------
// UPDATING THE PATH COLOR
// after each bounce these pick up color/attenuation from the medium
// just traversed, the surface just hit, or the sky. Called from
// pathTrace() in 6Trace/pathTrace.glsl.
//-------------------------------------------------


void updateFromVolume(inout Path path){

    vec3 beersLaw = path.absorb*path.distance;

    if(length(beersLaw)>0.0001){
        path.light *= exp( -beersLaw );
    }
}

//(subsurface volume emission + absorption now happen per step inside
//subSurfScatter() in 6Trace, so throughput decays with depth and roulette stays
//useful throughout the walk — there is no separate end-of-walk pass here.)


void updateFromSurface(inout Path path){

    //only do this if we are actually rendering the material
    if(path.dat.renderMaterial){

        //add in emissive lighting
        if (length(path.dat.surfEmit)>0.001){
            path.pixel += path.light * path.dat.surfEmit;
        }

        //pick up some surface color upon reflection
        if (path.type == 1){
            path.light *=  path.dat.surfDiffuse;
        }
        if (path.type == 2){
            path.light *=  path.dat.surfSpecular;
        }
        //crossing rays pick up the transmit tint — white (a strict no-op) for
        //volumes, where Beer's law owns the color; set on THIN surfaces
        //(lampshades, leaves) that have no interior to absorb in.
        if (path.type == 3){
            path.light *=  path.dat.transmitTint;
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



// (focus visualization retired from the path-trace loop — it now lives as a clean
// non-destructive debug lens: uDebugMode == 8, focus peaking. See debugPass.glsl.)



void roulette(inout Path path){

    // As the light left gets smaller, the ray is more likely to get terminated early.
    // Survivors have their value boosted to make up for fewer samples being in the average.

    // p MUST be capped at 1: survival probability is min(|light|,1), and the unbiased
    // boost is 1/that. Dividing by an uncapped p>1 (which never terminates) silently
    // DELETES energy — invisible while throughput stays <=1, but spectral tints start
    // near 4 in their dominant channel, so every spectral path was losing most of its
    // weight at the first roulette (wavelength-dependently: band centres lost most).
    float p = min(LInf_Norm(path.light), 1.);
    if (randomFloat() > p){
        path.keepGoing = false;
    }
    // Add the energy we 'lose' by randomly terminating paths
    if(p>0.001){
        path.light *= 1. / p;
    }
}



