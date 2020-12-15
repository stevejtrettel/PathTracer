

//-------------------------------------------------
// The RAYMARCHING LOOP
//-------------------------------------------------


float raymarch(inout Path path, inout localData dat){


    float distToScene=0.;
    float totalDist=0.;
    
    //set if you are inside or outside
    float side=path.inside?-1.:1.;

        for (int i = 0; i < maxMarchSteps; i++){
            
            distToScene  = side*sceneSDF(path.tv,dat);
            totalDist += distToScene;
            
            if (distToScene< EPSILON){
                    //local data is set by the sdf
                    return totalDist;
                }
            
            if(totalDist>maxDist){
                break;
            }
            
            //otherwise keep going
            flow(path.tv, distToScene);
        }
    
    //if you hit nothing
    dat.isSky=true;
    path.keepGoing=false;
    return maxDist;
}










//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------




float FresnelReflectAmount(float n1, float n2, Vector normal, Vector incident, float f0, float f90)
{
        //probably need to adjust normal vector depending on side
        
    
    
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



//    void updateProbabilities( inout Path path,inout localData dat, inout uint rngState){
//        
//        
//        float raySelectRoll = RandomFloat01(rngState);
//        
//        if(raySelectRoll<0.9){
//            setRefract(path.type,0.9);
//        }
//        
//        else if(raySelectRoll<0.999){
//           setSpecular(path.type,0.1);
//        }
//        
//        else{
//           setDiffuse(path.type,0.);
//        }
//        
//        path.type.rayProbability = max(path.type.rayProbability, 0.001f);
//        
//        //increase brightness of path chosen
//        //to account for the energy not taken
//        //IS THIS RIGHT?!?!
//       //path.light /= path.type.rayProbability;
//        
//    }


    void updateProbabilities( inout Path path,inout localData dat, inout uint rngState){
        
    // take fresnel into account for specularChance and adjust other chances.
    // specular takes priority.
    // chanceMultiplier makes sure we keep diffuse / refraction ratio the same.
        
    float specularChance;
    float refractChance;
    float diffuseChance;

    //if there's a chance of specular: update via Fresnel
    if (dat.mat.specularChance > 0.0f)
    {
        float oldSpecChance=dat.mat.specularChance;
        
        dat.mat.specularChance = FresnelReflectAmount(
            path.inside ? dat.mat.IOR : 1.0,
            !path.inside ? dat.mat.IOR : 1.0,
            path.tv, dat.normal, oldSpecChance, 1.0);
         
        float chanceMultiplier = (1.0f - dat.mat.specularChance) / (1.0f - oldSpecChance);
        dat.mat.refractionChance *= chanceMultiplier;
        //diffuseChance *= chanceMultiplier;
    }
     
    // calculate whether we are going to do a diffuse, specular, or refractive ray
        
    float raySelectRoll = RandomFloat01(rngState);
    if (dat.mat.specularChance > 0.0f && raySelectRoll < dat.mat.specularChance)
    {
        setSpecular(path.type,dat.mat.specularChance);
    }
    else if (dat.mat.refractionChance > 0.0f && raySelectRoll < dat.mat.specularChance + dat.mat.refractionChance)
    {
         setRefract(path.type,dat.mat.refractionChance);
    }
    else
    {
        setDiffuse(path.type, 1.0f - (dat.mat.specularChance + dat.mat.refractionChance));
    }
     
    // numerical problems can cause rayProbability to become small enough to cause a divide by zero.
    path.type.rayProbability = max(path.type.rayProbability, 0.001f);
        
    }







void updateRay(inout Path path, localData dat, inout uint rngState){
    

    //update the normal to be the correct direction:
    float side=(path.inside)?-1.:1.;
    vec3 normal=side*dat.normal.dir;
    
    //----- update the ray direction ----------
    
     // Diffuse uses a normal oriented cosine weighted hemisphere sample.
     vec3 diffuseDir = normalize(normal+RandomUnitVector(rngState));
    
    // Perfectly smooth specular uses the reflection ray.
    vec3 specularDir=reflect(path.tv.dir,normal);
    
    // Rough (glossy) specular lerps from the smooth specular to the rough diffuse by the material roughness squared
    // Squaring the roughness is just a convention to make roughness feel more linear perceptually.
    specularDir = normalize(mix(specularDir, diffuseDir, dat.mat.roughness * dat.mat.roughness));

    //get the refracted ray direction from IOR
    vec3 refractionDir = refract(path.tv.dir, normal, path.inside ? dat.mat.IOR : 1.0f / dat.mat.IOR);
    
    //update refraction ray based on roughness
    refractionDir = normalize(mix(refractionDir, -diffuseDir, dat.mat.roughness * dat.mat.roughness));
    
    //choose which one of these we will actually be doing
    //this is a weird way of doing it to avoid a 3-way if statement, unsure if this is necessary
    vec3 rayDir = mix(diffuseDir, specularDir, path.type.specular);
    rayDir = mix(rayDir, refractionDir, path.type.refract);
    
    //----- assemble the new tangent vector ----------
    //which side to push the point: in or out rel the normal?
    side=(path.type.refract == 1.0f)?-1.:1.;
    
    path.tv.pos+=0.01*side*normal;
    
    //direction is what was chosen above
    path.tv.dir=rayDir;
   
    
    //change inside if you refract:
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
        path.light *= exp(-dat.mat.refractionColor * path.distance);
}

void surfaceColor(inout Path path,localData dat){
    
        // add in emissive lighting
        path.pixel += path.light*dat.mat.emitColor ;
         
        // update the colorMultiplier
        //only do if not refractive (those taken care of with volume)
    path.light=vec3(1.);
    
//    
//    if(path.type.refract==0.){
//        //color choice depends on specular or diffuse
//        path.light *= (path.type.specular==1.)?dat.mat.specularColor:dat.mat.diffuseColor;
//    }
//    
}


void skyColor(inout Path path,localData dat){
    vec3 skyColor=SRGBToLinear(skyTex(path.tv.dir));
    path.pixel += path.light*skyColor;
}



vec3 pathTrace(inout Path path, inout uint rngState){
    
    localData dat;
    initializeData(dat);
    maxBounces=10;
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {

            // shoot a ray out into the world
            //when you hit a material, update dat accordingly
            path.distance=raymarch(path,dat);
            
            //if you hit the sky: stop
            if(dat.isSky){
                skyColor(path,dat);
                break;
            }
            
            //if you've arrived here by traveling inside
            //an object, pick up absorbed colors:
//            if(path.inside){
//                 volumeColor(path,dat);
//            }
    
            //set probabilities for spec, refract, diffuse
            updateProbabilities(path, dat, rngState);
            
            //use these probabilities to set the new ray
            updateRay(path, dat,rngState);    
                  
            //update the color from interacting with the surface
            surfaceColor(path,dat);
            
            //probabilistically kill rays
            roulette(path,rngState);
            
            //if killed ray,
            if(!path.keepGoing){break;}
            
        }

 //return path.debug;
   return path.pixel;
}







