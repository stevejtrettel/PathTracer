

//-------------------------------------------------
// The RAYMARCHING LOOP
//-------------------------------------------------




//-------------------------------------------------
// The RAYMARCHING LOOP
//-------------------------------------------------


void raymarch(inout Path path, inout localData dat){

    init_ellip(path.tv);
    

    float distToScene=0.;
    float totalDist=0.;
    
    //set if you are inside or outside
    float side=path.inside?-1.:1.;

        for (int i = 0; i < maxMarchSteps; i++){
            
            //for now still distance test with the Vector
            distToScene  = side*sceneSDF(path.tv,dat);
            totalDist += distToScene;
            
            if (distToScene< EPSILON){
                    //local data is set by the sdf
                    path.distance=totalDist;
                    return;
                }
            
            if(totalDist>maxDist){
                break;
            }
            
            //otherwise keep going
            path.tv=flow(path.tv, distToScene);
        }
    
    //if you hit nothing
    dat.isSky=true;
    path.keepGoing=false;
    path.distance=maxDist;
    
}








//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------



    void updateProbabilities( inout Path path,inout localData dat, inout uint rngState){
        
    
    //update the normal to be the correct direction:
    float side=(path.inside)?-1.:1.;
    Vector normal=multiplyScalar(side,dat.normal);
       
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
            path.inside ? dat.mat.IOR : 1.0,
            !path.inside ? dat.mat.IOR : 1.0,
            path.tv, normal, dat.mat.specularChance, 1.0);
         
        
        //--- update diffuse and refract accordingly
        
        float chanceMultiplier = (1.0f - specularChance) / (1.0f - dat.mat.specularChance);
        
        refractionChance = chanceMultiplier*dat.mat.refractionChance;
        diffuseChance = 
            1.-refractionChance-specularChance;
    }
     
    // calculate whether we are going to do a diffuse, specular, or refractive ray
        
    float raySelectRoll = RandomFloat01(rngState);
    if (specularChance > 0.0f && raySelectRoll < specularChance)
    {
        setSpecular(path.type,specularChance);
    }
    else if (refractionChance > 0.0f && raySelectRoll < specularChance + refractionChance)
    {
         setRefract(path.type,refractionChance);
    }
    else
    {
        setDiffuse(path.type, diffuseChance);
    }
     
    // numerical problems can cause ray Probability to become small enough to cause a divide by zero.
    path.type.probability = max(path.type.probability, 0.001f);
        
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

    //get the refracted ray direction from IOR
    Vector refractionDir = refract(path.tv, normal, path.inside ? dat.mat.IOR/1.0 : 1.0 / dat.mat.IOR);
    
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
    nudge(path.tv,multiplyScalar(side,normal));
   

    //----- change path.inside if refract ----------
    //if you reflect or diffuse you stay on same side
    if(path.type.refract==1.){
        path.inside=!path.inside;
    }
    
}









//-------------------------------------------------
// KILL DIM RAYS
//-------------------------------------------------



void roulette(inout Path path,inout uint rngState){

            // As the light left gets smaller, the ray is more likely to get terminated early.
            // Survivors have their value boosted to make up for fewer samples being in the average.
                  
            float p = max(path.light.r, max(path.light.g, path.light.b));
            if (RandomFloat01(rngState) > p){
                        path.keepGoing=false;
             }
             // Add the energy we 'lose' by randomly terminating paths
            path.light *= 1.0f / p;
    
}








//-------------------------------------------------
// The PATH TRACING LOOP
//-------------------------------------------------



void volumeColor(inout Path path,localData dat){
        if(path.inside){path.light *= exp(-dat.mat.absorbColor * 2.);}
}



void surfaceColor(inout Path path,localData dat){
    
        // add in emissive lighting
        path.pixel += path.light*dat.mat.emitColor ;
         
        // update the colorMultiplier
        //only do if not refractive (those taken care of with volume)
        if(path.type.refract==0.){
            //color choice depends on specular or diffuse
            path.light *= (path.type.specular==1.)?dat.mat.specularColor:dat.mat.diffuseColor;
        }
   
}


void skyColor(inout Path path,inout localData dat){
    //vec3 skyColor=skyTex(path.tv.dir);
    
    //vec3 p=normalize(path.tv.pos.coords);
    //vec3 skyColor=checkerTex(p);
    
    //vec3 skyColor=vec3(0.1,0.2,0.3);
   vec3 skyColor=vec3(0.);
    
    path.pixel += path.light*skyColor;
}



vec3 pathTrace(inout Path path, inout uint rngState){
    
    localData dat;
    initializeData(dat);
    maxBounces=3;
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {

            // shoot a ray out into the world
            //when you hit a material, update dat accordingly
            raymarch(path,dat);
            
            //if you hit the sky: stop
            if(dat.isSky){
                skyColor(path,dat);
               // break;
            }
            
           // pick up any colors absorbed
           // while traveling inside an object:
            volumeColor(path,dat);

    
            //set probabilities for spec, refract, diffuse
            updateProbabilities(path, dat, rngState);
            
            //use these probabilities to set the new ray
            updateRay(path, dat,rngState);    
                  
            //update the color from interacting with the surface
            surfaceColor(path,dat);
            
            //probabilistically kill rays
            roulette(path,rngState);
            
            //if killed ray,
            if(!path.keepGoing||dat.isSky){break;}
            
        }
    
  return path.pixel;

}







