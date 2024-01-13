
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
    bool varyingColor;
    bool varyingIsotropicScatter;
};


void zeroMat(inout Material mat){
    //initializes material:
    mat.render=true;
    mat.subSurface=false;
    mat.surfaceEmit=vec3(0.);
    mat.diffuseColor=vec3(1.);
    mat.specularColor=vec3(1.);
    mat.diffuseColorBack=vec3(1.);
    mat.specularColorBack=vec3(1.);
    mat.absorbColor=vec3(0.);
    mat.isotropicScatter=1.;
    mat.roughness=0.;
    mat.IOR=1.;
    mat.meanFreePath=1.;
    mat.specularChance=0.;
    mat.refractionChance=0.;
    mat.varyingColor=false;
    mat.varyingIsotropicScatter=false;
}




//------------------
// The functions varyingColor and varyingIsotropicColor that may be used
// unfortunately this means that they are set once and for all, for any material with this property
// cant be changed on an object by object basis:
//-----------------

vec3 varyingColor(Vector tv){
    vec3 pos = tv.pos;
    float val1 = sin(5.*pos.y);
    float val2 = sin(8.*pos.x*pos.z);
    return 0.1*(vec3(val1*val1)+0.3*vec3(val2*val2,0,0));
}

float varyingIsotropicScatter(Vector tv){
    vec3 pos = tv.pos;
    float val = sin(3.*pos.y);
    return val*val*val*val;
}





//HAVE NOT SET BACK COLORS OF ANY OF THESE MATERIALS NEED TO DO IT BY HAND

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



Material air(vec3 absorbColor){

    Material mat;
    zeroMat(mat);
    mat.render=false;
    mat.absorbColor=absorbColor;

    return mat;
}



//----- Glass --------------



void setGlass(inout Material mat, vec3 color, float IOR,float refractivity){

    zeroMat(mat);//initialize
    mat.render=true;

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


    mat.surfaceEmit=intensity*color;

    return mat;
}

void setLight(inout Material mat, vec3 color,float intensity){
    zeroMat(mat);//initialize

    mat.surfaceEmit=intensity*color;

}




