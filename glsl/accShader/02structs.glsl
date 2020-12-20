
//-------------------------------------------------
//The POINT Struct
//-------------------------------------------------


struct Point {
    vec3 coords;// the point in R4
};

// origin of the space
const Point ORIGIN = Point(vec3(0, 0, 0));



//// return the cylinder coordinates (rho, theta, z) of the point in the form (rho^2, theta, z)
//// avoid one square root computation
//vec3 toCylSq(Point p) {
//    return vec3(
//    pow(p.coords.x, 2.) + pow(p.coords.y, 2.),
//    atan(p.coords.y, p.coords.x),
//    p.coords.z
//    );
//}
//
//// return the cylinder coordinates (rho, theta, z) of the point
//vec3 toCyl(Point p) {
//    vec3 aux = toCylSq(p);
//    return vec3(sqrt(aux.x), aux.yz);
//}


Point shiftPoint(Point p, vec3 v, float ep){
    vec3 s=p.coords.xyz+ep*v;
    return Point(s);
}

//-------------------------------------------------
//The VECTOR Struct
//-------------------------------------------------


//tangent vector
struct Vector{
    Point pos;
    vec3 dir; //stored as PULLBACK TO THE ORIGIN
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

void nudge(inout Vector v, vec3 dir){
    v.pos.coords+=dir*0.003;
}

//overload to nudge along a tangent vector
void nudge(inout Vector v, Vector offset){
    v.pos.coords+=offset.dir*0.003;
}


//use mix instead of if/then statements to choose
//this is NOT to take an average; x should be 0 or 1.
Vector select(Vector v, Vector w,float x){
    vec3 pos=mix(v.pos.coords,w.pos.coords,x);
    vec3 dir=mix(v.dir,w.dir,x);
    return Vector(Point(pos),dir);
}


//overload of the usual mix command for vector directions
Vector mix(Vector v, Vector w, float x){
     vec3 dir=mix(v.dir,w.dir,x);
    return Vector(v.pos,dir);
}







//-------------------------------------------------
//The ISOMETRY Struct
//-------------------------------------------------


struct Isometry {
    mat4 mat;// isometry of the space.
};


const Isometry identity = Isometry(mat4(1));


// Product of two isometries (more precisely isom1 * isom2)
Isometry composeIsometry(Isometry isom1, Isometry isom2) {
    return Isometry(isom1.mat * isom2.mat);
}

// Return the inverse of the given isometry
Isometry getInverse(Isometry isom) {
    return Isometry(inverse(isom.mat));
}



// Translate a point by the given isometry
Point translate(Isometry isom, Point p) {
    vec4 coords=isom.mat * vec4(p.coords,1.);
    return Point(coords.xyz);
}

 

// overload to translate a direction
//SHOULD THIS CHANGE THE DIRECTION?
Vector translate(Isometry isom, Vector v) {
    // apply an isometry to the tangent vector
    //NO NEED TO CHANGE DIR: STORED AT ORIGIN
   // vec4 vDir=isom.mat*vec4(v.dir,0.);
        return Vector(translate(isom, v.pos), v.dir);
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
















