
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


//CONDUCTOR F0 MODEL: specularColor is the metal's reflectance AT NORMAL INCIDENCE
//(its measured F0 — always <= 1), and the engine whitens the specular tint toward
//total reflection at grazing (per-channel Schlick, see scatter()). That whitening
//is what turns "shiny yellow" into gold. The old model's specularColor of
//vec3(2)+0.8*color was an energy AMPLIFIER (tint > 1) — invisible under the old
//uncapped roulette, faithfully (and wrongly) brightening once transport was fixed.
//`specularity` stays a naive probability knob: 1 = pure conductor; < 1 leaves a
//colored diffuse remainder (artistic "dirty metal"), energy-conserving either way.
void setMetal(inout Material mat, vec3 color, float specularity,float roughness){
    initMat(mat);//initialize
    mat.diffuseColor=color;
    mat.specularColor=color;
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;
}


//measured F0 colours (linear) for the named metals below
//note: most metals are nearly COLOURLESS — silver/aluminum are bright neutrals,
//iron/chrome dark neutrals, differing in brightness not hue. The strongly coloured
//conductors are gold, copper, and their alloys (brass, bronze).
const vec3 GOLD_F0     = vec3(1.000, 0.766, 0.336);
const vec3 COPPER_F0   = vec3(0.955, 0.637, 0.538);
const vec3 BRASS_F0    = vec3(0.910, 0.778, 0.423);
const vec3 BRONZE_F0   = vec3(0.804, 0.498, 0.306);
const vec3 SILVER_F0   = vec3(0.972, 0.960, 0.915);
const vec3 ALUMINUM_F0 = vec3(0.913, 0.921, 0.925);
const vec3 IRON_F0     = vec3(0.560, 0.570, 0.580);
const vec3 CHROME_F0   = vec3(0.550, 0.556, 0.554);

Material makeMetal(vec3 color, float specularity, float roughness){

    Material mat;

    setMetal(mat,color,specularity,roughness);

    return mat;

}

//the named metals: pure conductors (specularity 1) at their measured F0, one knob
Material makeGold(float roughness)    { return makeMetal(GOLD_F0,     1., roughness); }
Material makeCopper(float roughness)  { return makeMetal(COPPER_F0,   1., roughness); }
Material makeBrass(float roughness)   { return makeMetal(BRASS_F0,    1., roughness); }
Material makeBronze(float roughness)  { return makeMetal(BRONZE_F0,   1., roughness); }
Material makeSilver(float roughness)  { return makeMetal(SILVER_F0,   1., roughness); }
Material makeAluminum(float roughness){ return makeMetal(ALUMINUM_F0, 1., roughness); }
Material makeIron(float roughness)    { return makeMetal(IRON_F0,     1., roughness); }
Material makeChrome(float roughness)  { return makeMetal(CHROME_F0,   1., roughness); }





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



//------Plastics (physical clearcoat) --------------
//
// THREE TIERS of shiny-opaque material (see also the pure-Fresnel note in setGlass):
//   makeDielectric — ARTISTIC: `specularity` is a hand-tuned gloss floor
//     (mix(specularity, 1, grazing)); no real IOR. Rooms/walls are tuned in these
//     terms; keep using it wherever direct artistic control of gloss is the point.
//   makePlastic  — PHYSICAL: specularChance stays 0 and the IOR alone sets the coat
//     via the Fresnel gate in updateProbabilities (~4% head-on at n=1.5, full
//     Schlick ramp at grazing — floors go mirror-like at shallow angles for free).
//     The coat is untinted (specularColor 1): Fresnel decides the amount.
//   makeGlass    — the physical coat PLUS transmission (see setGlass).
//
// Single-scatter coat caveat: the lobe mixture attenuates the diffuse substrate by
// (1-F) once; a real clearcoat does it twice (light enters AND exits the coat,
// (1-F)^2 plus internal bounces). Visually minor at plastic IORs; noted, not modeled.

void setPlastic(inout Material mat, vec3 color, float roughness, float IOR){
    initMat(mat);//initialize

    mat.diffuseColor=color;
    mat.specularColor=vec3(1.);
    mat.roughness=roughness;
    mat.IOR=IOR;
    //specularChance stays 0 and refractionChance stays 0: the IOR != 1 term of the
    //Fresnel gate supplies the coat, and the refract branch is unreachable.
}

void setPlastic(inout Material mat, vec3 color, float roughness){
    setPlastic(mat, color, roughness, 1.5);
}

Material makePlastic(vec3 color, float roughness, float IOR){
    Material mat;
    setPlastic(mat, color, roughness, IOR);
    return mat;
}

//default coat: n = 1.5 (acrylic-ish)
Material makePlastic(vec3 color, float roughness){
    return makePlastic(color, roughness, 1.5);
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

    //PURE-FRESNEL GLASS: specularChance stays 0, so updateProbabilities' f0 mapping
    //mix(specularChance, 1, schlick) reduces to the physical Schlick reflectance
    //from the IOR alone (4% head-on for n=1.5). A nonzero specularChance here is a
    //reflectance FLOOR stacked ON TOP of Fresnel — the old 0.9*(1-refractivity)
    //value made n=1.5 glass reflect 8.3% head-on, twice physical, and read "too
    //reflective". The floor semantics remain right for PLASTIC coats (setDielectric),
    //not for glass.
    //
    //refractivity is now an honest FROST knob: after Fresnel takes its share, the
    //non-reflected light refracts with this fraction and scatters diffusely (white)
    //with the remainder. 1.0 = physically clear glass; 0.95 = 5% matte frost.
    mat.refractionChance=refractivity;
    mat.specularChance=0.;

}



void setGlass(inout Material mat, vec3 color, float IOR){

    //default glass is CLEAR (frost is opt-in via the 3-arg version)
    setGlass(mat,color,IOR,1.0);

}


//control of transparency
Material makeGlass(vec3 color, float IOR,float refractivity){
    Material mat;

    setGlass(mat, color,IOR,refractivity);
    return mat;
}


//overload for default transparency (clear — frost is opt-in)
Material makeGlass(vec3 color, float IOR){
    return makeGlass(color,IOR,1.0);
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




