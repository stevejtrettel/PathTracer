uint seed;

uint randomSeed(vec2 fCoord,float frame){
    uint seed = uint(uint(fCoord.x) * uint(1973) +
    uint(fCoord.y) * uint(925277) + uint(frame) * uint(26699))
    | uint(1);
    return seed;
}

uint wang_hash(){
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}

float randomFloat(){
    return float(wang_hash()) / 4294967296.0;
}

vec3 randomUnitVec3(){
    float z = randomFloat() * 2.0f - 1.0f;
    float a = randomFloat() * 6.28;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}

float randomExponential(float mean){
    float u = randomFloat();
    float x = - mean * log(1.-u);
    return x;
}

vec3 skyTex(vec3 v){ return vec3(0.); }

uniform vec3 iResolution;
uniform mat3 facing;
uniform vec3 location;
uniform float frameSeed;
uniform float aperture;
uniform float focalLength;
uniform float fov;

float PI=3.1415926;
float EPSILON=0.001;
int maxMarchSteps=2000;
float maxDist=55.;
int maxBounces=50;

struct Camera{
    vec3 pos;
    mat3 facing;
    float fov;
    float aperture;
    float focalLength;
};

Camera buildCamFromUniforms(){
    Camera cam;
    cam.pos=location;
    cam.facing=facing;
    cam.fov=fov;
    cam.aperture=aperture;
    cam.focalLength=focalLength;
    return cam;
}

Vector initializeRay(vec2 fragCoord,float FOV){
    vec3 rayPosition = ORIGIN;
    vec2 jitter = vec2(randomFloat(), randomFloat()) - 0.5f;
    vec2 planeCoords=((fragCoord+jitter)/iResolution.xy) * 2.0f - 1.0f;
    float aspectRatio = iResolution.x / iResolution.y;
    planeCoords.y /= aspectRatio;
    float z=-1./ tan(radians(FOV * 0.5));
    vec3 rayTarget = vec3(planeCoords, z);
    vec3 rayDir = normalize(rayTarget);
    Vector tv=Vector(rayPosition,rayDir);
    return tv;
}

vec2 sampleAperture(Camera cam){
    float theta=2.*PI*randomFloat();
    float radius=cam.aperture*sqrt(randomFloat());
    vec2 offset=radius*vec2(cos(theta),sin(theta));
    return offset;
}

Vector cameraRay(vec2 fragCoord, Camera cam){
    vec3 startPos=vec3(-2,0,6);
    Vector tv=initializeRay(fragCoord,cam.fov);
    vec3 focalPt=tv.pos+cam.focalLength*tv.dir;
    vec2 offset=sampleAperture(cam);
    vec3 pos=tv.pos;
    pos.xy+=offset;
    vec3 dir=normalize(focalPt-pos);
    tv=Vector(pos,dir);
    tv.pos=facing*tv.pos;
    tv.pos+=cam.pos+startPos;
    tv=rotateByFacing(tv,cam.facing);
    return tv;
}

vec3 ORIGIN=vec3(0,0,0);

struct Vector{ vec3 pos; vec3 dir; };

Vector randomVector(vec3 pos)
{ return Vector(pos,randomUnitVec3()); }

Vector add(Vector v, Vector w)
{ return Vector(v.pos, v.dir+w.dir); }

Vector negate(Vector v)
{ return Vector(v.pos,-v.dir); }

Vector sub(Vector v, Vector w)
{ return add(v,negate(w)); }

Vector multiplyScalar(float a,Vector v)
{ return Vector(v.pos, a * v.dir); }

Vector mix(Vector v, Vector w, float x)
{ return Vector(v.pos,mix(v.dir,w.dir,x)); }

void nudge(inout Vector v, vec3 dir,float amt)
{ v.pos+=dir*amt; }

void nudge(inout Vector v, Vector offset,float amt)
{nudge(v,offset.dir,amt); }

float vDot(Vector v, Vector w)
{ return dot(v.dir,w.dir); }

float vNorm(Vector v)
{ return sqrt(vDot(v,v)); }

