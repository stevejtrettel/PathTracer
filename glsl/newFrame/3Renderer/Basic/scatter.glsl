

//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------

//takes in data after a raymarch, and chooses the type of ray which is cast next: diffuse, specular or refract
void updateProbabilities( inout Path path ){
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

}


void scatter( inout Path path ){

        Vector normal=path.dat.normal;

        //----- get a uniformly distributed vector on the sphere ----------
        Vector randomSph=Vector(path.tv.pos,randomUnitVector());

        //-----make diffuse direction-------------------
        path.tv=normalize(add(normal,randomSph));

        //----flow in this direction a bit to get off surface
        flow(path.tv,20.*EPSILON);
}




//void scatter( inout Path path ){
//
//
//    //update reflectivity,refractivity based on IOR and normal
//    updateProbabilities(path);
//
//    Vector normal=path.dat.normal;
//
//    //----- get a uniformly distributed vector on the sphere ----------
//    Vector randomSph=Vector(path.tv.pos,randomUnitVector());
//
//    //----- update the ray direction ----------
//
//    // Diffuse uses a normal oriented cosine weighted hemisphere sample.
//    Vector diffuseDir= normalize(add(normal,randomSph));
//
//    // Perfectly smooth specular uses the reflection ray.
//    Vector specularDir=reflect(path.tv,normal);
//
//    //roughness square for mixing
//   // float rough2=dat.mat.roughness * dat.mat.roughness;
//
//    // Rough (glossy) specular lerps from the smooth specular to the rough diffuse by the material roughness squared
//    //specularDir = normalize(mix(specularDir, diffuseDir,rough2));
//
//    Vector refractionDir;
//
//    //get the refracted ray direction from IOR
//    refractionDir = refract(path.tv, normal, path.dat.IOR);
//
//    //update refraction ray based on roughness
//    //refractionDir = normalize(mix(refractionDir, negate(diffuseDir), rough2));
//
//
//
//
//
//
//
//    //choose which one of these we will actually be doing
//    //this is a weird way of doing it to avoid a 3-way if statement, unsure if this is necessary
////    Vector rayDir = mix(diffuseDir, specularDir, path.type.specular);
////    rayDir = mix(rayDir, refractionDir, path.type.refract);
////    path.tv=rayDir;//use this direction
//
//    //THIS CODE BELOW SHOULD BE EQUIVALENT TO THE ABOVE, BUT ITS NOT...
//        if(path.type.specular){
//            path.tv=specularDir;
//        }
//        else if(path.type.refract){
//            path.tv=refractionDir;
//        }
//        else{ path.tv=diffuseDir;}
//
//    flow(path.tv,20.*EPSILON);
//    //----- update ray position ----------
//    //which side to push the point: in or out rel the normal?
//    //float side=-1.;
//   // float side=(path.type.refract == 1.0f)?-1.:1.;
//    //nudge(path.tv,multiplyScalar(side,normal),2.*EPSILON);

//}



