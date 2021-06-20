


//-------------------------------------------------
// The TRACING FUNCTION: ONE STEP IN THE SCENE
//-------------------------------------------------

float trace(inout Vector tv, inout localData dat){

    //copy the initial data

    Vector rayTV=tv;
    localData rayDat=dat;

    Vector rootTV=tv;
    localData rootDat=dat;

    //run each function
    float rayDist=raymarch(rayTV, rayDat);
    float rootDist=findRoot(rootTV,rootDat);

    //whichever hits an object first: use that one
    if(rayDist<rootDist){
        tv=rayTV;
        dat=rayDat;
        return rayDist;
    }

    else{
        tv=rootTV;
        dat=rootDat;
        return rootDist;
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

    localData dat;
    initializeData(dat);
    maxBounces=100;
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {

            // shoot a ray out into the world
            //when you hit a material, update dat accordingly
            path.distance=trace(path.tv,dat);
            
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
            
            //if killed ray, sample the light
            if(!path.keepGoing){
                break;
            }
            
        }

   return path.pixel;

}