Vector vNormalize(Vector v)
{ return multiplyScalar(1./vNorm(v),v); }

float cosAng(Vector v, Vector w)
{ return vDot(vNormalize(v),vNormalize(w)); }

void flow(inout Vector tv, float t)
{ tv.pos += t*tv.dir; }

Vector vReflect(Vector v, Vector n)
{ return add(multiplyScalar(-2.0 * vDot(v, n), n), v); }

Vector vRefract(Vector incident, Vector normal, float n){
    float cosX=-vDot(normal, incident);
    float sinT2=n*n* (1.0 - cosX * cosX);
    if (sinT2>1.){
        return Vector(incident.pos,vec3(0.,0.,0.));
    }
    float cosT=sqrt(1.0 - sinT2);
    vec3 dir=n*incident.dir+(n * cosX - cosT) * normal.dir;
    return Vector(incident.pos, dir);
}

float FresnelReflectAmount(float n, Vector normal, Vector incident, float f0, float f90){
    float r0 = (n-1.)/(n+1.);
    r0 *= r0;
    float cosX = -vDot(normal, incident);
    if (n>1.){
        float sinT2 = n*n*(1.0-cosX*cosX);
        if (sinT2 > 1.0){ return f90; }
        cosX = sqrt(1.0-sinT2);
    }
    float x = 1.0-cosX;
    float ret = clamp(r0+(1.0-r0)*x*x*x*x*x,0.,1.);
    return  f0 + (f90-f0)*ret;
}

struct Material{
    bool render;
    bool subSurface;
    vec3 surfaceEmit;
    vec3 diffuseColor;
    vec3 specularColor;
    vec3 diffuseColorBack;
    vec3 specularColorBack;
    vec3 absorbColor;
    vec3 emitColor;
    float roughness;
    float isotropicScatter;
    float meanFreePath;
    float IOR;
    float specularChance;
    float refractionChance;
};

Material makeMetal(vec3 color, float specularity, float roughness){
    Material mat;
    mat.diffuseColor=color;
    mat.specularColor=vec3(2.)+0.8*color;
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;
    return mat;
}

Material makeDielectric(vec3 color, float specularity, float roughness){
    Material mat;
    mat.diffuseColor=color;
    mat.specularColor=vec3(0.9);
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;
    return mat;
}

Material air(vec3 absorbColor){
    Material mat;
    mat.render=false;
    mat.absorbColor=absorbColor;
    return mat;
}

Material makeGlass(vec3 color, float IOR,float specularity){
    Material mat;
    mat.render=true;
    mat.specularColor=vec3(1.);
    mat.diffuseColor=vec3(1.);
    mat.absorbColor=vec3(color);
    mat.IOR=IOR;
    mat.refractionChance=refractivity;
    float remainder=1.-refractivity;
    mat.specularChance=0.9*remainder;
    return mat;
}

Material makeLight(vec3 color,float intensity){
    Material mat;
    mat.surfaceEmit=intensity*color;
    return mat;
}

struct localData{
    bool isPhysical;
    bool isSky;
    bool renderMaterial;
    float side;
    bool subSurface;
    float meanFreePath;
    float isotropicScatter;
    vec3 surfDiffuse;
    vec3 surfSpecular;
    vec3 surfEmit;
    float surfRoughness;
    float probDiffuse;
    float probSpecular;
    float probRefract;
    float IOR;
    vec3 refractAbsorb;
    vec3 reflectAbsorb;
    vec3 refractEmit;
    vec3 reflectEmit;
    Vector normal;
};

void initializeData(localData dat){
    dat.subSurface=false;
    dat.isSky=false;
    dat.isPhysical=true;
    dat.renderMaterial=true;
    dat.reflectAbsorb=vec3(0.);
    dat.refractAbsorb=vec3(0.);
    dat.surfDiffuse=vec3(1.);
    dat.surfSpecular=vec3(1.);
    dat.surfEmit=vec3(0.);
    dat.surfRoughness=0.;
    dat.isotropicScatter=0.;
    dat.meanFreePath=1.;
    dat.reflectEmit=vec3(0);
    dat.refractEmit=vec3(0);
    dat.IOR=1.;
    dat.probDiffuse=1.;
    dat.probRefract=0.;
    dat.probSpecular=0.;
}

