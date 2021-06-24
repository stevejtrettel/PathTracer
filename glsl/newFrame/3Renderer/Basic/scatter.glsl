

//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------

//takes in data after a raymarch, and chooses the type of ray which is cast next: diffuse, specular or refract
//void updateProbabilities( inout Path path ){
////
////    //always assume the normal is outward facing for the surface we are at
////    Vector normal=dat.normal;
////
////    // take fresnel into account for specularChance and adjust other chances.
////    // specular takes priority.
////    // chanceMultiplier makes sure we keep diffuse / refraction ratio the same.
//
//    float specularChance=path.dat.mat.specularChance;
//    float refractionChance=path.dat.mat.refractionChance;
//    float diffuseChance=1.0-specularChance-refractionChance;
//
////    //if there's a chance of specular
////    //update all chances via fresnel
////    //if (dat.mat.specularChance > 0.0)
////    //{
////    specularChance = FresnelReflectAmount(
////    dat.IOR,
////    path.tv, normal, dat.mat.specularChance, 1.0);
////
////
////    //--- update diffuse and refract accordingly
////
////    float chanceMultiplier = (1.0 - specularChance) / (1.0 - dat.mat.specularChance);
////
////    refractionChance = chanceMultiplier*dat.mat.refractionChance;
////    diffuseChance =
////    1.-refractionChance-specularChance;
////    //}
////    //
//    // calculate whether we are going to do a diffuse, specular, or refractive ray
//    float raySelectRoll = randomFloat();
//    if (raySelectRoll < specularChance)
//    {
//        setSpecular(path.type,specularChance);
//        path.absorb=path.dat.reflectAbsorb;
//
//    }
//    else if (raySelectRoll < specularChance + refractionChance)
//    {
//        //this only runs if reflection is not 100%, which means we are not in the TIR situation
//        setRefract(path.type,1.);
//        path.absorb=path.dat.refractAbsorb;
//    }
//    else
//    {
//        setDiffuse(path.type, diffuseChance);
//        path.absorb=path.dat.reflectAbsorb;
//
//    }
//
//    // numerical problems can cause ray Probability to become small enough to cause a divide by zero.
//    path.type.probability = max(path.type.probability, 0.001);
//
//    //increase brightness of path chosen
//    //to account for the energy not taken
//    //IS THIS RIGHT?!?!
//    path.light /= path.type.probability;
//

//}



void updateProbabilities( inout Path path ){
        //update using Fresnel
}

void scatter( inout Path path ){

        updateProbabilities(path);

        //random number we will use to select ray type
        float random=randomFloat();

        //----- useful vectors in the following computation ----------
        Vector normal=path.dat.normal;
        Vector randomDir=randomVector(path.tv.pos);
        Vector diffuseDir=normalize(add(normal,randomDir));
        Vector newDir;

        //------useful parameters--------
        float rough2=path.dat.surfRoughness * path.dat.surfRoughness;

        if(random<path.dat.probRefract){

            path.type=3;
            path.prob=path.dat.probRefract;

            newDir=refract(path.tv,normal,path.dat.IOR);
            newDir=normalize(mix(newDir, negate(diffuseDir),rough2));
        }

        else if(random<path.dat.probRefract+path.dat.probSpecular){
           //its a specular ray
            path.type=2;
            path.prob=path.dat.probSpecular;

            newDir=reflect(path.tv,normal);
            newDir=normalize(mix(newDir, diffuseDir,rough2));
        }

        else{
          //its a diffuse ray
            path.type=1;
            path.prob=path.dat.probDiffuse;
            newDir=diffuseDir;
        }


        //fix up the path probability:
        path.prob=max(path.prob,0.001);
        path.light /= path.prob;

        //----set the new vector and push off the surface
        path.tv=newDir;
        flow(path.tv,10.*EPSILON);
}