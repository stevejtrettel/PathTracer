


//-------------------------------------------------
//The VECTOR Struct
//-------------------------------------------------


//tangent vector
struct Vector{
    vec3 pos;
    vec3 dir; 
};


Vector add(Vector v, Vector w){
    //this only makes sense if v and w are based at the same point
    return Vector(v.pos, v.dir+w.dir);
}

Vector negate(Vector v){
    return Vector(v.pos,-v.dir);
}

Vector sub(Vector v, Vector w){
    return add(v,negate(w));
}

Vector normalize(inout Vector v){
   return Vector(v.pos,normalize(v.dir));
}

Vector clone(Vector v){
    return v;
}

float dot(Vector v, Vector w){
    return dot(v.dir,w.dir);
}

float cosAng(Vector v, Vector w){
    return dot(normalize(v),normalize(w));
}

//small shift in the location of a point
vec3 shiftPoint(vec3 p, vec3 v, float t){
    return p+0.001*v;
}

Vector shift(Vector tv, vec3 dir, float t){
    return Vector(tv.pos+0.001*dir,tv.dir);
}


//actually flowing along a geodesic
void flow(inout Vector tv, float t){
    //flow distance t in direction tv
    tv.pos+=t*tv.dir;
}




void nudge(inout Vector v, vec3 dir){
    v.pos+=dir*0.001;
}

//overload to nudge along a tangent vector
void nudge(inout Vector v, Vector offset){
    v.pos+=offset.dir*0.001;
}


//use mix instead of if/then statements to choose
Vector mix(Vector v, Vector w,float x){
    vec3 pos=mix(v.pos,w.pos,x);
    vec3 dir=mix(v.dir,w.dir,x);
    return Vector(pos,dir);
}














//-------------------------------------------------
//The RayType Struct
//-------------------------------------------------

struct RayType{
    
    float diffuse;
    float specular;
    float refract;
    float rayProbability;
    
    
};



RayType intializeRayType(){
    RayType type;
    type.diffuse=1.;
    type.specular=0.;
    type.refract=0.;
    type.rayProbability=1.;
    
    return type;
}




void setSpecular(inout RayType type,float prob){
    
    type.diffuse=0.;
    type.specular=1.;
    type.refract=0.;
    type.rayProbability=prob;
}


void setDiffuse(inout RayType type,float prob){
    
    type.diffuse=1.;
    type.specular=0.;
    type.refract=0.;
    type.rayProbability=prob;
}


void setRefract(inout RayType type,float prob){
    
    type.diffuse=0.;
    type.specular=0.;
    type.refract=1.;
    type.rayProbability=prob;
}





//-------------------------------------------------
//The Path Struct
//-------------------------------------------------


struct Path{
    
    Vector tv;
    vec3 pixel;//pixel color
    vec3 light;//light along path

    RayType type;
    
    bool inside;
    bool keepGoing;
    float distance; //distance traveled on a bounce
    
};




Path initializePath(Vector tv){
    Path path;
    
    path.tv=tv;//set the initial direction
    path.pixel=vec3(0.);//set the pixel black
    path.light=vec3(1.);//set the light white
    
    path.distance=0.;
    path.keepGoing=true;
    path.inside=false;
    
    path.type=intializeRayType();
    
    return path;
}













//-------------------------------------------------
//The MATERIAL Struct
//-------------------------------------------------


struct Material{
    vec3 emitColor;
    vec3 diffuseColor;
    vec3 specularColor;
    vec3 refractionColor;
    float roughness;
    float IOR;
    float specularChance;
    float refractionChance;
    
};


void zeroMat(inout Material mat){
    //initializes material:
    mat.emitColor=vec3(0.);
    mat.diffuseColor=vec3(0.);
    mat.specularColor=vec3(0.);
    mat.refractionColor=vec3(0.);
    mat.roughness=0.;
    mat.IOR=1.;
    mat.specularChance=0.;
    mat.refractionChance=0.;
}





//------Metals--------------


void setMetal(inout Material mat, vec3 color, float specularity,float roughness){
    zeroMat(mat);//initialize
    
    mat.diffuseColor=color;
    mat.specularColor=vec3(2.)+0.8*color;
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;
}


Material makeMetal(vec3 color, float specularity, float roughness){

    Material mat;
    
    setMetal(mat,color,specularity,roughness);
    
    return mat;

}





//------Dielectrics --------------



void setDielectric(inout Material mat, vec3 color, float specularity, float roughness){
    zeroMat(mat);//initialize
    
    mat.diffuseColor=color;
    mat.specularColor=vec3(0.9);
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;
    
}

Material makeDielectric(vec3 color, float specularity, float roughness){

    Material mat;
    
    setDielectric(mat,color,specularity,roughness);
    
    return mat;

}







//----- Glass --------------



void setGlass(inout Material mat, vec3 color, float IOR){
    
    zeroMat(mat);//initialize
    
    mat.specularColor=vec3(1.);
    mat.diffuseColor=vec3(1.);
    mat.IOR=IOR;
    mat.refractionColor=vec3(color);
    mat.specularChance=0.1;
    mat.refractionChance=0.8;
    
    
}


Material makeGlass(vec3 color, float IOR){
    Material mat;
    
    setGlass(mat, color,IOR);
    return mat;
}




//------Lights --------------


Material makeLight(vec3 color,float intensity){
    Material mat;
    zeroMat(mat);//initialize
    
    mat.emitColor=intensity*color;
    
    return mat;
}

void setLight(inout Material mat, vec3 color,float intensity){
    zeroMat(mat);//initialize
    
    mat.emitColor=intensity*color;
    
}








//-------------------------------------------------
//The LOCAL DATA Struct
//-------------------------------------------------





struct localData{
    Vector normal;
    Vector reflect;
    Vector refract;
    Material mat;
    bool isSky;
    float dist;
    bool inside;//are you inside an object
    bool hit;//did you hit an object
    
};




void initializeData(localData dat){
    dat.isSky=false;
    dat.inside=false;
    dat.dist=0.;
}





//set the local data to the sky
void setSky(inout localData dat,Vector tv){
    dat.isSky=true;
    dat.mat.diffuseColor=vec3(0.);
    dat.mat.emitColor=
        SRGBToLinear(skyTex(tv.dir));
    //
       // 0.5*vec3(53./255.,81./255.,92./255.);
}