struct Path{
    Vector tv;
    vec3 pixel;
    vec3 light;
    int type;
    float prob;
    vec3 absorb;
    vec3 emit;
    float distance;
    float totalDistance;
    float numScatters;
    localData dat;
    bool keepGoing;
    bool subSurface;
    vec3 debug;
};

Path initializePath(Vector tv){
    Path path;
    path.tv=tv;
    path.pixel=vec3(0.);
    path.light=vec3(1.);
    path.numScatters=0.;
    path.distance=0.;
    path.totalDistance=0.;
    path.keepGoing=true;
    path.subSurface=false;
    path.type=1;
    path.prob=1.;
    initializeData(path.dat);
    path.debug=vec3(0.);
    path.absorb=vec3(0.);
    path.emit = vec3(0);
    return path;
}

void setObjectInAir
(inout localData dat, bool inside, Vector normal, Material mat){
    dat.renderMaterial=mat.render;
    dat.isSky=false;
    dat.surfDiffuse=mat.diffuseColor;
    dat.surfSpecular=mat.specularColor;
    dat.surfEmit=mat.surfaceEmit;
    dat.surfRoughness=mat.roughness;
    dat.probDiffuse=1.-mat.specularChance-mat.refractionChance;
    dat.probSpecular=mat.specularChance;
    dat.probRefract=mat.refractionChance;
    if(inside){
        dat.normal=negate(normal);
        dat.IOR=mat.IOR/1.;
        dat.reflectEmit = mat.emitColor;
        dat.reflectAbsorb=mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
        dat.refractEmit=vec3(0.);
        dat.subSurface=false;
        dat.meanFreePath=maxDist;
        dat.isotropicScatter=0.;
    }
    else{
        dat.normal=normal;
        dat.IOR=1./mat.IOR;
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=mat.absorbColor;
        dat.reflectEmit=vec3(0.);
        dat.refractEmit=mat.emitColor;
        dat.subSurface=mat.subSurface;
        dat.meanFreePath=mat.meanFreePath;
        dat.isotropicScatter=mat.isotropicScatter;
    }
}

void setSurfaceInMat
(inout localData dat, float side,
Vector normal, Material surf,Material mat){
    dat.renderMaterial=surf.render;
    dat.isSky=false;
    dat.surfEmit=surf.surfaceEmit;
    dat.surfRoughness=surf.roughness;
    dat.probDiffuse=1.-surf.specularChance-surf.refractionChance;
    dat.probSpecular=surf.specularChance;
    dat.probRefract=surf.refractionChance;
    dat.reflectAbsorb=mat.absorbColor;
    dat.refractAbsorb=mat.absorbColor;
    dat.reflectEmit=mat.emitColor;
    dat.refractEmit=mat.emitColor;
    dat.IOR=1.;
    dat.subSurface=false;
    if(side<0.){
        dat.normal=negate(normal);
        dat.surfDiffuse=surf.diffuseColorBack;
        dat.surfSpecular=surf.specularColorBack;
    }
    else{
        dat.normal=normal;
        dat.surfDiffuse=surf.diffuseColor;
        dat.surfSpecular=surf.specularColor;
    }
}

void setMaterialInterface
(inout localData dat, Material current,
Material neighbor, Material dominant ){
    dat.renderMaterial=true;
    dat.probSpecular=dominant.specularChance;
    dat.probRefract=dominant.refractionChance;
    dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;
    dat.surfDiffuse=dominant.diffuseColor;
    dat.surfSpecular=dominant.specularColor;
    dat.surfEmit=dominant.surfaceEmit;
    dat.IOR=current.IOR/neighbor.IOR;
    dat.subSurface=neighbor.subSurface;
    dat.surfRoughness=neighbor.roughness;
    dat.meanFreePath=neighbor.meanFreePath;
    dat.isotropicScatter=neighbor.isotropicScatter;
    dat.reflectAbsorb=current.absorbColor;
    dat.refractAbsorb=neighbor.absorbColor;
    dat.reflectEmit=current.emitColor;
    dat.refractEmit=neighbor.emitColor;
}

