//-------------------------------------------------
// Sample Other Material
//-------------------------------------------------

//this is kind of a hacky way to get the material on the other side.....

void otherSideMat(Path path,inout localData dat){
    //reverse the normal vector so its pointing inwards
    Vector normal=negate(dat.normal);
    
    //nudge tv in the direction of the normal
    nudge(path.tv,normal,EPSILON);
    
    float d=sceneSDF(path,trashDat);
    
    dat.otherMat=trashDat.mat;
}




//-------------------------------------------------
// The RAYMARCHING LOOP
//-------------------------------------------------


void raymarch(inout Path path, inout localData dat){


    float distToScene=0.;
    float totalDist=0.;
    Vector trashTV;
    
    //set if you are inside or outside
    float side=path.inside?-1.:1.;

        for (int i = 0; i < maxMarchSteps; i++){
            
            distToScene  = side*sceneSDF(path,dat);
            totalDist += distToScene;
            
            if (distToScene< EPSILON){
                    //march forward by epsilon to get onto the other side:
                    otherSideMat(path,dat);
      
                    //local data is set by the sdf
                    path.distance=totalDist;
                    return;
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
    path.distance=maxDist;
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
    vec3 skyColor=skyTex(path.tv.dir);
    //vec3 skyColor=0.1*checkerTex(path.tv.dir);
    //vec3 skyColor=vec3(0.1);
    path.pixel += path.light*skyColor;
}



vec3 pathTrace(inout Path path, inout uint rngState){
    
    localData dat;
    initializeData(dat);
    maxBounces=50;
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {

            // shoot a ray out into the world
            //when you hit a material, update dat accordingly
            raymarch(path,dat);
            
            //if you hit the sky: stop
            if(dat.isSky){
                skyColor(path,dat);
                break;
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







