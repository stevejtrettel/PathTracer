



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

//like updateFromVolume, but the medium can also emit along the walk
void updateFromSubSurf(inout Path path){

    vec3 beersLaw = path.absorb*path.distance;
    vec3 emitAmt = path.emit*path.distance;

    if(length(beersLaw)>0.0001){
        emitAmt *= exp( -beersLaw);
        path.light *= exp( -beersLaw );
    }

    if(length(emitAmt)>0.0001){
        path.pixel += path.light*emitAmt;
    }
}


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

    float p = LInf_Norm(path.light);
    if (randomFloat() > p){
        path.keepGoing = false;
    }
    // Add the energy we 'lose' by randomly terminating paths
    if(p>0.001){
        path.light *= 1. / p;
    }
}