void updateProbabilities( inout Path path ){
    if(path.dat.probSpecular!=0.){
        Vector normal=path.dat.normal;
        float origSpec=path.dat.probSpecular;
        path.dat.probSpecular = FresnelReflectAmount(path.dat.IOR, path.tv, normal, origSpec, 1.0);
        float chanceMultiplier = (1.0 - path.dat.probSpecular) / (1.0 - origSpec);
        path.dat.probRefract  *= chanceMultiplier;
        path.dat.probDiffuse = 1.-path.dat.probRefract-path.dat.probSpecular;
    }
}

void scatter( inout Path path){
    if(path.dat.renderMaterial){
        updateProbabilities(path);
        float random=randomFloat();
        Vector normal=path.dat.normal;
        Vector randomDir=randomVector(path.tv.pos);
        Vector diffuseDir=vNormalize(add(normal, randomDir));
        Vector newDir;
        float rough2=path.dat.surfRoughness * path.dat.surfRoughness;
        if (random<path.dat.probSpecular){
            path.type=2;
            path.prob=path.dat.probSpecular;
            path.absorb=path.dat.reflectAbsorb;
            path.emit=path.dat.reflectEmit;
            path.subSurface=false;
            newDir=vReflect(path.tv, normal);
            newDir=vNormalize(mix(newDir, diffuseDir,rough2));
        } else if (random<path.dat.probRefract+path.dat.probSpecular){
            path.type=3;
            path.prob=path.dat.probRefract;
            path.absorb=path.dat.refractAbsorb;
            path.emit=path.dat.refractEmit;
            path.subSurface=false;
            newDir=vRefract(path.tv, normal, path.dat.IOR);
            newDir=vNormalize(mix(newDir, negate(diffuseDir),rough2));
        } else {
            path.prob=path.dat.probDiffuse;
            if(path.dat.subSurface){
                path.subSurface=true;
                path.type=3;
                path.absorb=path.dat.refractAbsorb;
                path.emit=path.dat.refractEmit;
                newDir=vRefract(path.tv, normal, path.dat.IOR);
            } else{
                path.type=1;
                path.absorb=path.dat.reflectAbsorb;
                path.emit=path.dat.reflectEmit;
                newDir=diffuseDir;
            }
        }
        path.prob=max(path.prob, 0.001);
        path.light /= path.prob;
        path.tv=newDir;
        flow(path.tv,10.*EPSILON);
    } else{
        path.type=3;
        path.prob=1.;
        path.absorb=path.dat.refractAbsorb;
        path.emit=path.dat.refractEmit;
        path.subSurface=false;
        flow(path.tv,10.*EPSILON);
    }
}

void updateFromVolume(inout Path path){
    if(length(beersLaw)>0.0001)
    { path.light *= exp( -path.absorb*path.distance ); }
}

void updateFromSubSurf(inout Path path){
    vec3 beersLaw = path.absorb*path.distance;
    vec3 emitAmt = path.emit*path.distance;
    if(length(beersLaw)>0.0001){
        emitAmt *= exp( -beersLaw);
        path.light *= exp( -beersLaw );
    }
    path.pixel += path.light*emitAmt;
}

void updateFromSurface(inout Path path){
    if(path.dat.renderMaterial){
        if (length(path.dat.surfEmit)>0.001)
        { path.pixel += path.light * path.dat.surfEmit; }
        if (path.type == 1){ path.light *=  path.dat.surfDiffuse; }
        if (path.type == 2){ path.light *=  path.dat.surfSpecular; }
    }
}

void updateFromSky(inout Path path){
    if(path.dat.isSky){
        vec3 skyColor = skyTex(path.tv.dir);
        path.pixel += path.light*skyColor;
        path.keepGoing = false;
    }
}

