

//-------------------------------------------------
// The RAYMARCHING LOOP
//-------------------------------------------------


float raymarch(inout Vector tv, inout localData dat){


    float distToScene;
    float totalDist=0.;

        for (int i = 0; i < maxMarchSteps; i++){
            
               distToScene  = sceneSDF(tv,dat);
           
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








void updateRayDirection(inout Path path, localData dat, inout uint rngState){
    
    
    

    
        // calculate new diffuse ray direction, in a cosine weighted hemisphere oriented at normal
        vec3 diffuseDir = normalize(dat.normal.dir+RandomUnitVector(rngState));
    
    //calculate the specular direction
        vec3 specularDir=reflect(path.tv.dir,dat.normal.dir);
        specularDir = normalize(mix(specularDir, diffuseDir, dat.mat.roughness * dat.mat.roughness));
    
    
        //decide if the new ray is going to be specular or diffuse:
    
    
    // apply fresnel
float specularChance = dat.mat.specularPercent;
if (specularChance > 0.0f)
{
    specularChance = FresnelReflectAmount(
        1.0,
        dat.mat.IOR,
        path.tv, dat.normal, dat.mat.specularPercent, 1.0f);  
}
       
// calculate whether we are going to do a diffuse or specular reflection ray 
    
     path.specularRay=(RandomFloat01(rngState) < specularChance);
    

      // get the probability for choosing the ray type we chose
path.rayProbability = path.specularRay ? specularChance : 1.0f - specularChance;
         
// avoid numerical issues causing a divide by zero, or nearly so (more important later, when we add refraction)
path.rayProbability = max(path.rayProbability, 0.001f);     
    
    
    
    
    
        vec3 rayDir = path.specularRay?specularDir:diffuseDir;
            
    
    
        //update the tangent vector:
        nudge(path.tv,dat.normal);
        path.tv.dir=rayDir;
    

            // since we chose randomly between diffuse and specular,
                    // we need to account for the times we didn't do one or the other.
                    path.light /= path.rayProbability;
    
}






//-------------------------------------------------
// MAKE ONE STEP FORWARD
//-------------------------------------------------


//march in direction of tv until you hit an object, do color computations at that object
void stepForward(inout Path path,inout localData dat,inout uint rngState){
    
     // shoot a ray out into the world
        float dist=raymarch(path.tv,dat);
    
    
        //get the new direction we are going to march in
        // set the pixel colors appropriately based on ray choice
        updateRayDirection(path,dat,rngState);
    
    
         
        // add in emissive lighting
        path.pixel += dat.mat.emit * path.light;
         
        // update the colorMultiplier
    //if specular ray; give specular color.  if diffuse raym diffuse color
        path.light *= path.specularRay?dat.mat.specular:dat.mat.diffuse;

}






//-------------------------------------------------
// KILL DIM RAYS
//-------------------------------------------------



void roulette(inout Path path,inout uint rngState){
    
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
    
    localData dat;
    int maxBounces=10;
    
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {

            //march to the next surface, pick up light contributions
            stepForward(path,dat,rngState);
            
            //probabilistically kill rays
            roulette(path,rngState);
            
            //if hit sky or killed ray,
            if(dat.isSky||!path.keepGoing){break;}
            
            
        }

    
    return path.pixel;
}







