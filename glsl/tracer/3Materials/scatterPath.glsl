

//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------



void updateProbabilities( inout Path path ){

    //update using Fresnel
    if(path.dat.probSpecular!=0.){
        //always assume the normal is outward facing for the surface we are at
        Vector normal=path.dat.normal;

        float origSpec=path.dat.probSpecular;

        path.dat.probSpecular = FresnelReflectAmount(path.dat.IOR, path.tv, normal, origSpec, 1.0);

        //--- update diffuse and refract accordingly
        float chanceMultiplier = (1.0 - path.dat.probSpecular) / (1.0 - origSpec);

        path.dat.probRefract  *= chanceMultiplier;
        path.dat.probDiffuse = 1.-path.dat.probRefract-path.dat.probSpecular;
    }

}






void scatter( inout Path path){

    if(path.dat.renderMaterial){

        updateProbabilities(path);

        //random number we will use to select ray type
        float random=randomFloat();

        //----- useful vectors in the following computation ----------
        Vector normal=path.dat.normal;
        Vector randomDir=randomVector(path.tv.pos);
        Vector diffuseDir=vNormalize(add(normal, randomDir));
        Vector newDir;

        //------useful parameters--------
        float rough2=path.dat.surfRoughness * path.dat.surfRoughness;

        if (random<path.dat.probSpecular){

            //its a specular ray
            path.type=2;
            path.absorb=path.dat.reflectAbsorb;
            path.emit=path.dat.reflectEmit;
            path.subSurface=false;

            newDir=vReflect(path.tv, normal);
            newDir=vNormalize(mix(newDir, diffuseDir,rough2));

        }

        else if (random<path.dat.probRefract+path.dat.probSpecular){

            //its a refractive ray
            path.type=3;
            path.absorb=path.dat.refractAbsorb;
            path.emit=path.dat.refractEmit;
            path.subSurface=false;

            newDir=vRefract(path.tv, normal, path.dat.IOR);
            newDir=vNormalize(mix(newDir, negate(diffuseDir),rough2));

        }

        else {

            //its a diffuse ray

            //if the material subsurface scatters, enter it
            if(path.dat.subSurface){
                path.subSurface=true;
                path.type=3;//we are entering material
                path.absorb=path.dat.refractAbsorb;
                path.emit=path.dat.refractEmit;
                newDir=vRefract(path.tv, normal, path.dat.IOR);
            }

            else{
                //just reflect off in a random direction
                path.type=1;
                path.absorb=path.dat.reflectAbsorb;
                path.emit=path.dat.reflectEmit;
                newDir=diffuseDir;
            }

        }


        //NO 1/probability boost here: the lobe probabilities ARE the lobes' energy
        //fractions (updateProbabilities sets probSpecular to the Fresnel reflectance,
        //and the others share what remains), so the sampling weight and the lobe
        //energy cancel exactly — the throughput picks up only the lobe's colour in
        //updateFromSurface. Dividing by the probability double-counts the lobe energy
        //(a 1/F ~ 20x boost per specular event: glass glows white). The old uncapped
        //roulette happened to renormalize any throughput > 1 and masked this.

        //----set the new vector and push off the surface
        path.tv=newDir;
        flow(path.tv,10.*EPSILON);

    }

    else{
        //if we do not render the material:

        //we are passing through: so "refraction"
        path.type=3;
        path.absorb=path.dat.refractAbsorb;
        path.emit=path.dat.refractEmit;
        path.subSurface=false;

        //move ahead along our (unchanged) ray
        flow(path.tv,10.*EPSILON);
    }

}