void roulette(inout Path path){
    vec3 p = abs(path.light);
    float L1 = max(p.x,max(p.y,p.z));
    if (randomFloat() > L1){ path.keepGoing = false; }
    if(L1>0.001){ path.light *= 1. / p; }
}


//-------------------------------------------------
// OBJECTS!!!!
//-------------------------------------------------
float smin( float a, float b, float k ){
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}
float smax( float a, float b, float k )
{ return -smin(-a,-b,k); }



//-------------------------------------------------
// SCENE!!!!!
//-------------------------------------------------

float raymarch(Vector tv, float stopDist){
    float totalDist=0.;
    float distToScene=0.;
    float marchFactor=0.9;
    for (int i = 0; i < maxMarchSteps; i++){
        distToScene = abs(sdf_Scene( tv ));
        if (distToScene< EPSILON){ return totalDist+distToScene; }
        distToScene *= marchFactor;
        totalDist += distToScene;
        if(totalDist>stopDist){ return stopDist; }
        flow(tv, distToScene);
    }
    return stopDist;
}

float raytrace(Vector tv, float stopDist){
    float dist =  trace_Scene( tv ) ;
    if(dist<stopDist){ return dist- EPSILON/2.; }
    return stopDist;
}

float bisect_Scatter(Vector tv, float dt){
    float dist=0.;
    float testDist=dt;
    Vector temp;
    for(int i=0;i<10;i++){
        testDist=testDist/2.;
        temp=tv;
        flow(temp, dist+testDist);
        if(inside_Object(temp)){ dist+=testDist; }
    }
    return dist;
}

void subSurfScatter(inout Path path){
    int scatterSteps=500;
    float depth=0.;
    float flowDist;
    Vector tv=path.tv;
    Vector temp=path.tv;
    Vector randomDir;
    float rough=path.dat.isotropicScatter*path.dat.isotropicScatter;
    float mfp = path.dat.meanFreePath;
    for (int i = 0; i < scatterSteps; i++){
        randomDir=randomVector(temp.pos);
        temp=mix(temp,randomDir,rough);
        tv=temp;
        flowDist=randomExponential(mfp);
        flow(temp,flowDist);
        if(!inside_Object(temp)){
            flowDist=bisect_Scatter(tv,flowDist);
            flow(tv,flowDist-EPSILON/2.);
            path.tv=tv;
            path.distance=depth+flowDist;
            path.numScatters=float(i);
            path.subSurface=false;
            return;
        }
        tv=temp;
        depth+=flowDist;
        roulette(path);
        if(!path.keepGoing){ break; }
    }
    path.numScatters=float(scatterSteps);
    path.distance=depth;
    path.keepGoing=false;
}

void stepForward(inout Path path){
    bool insideVar=false;
    float distance=maxDist;
    distance=raytrace( path.tv, distance );
    distance=raymarch( path.tv, distance );
    path.distance=distance;
    path.totalDistance+=distance;
    flow(path.tv,distance);
    path.dat.isSky=(path.distance>maxDist-0.1);
    if(!path.dat.isSky){ setData_Scene(path); }
}

vec3 pathTrace(Path path){
    maxBounces=50;
    for (int bounceIndex = 0; bounceIndex < maxBounces; ++bounceIndex){
        stepForward(path);
        updateFromVolume(path);
        updateFromSky(path);
        scatter(path);
        if(path.subSurface){
            subSurfScatter(path);
            updateFromSubSurf(path);
            path.absorb=path.dat.reflectAbsorb;
            flow(path.tv,5.*EPSILON);
        }
        else{ updateFromSurface(path); }
        roulette(path);
        if(!path.keepGoing){ break; }
    }
    return path.pixel;
}

vec3 mainImage(vec2 fragCoord){
    seed = randomSeed(fragCoord,frameSeed);
    Camera cam=buildCamFromUniforms();
    Vector tv=cameraRay(fragCoord,cam);
    Path path=initializePath(tv);
    buildScene();
    vec3 pixelColor = pathTrace(path);
    return pixelColor;
}



























