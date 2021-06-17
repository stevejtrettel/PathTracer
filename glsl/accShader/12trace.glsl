
//-------------------------------------------------
// The RAYMARCHING LOOP: FOR SDFS
//-------------------------------------------------


float raymarch(inout Vector tv, inout localData dat){

    float distToScene=0.;
    float totalDist=0.;

    float factor=0.8;
    float marchDist;

    Vector temp=tv;

        for (int i = 0; i < maxMarchSteps; i++){
            
            distToScene =abs(sceneSDF(temp,dat));
            marchDist=factor*distToScene;
            
            if (distToScene< EPSILON){
                    flow(tv,totalDist);
                    return totalDist;
                }
            
            totalDist += marchDist;
            
            if(totalDist>maxDist){
                break;
            }
            
            //otherwise keep going
            flow(temp, marchDist);
        }
    
    //if you hit nothing
    dat.isSky=true;
    flow(tv,maxDist);
    return maxDist;
}




//-------------------------------------------------
// The ROOTFINDING LOOP: FOR VARIETIES
//-------------------------------------------------


float sexticEqn(vec3 pos){

    float scale=1.;
    vec3 center=vec3(0,0,0);

    float x=scale*(pos.x-center.x);
    float y=scale*(pos.y-center.y);
    float z=scale*(pos.z-center.z);

    float t = 1.618034;
    return 4.*(t*t*x*x - y*y ) * ( t*t *y*y - z*z ) *( t*t* z*z - x*x )
    - ( 1. + 2.*t) *(x*x + y*y + z*z- 1.)*(x*x + y*y + z*z- 1.);
}

float variety(Vector tv){
    return sexticEqn(tv.pos.coords.xyz);
}


vec3 gradient(Vector tv){

    vec3 pos=tv.pos.coords.xyz;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=sexticEqn( pos + e.xyy*ep);
    float vyyx=sexticEqn( pos + e.yyx*ep);
    float vyxy=sexticEqn( pos + e.yxy*ep);
    float vxxx=sexticEqn( pos + e.xxx*ep);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    return normalize(dir);
}



float setStepSize(Vector tv){

    float dist=abs(variety(tv));

    if(dist>10.){
        return 0.1;
    }
    else{
        return 0.01;
    }
}


bool changeSign(Vector u, Vector v){
    float x=variety(u);
    float y=variety(v);
    if(x*y<0.){
        return true;
    }
    return false;
}


void binarySearch(inout Vector tv,inout float dt){
    //given that you just passed changed sign, find the root
    float dist=0.;
    //flowing dist from tv doesnt hit the plane, dist+dt does:
    float testDist=dt;
    Vector temp;
    for(int i=0;i<10;i++){

        //divide the step size in half
        testDist=testDist/2.;

        //test flow by that amount:
        temp=tv;
        flow(temp, dist+testDist);
        //if you are still above the plane, add to distance.
        if(!changeSign(temp,tv)){
            dist+=testDist;
        }
        //if not, then don't add: divide in half and try again

    }

    //step tv ahead by the right ammount;
    flow(tv,dist);

}




float findRoot(inout Vector tv, inout localData dat){

    float marchStep = 0.;
    float depth=0.;
    float dt;

    Vector temp=tv;
    vec3 dir;
    Vector normal;
    float side;
    float boundingBox=20.;

    for (int i = 0; i < 300; i++){

        //determine how far to test flow from current location
        dt=setStepSize(tv);

        //temporarily step forward that distance along the ray
        temp=tv;
        flow(temp,dt);

        //check if we crossed the surface:f
        if(changeSign(temp,tv)){
            //set side based on orig position:
            side=variety(tv);

            //use a binary search to give exact intersection
            binarySearch(tv,dt);

            //set all the data:
            dir=gradient(tv);
            normal=Vector(tv.pos,dir);

            setSurfaceInAir(dat,side,normal,ball2.mat);
            return depth+dt;
        }

        //if we didn't cross the surface, move tv ahead by this step
        tv=temp;
        //increase the total distance marched
        depth+=dt;
        if(length(tv.pos.coords.xyz)>10.){
            break;
        }
    }

    //hit nothing
    dat.isSky=true;
    flow(tv,maxDist);
    return maxDist;
}








//
//float findRoot(inout Vector tv, inout localData dat){
//    return 500.;
//}
//




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
    maxBounces=50;
    
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








