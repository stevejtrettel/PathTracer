 #include <common>

uniform vec3 iResolution;
uniform float iTime;
uniform sampler2D sky;
uniform sampler2D skySM;
uniform sampler2D acc;
uniform float iFrame;

// constants
float eps=0.001;
int maxMarchSteps=300;
float maxDist=10.;
float distToViewer;
bool isSky=false;
float fov=100.;


vec3 pixelColor=vec3(0.);
vec3 lightColor=vec3(1.);
vec3 albedo;
vec3 emissive;

vec2 toSphCoords(vec3 v){
float theta=atan(-v.z,v.x);
float phi=acos(v.y);
return vec2(theta,phi);
}




vec3 skyTex(vec3 v){

vec2 angles=toSphCoords(v);
float x=(angles.x+3.1415)/(2.*3.1415);
float y=1.-angles.y/3.1415;

//return texture(skySM,vec2(x,y)).rgb;
return vec3(0.1);
}






vec3 LessThan(vec3 f, float value)
{
    return vec3(
        (f.x < value) ? 1.0f : 0.0f,
        (f.y < value) ? 1.0f : 0.0f,
        (f.z < value) ? 1.0f : 0.0f);
}


vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);
    
    return mix(
        pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
        rgb * 12.92f,
        LessThan(rgb, 0.0031308f)
    );
}

vec3 SRGBToLinear(vec3 rgb)
{   
    rgb = clamp(rgb, 0.0f, 1.0f);
    
    return mix(
        pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
        rgb / 12.92f,
        LessThan(rgb, 0.04045f)
	);
}















uint wang_hash(inout uint seed)
{
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}
 
float RandomFloat01(inout uint state)
{
    return float(wang_hash(state)) / 4294967296.0;
}
 
vec3 RandomUnitVector(inout uint state)
{
    float z = RandomFloat01(state) * 2.0f - 1.0f;
    float a = RandomFloat01(state) * 6.28;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}

















//tangent vector
struct Vector{
    vec3 pos;
    vec3 dir; 
};


//
//Vector add(Vector v, Vector w){
//    //this only makes sense if v and w are based at the same point
//    return Vector(v.pos, v.dir+w.dir);
//}
//
//Vector negate(Vector v){
//    return Vector(v.pos,-v.dir);
//}
//
//Vector sub(Vector v, Vector w){
//    return add(v,negate(w));
//}
//
//Vector normalize(inout Vector v){
//   return Vector(v.pos,normalize(v.dir));
//}
//
//Vector clone(Vector v){
//    return v;
//}
//
//float dot(Vector v, Vector w){
//    return dot(v.dir,w.dir);
//}
//
//float cosAng(Vector v, Vector w){
//    return dot(normalize(v),normalize(w));
//}
//
////small shift in the location of a point
//vec3 shiftPoint(vec3 p, vec3 v, float t){
//    return p+eps*v;
//}
//
//Vector shift(Vector tv, vec3 dir, float t){
//    return Vector(tv.pos+eps*dir,tv.dir);
//}


//actually flowing along a geodesic
void flow(inout Vector tv, float t){
    //flow distance t in direction tv
    tv.pos+=t*tv.dir;
}

void nudge(inout Vector v, vec3 dir){
    v.pos+=dir*0.01;
}


void nudge(inout Vector v, Vector offset){
    v.pos+=offset.dir*0.01;
}



struct Path{
    Vector tv;
    vec3 pixel;//pixel color
    vec3 light;//light along path
      bool specularRay;//what type of ray we are shooting
    float rayProbability;
};




Path initializePath(Vector tv){
    Path p;
    p.tv=tv;//set the initial direction
    p.pixel=vec3(0.);//set the pixel black
    p.light=vec3(1.);//set the light white
    
    return p;
}


struct Material{
    vec3 emit;
    vec3 diffuse;
    vec3 specular;
    float roughness;
    float IOR;
    float specularChance;
    float refractionChance;
    float specularPercent;
    
};




struct localData{
    Vector normal;
    Vector reflect;
    Vector refract;
    Material mat;
    bool isSky;
    float dist;
    bool fromInside;
};










//set the local data to the sky
void setSky(inout localData dat,Vector tv){
    dat.mat.diffuse=vec3(0.);
    dat.mat.emit=vec3(0.3);
        //SRGBToLinear(skyTex(tv.dir));
       // 0.5*vec3(53./255.,81./255.,92./255.);
}







