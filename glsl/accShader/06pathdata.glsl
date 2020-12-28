



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
    float wavelength;//wavelength of starting ray

    RayType type;
    Material mat;//material we are CURRENTLY tracing inside
    
    bool inside;
    bool keepGoing;
    float distance; //distance traveled on a bounce
    
    vec3 debug;
    
};





void setLightColor(inout Path path, inout uint rngState){
    
    //if we dont want to run a spectral tracer
    if(!doSpectral){
        path.light=vec3(1.);
        path.wavelength=550.;
        return;
    }
      
    
  path.light=sampleSpectrum(path.wavelength,rngState);
    

}









Path initializePath(Vector tv,inout uint rngState){
    Path path;
    
    
    path.tv=tv;//set the initial direction
    path.pixel=vec3(0.);//set the pixel black
    
    setLightColor(path,rngState);//set the initial light color
    
    path.distance=0.;
    path.keepGoing=true;
    path.inside=false;
    
    path.type=intializeRayType();
    
    path.debug=vec3(0.);
    
    return path;
}













//-------------------------------------------------
//The LOCAL DATA Struct
//-------------------------------------------------





struct localData{
    Vector normal;
    Vector reflect;
    Vector refract;
    Material mat;//material on the other side of what we just hit
    bool isSky;
};


localData trashDat;

void initializeData(localData dat){
    dat.isSky=false;
}








