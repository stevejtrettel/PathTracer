

//-------------------------------------------------
// The RAYMARCHING LOOP
//-------------------------------------------------


float raymarch(inout Vector tv, inout localData dat){


    float distToScene;
    float totalDist=0.;
    float side=dat.inside?-1.:1.;

        for (int i = 0; i < maxMarchSteps; i++){
            
               distToScene  = side*sceneSDF(tv,dat);
           
                if (distToScene < eps){
                    //local data is set by the sdf
                    return totalDist;
                }
            
           
            totalDist += distToScene;
            if(totalDist>maxDist){
                break;
            }
            
            //otherwise keep going
            flow(tv, distToScene);
        }
    
    //if you hit nothing
    setSky(dat,tv);
    return maxDist;
}










//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------




float FresnelReflectAmount(float n1, float n2, Vector normal, Vector incident, float f0, float f90)
{
        // Schlick aproximation
        float r0 = (n1-n2) / (n1+n2);
        r0 *= r0;
        float cosX = -dot(normal.dir, incident.dir);
        if (n1 > n2)
        {
            float n = n1/n2;
            float sinT2 = n*n*(1.0-cosX*cosX);
            // Total internal reflection
            if (sinT2 > 1.0)
                return f90;
            cosX = sqrt(1.0-sinT2);
        }
        float x = 1.0-cosX;
        float ret = r0+(1.0-r0)*x*x*x*x*x;
 
        // adjust reflect multiplier for object reflectivity
        return mix(f0, f90, ret);
}







    void updateProbabilities( inout Path path,inout localData dat, out float doSpecular, out float doRefraction,inout uint rngState){
        
    // take fresnel into account for specularChance and adjust other chances.
    // specular takes priority.
    // chanceMultiplier makes sure we keep diffuse / refraction ratio the same.

        
    //if there's a chance of specular: update via Fresnel
    if (dat.mat.specularChance > 0.0f)
    {
        float oldSpecChance=dat.mat.specularChance;
        
        dat.mat.specularChance = FresnelReflectAmount(
            dat.inside ? dat.mat.IOR : 1.0,
            !dat.inside ? dat.mat.IOR : 1.0,
            path.tv, dat.normal, oldSpecChance, 1.0);
         
        float chanceMultiplier = (1.0f - dat.mat.specularChance) / (1.0f - oldSpecChance);
        dat.mat.refractionChance *= chanceMultiplier;
        //diffuseChance *= chanceMultiplier;
    }
     
    // calculate whether we are going to do a diffuse, specular, or refractive ray
        
    //zero out our inputs;
    doSpecular = 0.0f;
    doRefraction = 0.0f;
        
    float raySelectRoll = RandomFloat01(rngState);
    if (dat.mat.specularChance > 0.0f && raySelectRoll < dat.mat.specularChance)
    {
        doSpecular = 1.0f;
        path.rayProbability = dat.mat.specularChance;
    }
    else if (dat.mat.refractionChance > 0.0f && raySelectRoll < dat.mat.specularChance + dat.mat.refractionChance)
    {
        doRefraction = 1.0f;
        path.rayProbability = dat.mat.refractionChance;
    }
    else
    {
        path.rayProbability = 1.0f - (dat.mat.specularChance + dat.mat.refractionChance);
    }
     
    // numerical problems can cause rayProbability to become small enough to cause a divide by zero.
    path.rayProbability = max(path.rayProbability, 0.001f);
        
    }





void updateRay(inout Path path, inout localData dat,float doSpecular, float doRefraction,inout uint rngState){
    
    
    //----- update the ray position ----------
    if (doRefraction == 1.0f)
    {
        //push into the material
       nudge(path.tv,negate(dat.normal));
    }
    else
    {
        //push off of the material
       nudge(path.tv,dat.normal);
    }
      
    
    
    //----- update the ray direction ----------
    
     // Diffuse uses a normal oriented cosine weighted hemisphere sample.
     vec3 diffuseDir = normalize(dat.normal.dir+RandomUnitVector(rngState));
    
    
    // Perfectly smooth specular uses the reflection ray.
    vec3 specularDir=reflect(path.tv.dir,dat.normal.dir);
    
    // Rough (glossy) specular lerps from the smooth specular to the rough diffuse by the material roughness squared
    // Squaring the roughness is just a convention to make roughness feel more linear perceptually.
    specularDir = normalize(mix(specularDir, diffuseDir, dat.mat.roughness * dat.mat.roughness));
    

    //get the refracted ray direction from IOR
    vec3 refractionDir = refract(path.tv.dir, dat.normal.dir, dat.inside ? dat.mat.IOR : 1.0f / dat.mat.IOR);
    
    //update refraction ray based on roughness
    refractionDir = normalize(mix(refractionDir, -diffuseDir, dat.mat.roughness * dat.mat.roughness));
    
    
    //choose which one of these we will actually be doing
    //this is a weird way of doing it to avoid a 3-way if statement, unsure if this is necessary
    vec3 rayDir = mix(diffuseDir, specularDir, doSpecular);
    //rayDir = mix(rayDir, refractionDir, doRefraction);
    
    
    
    //----- assemble the new tangent vector ----------
    //position was already nudged above
    path.tv.dir=rayDir;
    
}









//-------------------------------------------------
// KILL DIM RAYS
//-------------------------------------------------



void roulette(inout Path path,inout uint rngState){
        // since we chose randomly between diffuse and specular,
    // we need to account for the times we didn't do one or the other.
    //DONT KNOW IF THIS GOES RIGHT HERE?
   path.light /= path.rayProbability;
    
               // Russian Roulette
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


vec3 pathTrace(inout Path path, inout uint rngState){
    float dist;
    
    localData dat;
    float doSpecular, doRefraction;
    initializeData(dat);
    
    int maxBounces=10;
    
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {

            // shoot a ray out into the world
            dist=raymarch(path.tv,dat);
            
            
            
            //if you've arrived here by traveling inside
            //an object, pick up absorbed colors:
            if(dat.inside){
                path.light *= exp(-dat.mat.refractionColor * dist);
            }
    
    
            //set probabilities for spec, refract, diffuse
            updateProbabilities(path, dat, doSpecular, doRefraction, rngState);
            
            //use these probabilities to set the new ray
            updateRay(path, dat, doSpecular, doRefraction,rngState);    
                  
    
            // add in emissive lighting
            path.pixel += dat.mat.emitColor * path.light;
         
            // update the colorMultiplier
            //depends on if its a specular ray (set in update)
            path.light *= path.specularRay?dat.mat.specularColor:dat.mat.diffuseColor;

            
            //probabilistically kill rays
            roulette(path,rngState);
            
            //if hit sky or killed ray,
            if(dat.isSky||!path.keepGoing){break;}
            
            
        }

    
    return path.pixel;
}







