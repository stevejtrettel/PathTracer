
//-------------------------------------------------
//The MATERIAL Struct
//-------------------------------------------------

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


void initMat(inout Material mat){
    //initialize to the default material: pure white diffuse, no specular/refraction
    mat.render=true;
    mat.subSurface=false;
    mat.surfaceEmit=vec3(0.);
    mat.diffuseColor=vec3(1.);
    mat.specularColor=vec3(1.);
    mat.diffuseColorBack=vec3(1.);
    mat.specularColorBack=vec3(1.);
    mat.absorbColor=vec3(0.);
    mat.emitColor=vec3(0.);   //volume emission along the ray (distinct from surfaceEmit); off by default
    mat.isotropicScatter=1.;
    mat.roughness=0.;
    mat.IOR=1.;
    mat.meanFreePath=1.;
    mat.specularChance=0.;
    mat.refractionChance=0.;
}



//note: none of the constructors below set the back colors (diffuseColorBack /
//specularColorBack); they stay at the initMat default of white. Set them by
//hand after construction if a two-sided material needs them.

//------Metals--------------


void setMetal(inout Material mat, vec3 color, float specularity,float roughness){
    initMat(mat);//initialize
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
    initMat(mat);//initialize

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



Material air(vec3 absorbColor){

    Material mat;
    initMat(mat);
    mat.render=false;
    mat.absorbColor=absorbColor;

    return mat;
}



//----- Glass --------------



void setGlass(inout Material mat, vec3 color, float IOR,float refractivity){

    initMat(mat);//initialize
    mat.render=true;

    mat.specularColor=vec3(1.);
    mat.diffuseColor=vec3(1.);
    mat.absorbColor=vec3(color);

    mat.IOR=IOR;

    //refractivity of the glass; the leftover probability is split 90/10
    //between specular reflection and diffuse scattering
    mat.refractionChance=refractivity;
    float remainder=1.-refractivity;
    mat.specularChance=0.9*remainder;

}



void setGlass(inout Material mat, vec3 color, float IOR){

    setGlass(mat,color,IOR,0.95);

}


//control of transparency
Material makeGlass(vec3 color, float IOR,float refractivity){
    Material mat;

    setGlass(mat, color,IOR,refractivity);
    return mat;
}


//overload for default transparency
Material makeGlass(vec3 color, float IOR){
    return makeGlass(color,IOR,0.95);
}



//------Lights --------------


Material makeLight(vec3 color,float intensity){
    Material mat;
    initMat(mat);//initialize


    mat.surfaceEmit=intensity*color;

    return mat;
}

void setLight(inout Material mat, vec3 color,float intensity){
    initMat(mat);//initialize

    mat.surfaceEmit=intensity*color;

}




