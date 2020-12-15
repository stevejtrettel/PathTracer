


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
    return p+eps*v;
}

Vector shift(Vector tv, vec3 dir, float t){
    return Vector(tv.pos+eps*dir,tv.dir);
}


//actually flowing along a geodesic
void flow(inout Vector tv, float t){
    //flow distance t in direction tv
    tv.pos+=t*tv.dir;
}




void nudge(inout Vector v, vec3 dir){
    v.pos+=dir*0.01;
}

//overload to nudge along a tangent vector
void nudge(inout Vector v, Vector offset){
    v.pos+=offset.dir*0.01;
}












//-------------------------------------------------
//The Path Struct
//-------------------------------------------------


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













//-------------------------------------------------
//The MATERIAL Struct
//-------------------------------------------------


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


void zeroMat(inout Material mat){
    //initializes material:
    mat.emit=vec3(0.);
    mat.diffuse=vec3(0.);
    mat.specular=vec3(0.);
    mat.roughness=0.;
    mat.IOR=1.;
    mat.specularChance=0.;
    mat.refractionChance=0.;
    mat.specularPercent=0.;
}




void setMetal(inout Material mat, vec3 color, float specularity,float roughness){
    zeroMat(mat);//initialize
    
    mat.diffuse=color;
    mat.specular=(vec3(1.)+color)/2.;
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;
    
    mat.specularPercent=specularity;

}



void setDielectric(inout Material mat, vec3 color, float specularity, float roughness){
    zeroMat(mat);//initialize
    
    mat.diffuse=color;
    mat.specular=vec3(0.9);
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;
    
   mat.specularPercent=specularity;
    mat.refractionChance=0.3;

}



void setGlass(inout Material mat, vec3 color, float IOR){
    
    zeroMat(mat);//initialize
    
}



void setLight(inout Material mat, vec3 color,float intensity){
    zeroMat(mat);//initialize
    
    mat.emit=intensity*color;
    
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
    bool inside;
    //are you inside an object
};




//set the local data to the sky
void setSky(inout localData dat,Vector tv){
    dat.isSky=true;
    dat.mat.diffuse=vec3(0.);
    dat.mat.emit=vec3(0.2);
        //SRGBToLinear(skyTex(tv.dir));
    //
       // 0.5*vec3(53./255.,81./255.,92./255.);
}