float sphereSDF(Vector tv, vec3 center, float rad){
    //if you are looking away from the sphere, stop
   if(dot(tv.dir,tv.pos-center)>0.){return maxDist;}
    //else return distance to closest point
    return length(tv.pos-center)-rad;
}

Vector sphereNormal(Vector tv, vec3 center){
    return Vector(tv.pos,normalize(tv.pos-center));
}







float planeSDF(Vector tv, vec3 normal, float D){
    //does not need to be a unit normal vector
    //D is the constant in ax+by+cz+d=0
    if(dot(tv.dir,normal)>0.){return maxDist;}
    
    //otherwise give distance to closest point
   float d=dot(tv.pos,normal)+D;
   d= d/length(normal);
    return d;
}

Vector planeNormal(Vector tv,vec3 normal, float D){
    return Vector(tv.pos, normalize(normal));
}





//extra data
float sceneSDF(Vector tv, inout localData dat){
    
    
    //sphere 0
    vec3 center=vec3(0,-0.35,-2.);
    float dist= sphereSDF(tv, center,0.5);
    
    
    if(dist<eps){
        dat.isSky=false;
        dat.normal=sphereNormal(tv,center);
        dat.mat.diffuse=vec3(0.9f, 0.9f, 0.5f);
        dat.mat.emit=vec3(0.0);
        dat.mat.specular=vec3(0.9f, 0.9f, 0.9f); 
        dat.mat.specularPercent=0.3;
        dat.mat.roughness=0.2;
        dat.mat.IOR=1.;
        dat.mat.specularChance=0.3;
        dat.mat.refractionChance=0.3;
        return dist;
    }
    
    
        //sphere 1
    vec3 center1=vec3(-0.6,-0.63,-1.6);
    float dist1= sphereSDF(tv, center1,0.25);
    
    
    if(dist1<eps){
        dat.isSky=false;
        dat.normal=sphereNormal(tv,center1);
        dat.mat.diffuse=vec3(1.);
        dat.mat.emit=vec3(0.0);
        dat.mat.specular=vec3(0.9f, 0.9f, 0.9f); 
        dat.mat.specularPercent=0.2;
        dat.mat.roughness=0.3;
            dat.mat.IOR=1.;
                dat.mat.specularChance=0.3;
        dat.mat.refractionChance=0.3;
        return dist1;
    }

    dist1=min(dist,dist1);
    
    //the light source
    vec3 center2=vec3(.8,0.0,-0.5);
    float dist2=sphereSDF(tv, center2,0.1);
    
    if(dist2<eps){
        dat.isSky=false;
        dat.normal=sphereNormal(tv,center2);
        dat.mat.diffuse=vec3(0.,0.,0.);
        dat.mat.emit=vec3(1.0f, 0.9f, 0.7f) * 3.0f;
        dat.mat.specular=vec3(0.,0.,0.);
        dat.mat.specularPercent=0.;
        dat.mat.roughness=0.;
            dat.mat.IOR=1.;
                dat.mat.specularChance=0.3;
        dat.mat.refractionChance=0.;
        return dist2;
    }
    
    
    //floor
    vec3 pNormal=vec3(0,1,0.1);
        float dist3=planeSDF(tv, pNormal,1.);
    
    if(dist3<eps){
        dat.isSky=false;
        dat.normal=planeNormal(tv,pNormal,1.);
        dat.mat.diffuse=vec3(0.99f, 0.7f, 0.7f);
        dat.mat.emit=vec3(0.0);
        dat.mat.specular=vec3(0.);
        dat.mat.specularPercent=0.;
        dat.mat.roughness=0.;
            dat.mat.IOR=1.;
                dat.mat.specularChance=0.3;
        dat.mat.refractionChance=0.;
        return dist3;
    }
    

    
    
         pNormal=vec3(1,0,1);
        float dist4=planeSDF(tv, pNormal,5.);
    
    if(dist4<eps){
        dat.isSky=false;
        dat.normal=planeNormal(tv,pNormal,5.);
        dat.mat.diffuse=vec3(0.7,0.7,0.8);
        dat.mat.emit=vec3(0.0);
        dat.mat.specular=vec3(0.);
        dat.mat.specularPercent=0.;
        dat.mat.roughness=0.;
            dat.mat.IOR=1.;
                dat.mat.specularChance=0.3;
        dat.mat.refractionChance=0.;
        return dist4;
    }
    
    
        
         pNormal=vec3(0,0,1);
        float dist5=planeSDF(tv, pNormal,5.);
    
    if(dist5<eps){
        dat.isSky=false;
        dat.normal=planeNormal(tv,pNormal,5.);
        dat.mat.diffuse=vec3(0.5,0.9,0.5);
        dat.mat.emit=vec3(0.0);
        dat.mat.specular=vec3(0.);
        dat.mat.specularPercent=0.;
        dat.mat.roughness=0.;
            dat.mat.IOR=1.;
                dat.mat.specularChance=0.3;
        dat.mat.refractionChance=0.;
        return dist5;
    }
   // float dist4=maxDist;
    
    return min(min(min(dist1,dist2),min(dist3,dist4)),dist5);

}






