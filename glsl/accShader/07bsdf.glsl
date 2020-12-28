






//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------

    void updateRefraction(inout Material mat,float wavelength){
        
       // mat.IOR=mat.IOR-0.6*wavelength/1000.;

         mat.IOR=mat.IOR+100./(wavelength-350.);
    }





    void updateProbabilities( inout Path path,inout localData dat, inout uint rngState){
        
    
    //update the normal to be the correct direction:
    float side=(path.inside)?-1.:1.;
    Vector normal=multiplyScalar(side,dat.normal);

        
    //update the refractive index for the light wavelength:
    updateRefraction(dat.mat, path.wavelength);
       
    // take fresnel into account for specularChance and adjust other chances.
    // specular takes priority.
    // chanceMultiplier makes sure we keep diffuse / refraction ratio the same.
        
    float specularChance=dat.mat.specularChance;
    float refractionChance=dat.mat.refractionChance;
    float diffuseChance=1.-specularChance-refractionChance;

    //if there's a chance of specular
    //update all chances via fresnel
    if (dat.mat.specularChance > 0.0f)
    {
        specularChance = FresnelReflectAmount(
            path.inside ? dat.mat.IOR : path.mat.IOR,
            !path.inside ? dat.mat.IOR : path.mat.IOR,
            path.tv, normal, dat.mat.specularChance, 1.0);
         
        
        //--- update diffuse and refract accordingly
        
        float chanceMultiplier = (1.0f - specularChance) / (1.0f - dat.mat.specularChance);
        
        refractionChance = chanceMultiplier*dat.mat.refractionChance;
        diffuseChance = 
            1.-refractionChance-specularChance;
    }
//     
    // calculate whether we are going to do a diffuse, specular, or refractive ray
    float raySelectRoll = RandomFloat01(rngState);
    if (specularChance > 0.0f && raySelectRoll < specularChance)
    {
        setSpecular(path.type,specularChance);
        //do not change current mat: we stay in same material
    }
    else if (refractionChance > 0.0f && raySelectRoll < specularChance + refractionChance)
    {
         setRefract(path.type,refractionChance);
        //current mat changes as we moved:
        path.mat=dat.mat;
    }
    else
    {
        setDiffuse(path.type, diffuseChance);
        //current mat does not change, as we reflect
    }
     
    // numerical problems can cause ray Probability to become small enough to cause a divide by zero.
    path.type.probability = max(path.type.probability, 0.001);
        
    //increase brightness of path chosen
    //to account for the energy not taken
    //IS THIS RIGHT?!?!
    path.light /= path.type.probability;
        
        
    }







void updateRay(inout Path path, localData dat, inout uint rngState){
    

    //update the normal to be the correct direction:
    float side=(path.inside)?-1.:1.;
    Vector normal=multiplyScalar(side,dat.normal);
    
    
    //----- get a uniformly distributed vector on the sphere ----------
    Vector randomSph=Vector(path.tv.pos,RandomUnitVector(rngState));
    
    
    //----- update the ray direction ----------
    
    // Diffuse uses a normal oriented cosine weighted hemisphere sample.
    Vector diffuseDir= normalize(add(normal,randomSph));
        
    // Perfectly smooth specular uses the reflection ray.
    Vector specularDir=reflect(path.tv,normal);
    
    // Rough (glossy) specular lerps from the smooth specular to the rough diffuse by the material roughness squared
    specularDir = normalize(mix(specularDir, diffuseDir, dat.mat.roughness * dat.mat.roughness));

    Vector refractionDir;
    //if(inLiquid(path.tv)){
   //refractionDir=path.tv;   
   // }
    //else{
    //get the refracted ray direction from IOR
     refractionDir = refract(path.tv, normal, path.inside ? dat.mat.IOR/1.0 : 1.0 / dat.mat.IOR);
   // }
    
    //update refraction ray based on roughness
    refractionDir = normalize(mix(refractionDir, negate(diffuseDir), dat.mat.roughness * dat.mat.roughness));
    
    //choose which one of these we will actually be doing
    //this is a weird way of doing it to avoid a 3-way if statement, unsure if this is necessary
    Vector rayDir = mix(diffuseDir, specularDir, path.type.specular);
    rayDir = mix(rayDir, refractionDir, path.type.refract);
    
    //use this direction
    path.tv=rayDir;
   
    
    //----- update ray position ----------
    //which side to push the point: in or out rel the normal?
    side=(path.type.refract == 1.0f)?-1.:1.;
    nudge(path.tv,multiplyScalar(side,normal),0.003);
   

    //----- change path.inside if refract ----------
    //if you reflect or diffuse you stay on same side
    if(path.type.refract==1.){
        path.inside=!path.inside;
    }
    
}



