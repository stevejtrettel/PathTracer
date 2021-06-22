

//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------


//takes in data after a raymarch, and chooses the type of ray which is cast next: diffuse, specular or refract
void setProbabilities( inout Path path){

    //always assume the normal is outward facing for the surface we are at
    Vector normal=path.dat.normal;

    float specularChance=path.dat.mat.specularChance;
    float refractionChance=path.dat.mat.refractionChance;
    float diffuseChance=1.0-specularChance-refractionChance;

    // calculate whether we are going to do a diffuse, specular, or refractive ray
    float raySelectRoll = randomFloat();
    if (raySelectRoll < specularChance)
    {
        setSpecular(path.type,specularChance);
        path.absorb=path.dat.reflectAbsorb;

    }
    else if (raySelectRoll < specularChance + refractionChance)
    {
        //this only runs if reflection is not 100%, which means we are not in the TIR situation
        setRefract(path.type,refractionChance);
        path.absorb=path.dat.refractAbsorb;
    }
    else
    {
        setDiffuse(path.type, diffuseChance);
        path.absorb=path.dat.reflectAbsorb;

    }

    // numerical problems can cause ray Probability to become small enough to cause a divide by zero.
    path.type.probability = max(path.type.probability, 0.001);

    //increase brightness of path chosen
    //to account for the energy not taken
    path.light /= path.type.probability;


}







void scatterRay(inout Path path){

    Vector normal=path.dat.normal;

    //----- get a uniformly distributed vector on the sphere ----------
    Vector randomSph=Vector(path.tv.pos,randomUnitVector());


    //----- update the ray direction ----------

    // Diffuse uses a normal oriented cosine weighted hemisphere sample.
    Vector diffuseDir= normalize(add(normal,randomSph));

    // Perfectly smooth specular uses the reflection ray.
    Vector specularDir=reflect(path.tv,normal);

    //roughness square for mixing
    float rough2=path.dat.mat.roughness * path.dat.mat.roughness;

    // Rough (glossy) specular lerps from the smooth specular to the rough diffuse by the material roughness squared
    specularDir = normalize(mix(specularDir, diffuseDir,rough2));

    Vector refractionDir;

    //get the refracted ray direction from IOR
    refractionDir = refract(path.tv, normal, path.dat.IOR);

    //update refraction ray based on roughness
    refractionDir = normalize(mix(refractionDir, negate(diffuseDir), rough2));





    Vector rayDir;
    if(path.type.specular){
        rayDir=specularDir;
    }
    else if(path.type.refract){
        rayDir=refractionDir;
    }
    else{
        rayDir=diffuseDir;
    }
    path.tv=rayDir;//use this direction

//    //choose which one of these we will actually be doing
//    //this is a weird way of doing it to avoid a 3-way if statement, unsure if this is necessary
//    Vector rayDir = mix(diffuseDir, specularDir, path.type.specular);
//    rayDir = mix(rayDir, refractionDir, path.type.refract);
//    path.tv=rayDir;//use this direction

    //THIS CODE BELOW SHOULD BE EQUIVALENT TO THE ABOVE, BUT ITS NOT...
    //    if(path.type.specular==1.){
    //        path.tv=specularDir;
    //    }
    //    else if(path.type.refract==1.){
    //        path.tv=refractionDir;
    //    }
    //    else{ path.tv=diffuseDir;}


    //----- update ray position ----------
    //which side to push the point: in or out rel the normal?
    float side=(path.type.refract)?-1.:1.;
    nudge(path.tv,multiplyScalar(side,normal),5.*EPSILON);

}