float raymarch(inout Vector tv, inout localData dat){

    float toScene;
    float totalDist=0.;
    
    //default= you hit the sky
    dat.isSky=true;

        for (int i = 0; i < maxMarchSteps; i++){
            
               toScene  = sceneSDF(tv,dat);
           
                if (toScene < eps){
                    //local data is set by the sdf
                    return totalDist;
                }
            
           
            totalDist += toScene;
            if(totalDist>maxDist){
                //set local data
                setSky(dat,tv);
                return maxDist;
            }
            
            //otherwise keep going
            flow(tv, toScene);
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
    

    
}









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





vec3 pathTrace(inout Path path, inout uint rngState){
    
    localData dat;
    int maxBounces=10;
    
    
        for (int bounceIndex = 0; bounceIndex <maxBounces; ++bounceIndex)
    {
            //march to the next surface, pick up light contributions
            stepForward(path,dat,rngState);
            if(dat.isSky){break;}
            
                // Russian Roulette
            // As the light left gets smaller, the ray is more likely to get terminated early.
            // Survivors have their value boosted to make up for fewer samples being in the average.
            
            
                {
                    // since we chose randomly between diffuse and specular,
                    // we need to account for the times we didn't do one or the other.
                    path.light /= path.rayProbability;
                    
                    float p = max(path.light.r, max(path.light.g, path.light.b));
                    if (RandomFloat01(rngState) > p)
                        break;
 
                    // Add the energy we 'lose' by randomly terminating paths
                    path.light *= 1.0f / p;
                }

        }

    
    return path.pixel;
}











Vector initializeRay(vec2 fragCoord,inout uint rngState){
    
    // The ray starts at the camera position (the origin)
    vec3 rayPosition = vec3(0.0f, 0.0f, 0.0f);
    
    // calculate subpixel camera jitter for anti aliasing
    vec2 jitter = vec2(RandomFloat01(rngState), RandomFloat01(rngState)) - 0.5f;
    
     // calculate coordinates of the ray target on the imaginary pixel plane.
    vec2 planeCoords=((fragCoord+jitter)/iResolution.xy) * 2.0f - 1.0f;

    // correct for aspect ratio
    float aspectRatio = iResolution.x / iResolution.y;
    planeCoords.y /= aspectRatio;
    
    //move z-distance for fov:
    float z=-1./ tan(radians(fov * 0.5));
    
    // -1 to +1 on x,y axis. 1 unit away on the z axis
    vec3 rayTarget = vec3(planeCoords, z);
     

    // calculate a normalized vector for the ray direction.
    // it's pointing from the ray position to the ray target.
    vec3 rayDir = normalize(rayTarget);
    
    //combine into tangent vector
    Vector tv=Vector(rayPosition,rayDir);
    
    return tv;
    
}









//get the new frame
vec3 newFrame(vec2 fragCoord, inout uint rngState){
    
    //get the initial tangent vector, path data
    Vector tv=initializeRay(fragCoord,rngState);
    Path path=initializePath(tv);
    
    //do one trace out into the scene
    return pathTrace(path,rngState);
    
}


//call the previous frame from memory
vec4 prevFrame(vec2 fragCoord){
    return texture(acc, fragCoord / iResolution.xy);
}





void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   
    // initialize a random number state based on frag coord and frame
uint rngState = uint(uint(fragCoord.x) * uint(1973) + uint(fragCoord.y) * uint(9277) + uint(iFrame) * uint(26699)) | uint(1);
    
    //get new and old frames
    vec3 new=newFrame(fragCoord,rngState);
    new=clamp(new,0.,5.);
    
    vec4 prev=prevFrame(fragCoord);
    
     float blend =   (iFrame < 2. || prev.a == 0.0f) ? 1.0f :  1. / (1. + 1./prev.a);
    
    
    vec3 color = ((iFrame-1.)*prev.rgb+new)/(iFrame);

    //color=clamp(color,0.,1.);
   // vec3 color= ((iFrame-1.)*prev.rgb+new);
    
    // show the result
    fragColor = vec4(color, blend);
}
























  void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
  }
