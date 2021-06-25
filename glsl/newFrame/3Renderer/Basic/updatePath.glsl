



//-------------------------------------------------
// The NEW FUNCTIONS
//-------------------------------------------------


void updateFromVolume(inout Path path){

    vec3 beersLaw = path.absorb*path.distance;

    if(length(beersLaw)>0.0001){
        path.light *= exp( -beersLaw );
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
        vec3 skyColor = skyTex(path.tv.dir);
        //vec3 skyColor=vec3(0.5);
        path.pixel += path.light*skyColor;
        path.keepGoing = false;
    }
}



void focusCheck(inout Path path){
    if(abs(path.distance-focalLength)<0.5&&focusHelp){
        path.pixel+=vec3(1.,0.,0.);
    }
}



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



