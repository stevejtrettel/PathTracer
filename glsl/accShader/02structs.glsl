


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

// scalar multiplication of a tangent vector (return a * v)
Vector multiplyScalar(float a,Vector v) {
    return Vector(v.pos, a * v.dir);
}


Vector normalize(Vector v){
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


Vector rotateByFacing(Vector v, mat3 facing){
    return Vector(v.pos,facing*v.dir);
}







//actually flowing along a geodesic
void flow(inout Vector tv, float t){
    //flow distance t in direction tv
    tv.pos+=t*tv.dir;
}




void nudge(inout Vector v, vec3 dir){
    v.pos+=dir*0.003;
}

//overload to nudge along a tangent vector
void nudge(inout Vector v, Vector offset){
    v.pos+=offset.dir*0.003;
}


//small shift in the location of a point
vec3 shiftPoint(vec3 p, vec3 v, float t){
    return p+0.001*v;
}

Vector shift(Vector tv, vec3 dir, float t){
    return Vector(tv.pos+0.001*dir,tv.dir);
}




//use mix instead of if/then statements to choose
//this is NOT to take an average; x should be 0 or 1.
Vector select(Vector v, Vector w,float x){
    vec3 pos=mix(v.pos,w.pos,x);
    vec3 dir=mix(v.dir,w.dir,x);
    return Vector(pos,dir);
}


//overload of the usual mix command for vector directions
Vector mix(Vector v, Vector w, float x){
     vec3 dir=mix(v.dir,w.dir,x);
    return Vector(v.pos,dir);
}




//reflect the unit tangent vector u off the surface with unit normal n
Vector reflect(Vector v, Vector n){
    return add(multiplyScalar(-2.0 * dot(v, n), n), v);
}


//refract the vector v through the surface with normal vector n, coming from a material with refactive index n1 and entering a material with index n2.
Vector refract(Vector v, Vector n, float IOR){
   
    float r=IOR;
    float cosI=-dot(n,v);
    float sinT2=r*r* (1.0 - cosI * cosI);
    if(sinT2>1.){return Vector(v.pos,vec3(0.,0.,0.));}//TIR  
    //if we are not in this case, then refraction actually occurs
    float cosT=sqrt(1.0 - sinT2);
    vec3 dir=r*v.dir+(r * cosI - cosT) * n.dir;
    return Vector(v.pos, dir);
}





float FresnelReflectAmount(float n1, float n2, Vector normal, Vector incident, float f0, float f90)
{
        // Schlick aproximation
        float r0 = (n1-n2) / (n1+n2);
        r0 *= r0;
        float cosX = -dot(normal, incident);
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














//-------------------------------------------------
//The RayType Struct
//-------------------------------------------------

struct RayType{
    
    float diffuse;
    float specular;
    float refract;
    float probability;
    
};



RayType intializeRayType(){
    RayType type;
    type.diffuse=1.;
    type.specular=0.;
    type.refract=0.;
    type.probability=1.;
    
    return type;
}




void setSpecular(inout RayType type,float prob){
    
    type.diffuse=0.;
    type.specular=1.;
    type.refract=0.;
    type.probability=prob;
}


void setDiffuse(inout RayType type,float prob){
    
    type.diffuse=1.;
    type.specular=0.;
    type.refract=0.;
    type.probability=prob;
}


void setRefract(inout RayType type,float prob){
    
    type.diffuse=0.;
    type.specular=0.;
    type.refract=1.;
    type.probability=prob;
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
    
    vec3 debug;
    
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
    
    path.debug=vec3(0.);
    
    return path;
}













//-------------------------------------------------
//The MATERIAL Struct
//-------------------------------------------------


struct Material{
    vec3 emitColor;
    vec3 diffuseColor;
    vec3 specularColor;
    vec3 absorbColor;
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
    mat.absorbColor=vec3(0.);
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



void setGlass(inout Material mat, vec3 color, float IOR,float refractivity){
    
    zeroMat(mat);//initialize
    
    mat.specularColor=vec3(1.);
    mat.diffuseColor=vec3(1.);
    mat.absorbColor=vec3(color);
    
    mat.IOR=IOR;
    
    
    mat.refractionChance=refractivity;
    float remainder=1.-refractivity;
    mat.specularChance=0.9*remainder;
   // mat.diffuseChance=0.1*remainder;
    
}



void setGlass(inout Material mat, vec3 color, float IOR){
    
setGlass(mat,color,IOR,0.95);
    
}


//control of transparency
Material makeGlass(vec3 color, float IOR,float specularity){
    Material mat;
    
    setGlass(mat, color,IOR,specularity);
    return mat;
}


//overload for default transparency
Material makeGlass(vec3 color, float IOR){
    return makeGlass(color,IOR,0.95);
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
};




void initializeData(localData dat){
    dat.isSky=false;
}








