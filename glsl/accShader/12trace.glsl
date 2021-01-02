
//-------------------------------------------------
// The RAYMARCHING LOOP
//-------------------------------------------------


float raymarch(Vector tv, inout localData dat){

    float distToScene=0.;
    float totalDist=0.;

    float factor=1.;
    float marchDist;
    

        for (int i = 0; i < maxMarchSteps; i++){
            
            distToScene =abs(sceneSDF(tv,dat));
            marchDist=factor*distToScene;
            
            if (distToScene< EPSILON){               
                    return totalDist;
                }
            
            totalDist += marchDist;
            
            if(totalDist>maxDist){
                break;
            }
            
            //otherwise keep going
            flow(tv, marchDist);
        }
    
    //if you hit nothing
    dat.isSky=true;
    return maxDist;
}












//-------------------------------------------------
// The IMPORTANCE SAMPLE
//-------------------------------------------------


//start off easy: just go after a fixed light in the scene
//update tangent vector to 
float importanceDir(inout Vector tv, Sphere sph,inout uint rngState){
    
    vec3 q=tv.pos.coords;
    vec3 p=sph.center.coords;
    
    vec3 rand=sph.radius*RandomUnitVector(rngState);
    
    
    //get the new direction
    vec3 dir=p-q+rand;
    float length=length(dir);
    dir=normalize(dir);
    
    tv.dir=dir;
    return length;
    
}


float lightArea(float distance, Sphere sph){
    float rad=atan(sph.radius,distance);
    return rad*rad;
}



void Sample(inout Path path, localData dat, Sphere sph, inout uint rngState){
    
    Vector sampleLight=path.tv;
    //starting where our tangent vector hit the surface, find the right direction
    float distToLight=importanceDir(sampleLight,sph,rngState);
    
    
    float cosFactor=clamp(dot(sampleLight,dat.normal),0.,1.);
    
    if(cosFactor>0.){
    
    //move towards the light
    nudge(sampleLight,dat.normal,0.01);
    
    float distToObj=raymarch(sampleLight,trashDat);
    
    if(distToObj<distToLight-sph.radius-0.5){
        return;
    }
    
    //otherwise, add the light color
    vec3 lightAmt=trashDat.mat.emitColor;
    
    lightAmt*=lightArea(distToLight,sph)/(4.*PI);
    lightAmt*=cosFactor;

    // add in emissive lighting
    path.pixel += path.light*lightAmt ;
    }
}





//-------------------------------------------------
// The FOCUS CHECK
//-------------------------------------------------

void focusCheck(inout Path path){

    if(abs(path.distance-focalLength)<0.5){
        path.pixel+=vec3(1.,0.,0.);
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
// The LIGHTING FUNCTIONS
//-------------------------------------------------



void volumeColor(inout Path path,localData dat){
            path.light *= exp(-path.absorb*path.distance);
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
    //vec3 skyColor=0.1*checkerTex(path.tv.dir);
    vec3 skyColor=vec3(0.05);
    path.pixel += path.light*skyColor;
}











//-------------------------------------------------
// The PATH TRACING LOOP
//-------------------------------------------------



vec3 pathTrace(inout Path path, inout uint rngState){
    
    Vector importanceSample;
    localData dat;
    initializeData(dat);
    maxBounces=50;
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {

            // shoot a ray out into the world
            //when you hit a material, update dat accordingly
            path.distance=raymarch(path.tv,dat);
            
            //if you hit the sky: stop
            if(dat.isSky){
                path.keepGoing=false;
                skyColor(path,dat);
                break;
            }
            
            //focusCheck(path);
            
                //================================
                //--- IMPORTANCE SAMPLING--------
//                Sample(path,dat,light1,rngState);
//                Sample(path,dat,light2,rngState); 
                //===============================
           
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
            
            //if killed ray, sample the light
            if(!path.keepGoing){
                break;
            }
            
        }

   return path.pixel;

}









//-------------------------------------------------
// The BI-DIRECTIONAL PATH TRACING LOOP
//-------------------------------------------------



vec3 BiDirPathTrace(inout Path path, inout uint rngState){
    
    localData dat;
    initializeData(dat);
    
    
    
    
    maxBounces=50;
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {

            // shoot a ray out into the world
            //when you hit a material, update dat accordingly
            path.distance=raymarch(path.tv,dat);
            
            //if you hit the sky: stop
            if(dat.isSky){
                path.keepGoing=false;
                skyColor(path,dat);
                break;
            }
            
            //focusCheck(path);
           
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







