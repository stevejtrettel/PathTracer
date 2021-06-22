
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




