//-------------------------------------------------
// MATERIALS  (docs/material-system.md)
//
// A Material is a SURFACE response plus an interior MEDIUM:
//   Surface — everything angular, consumed at an interface (tints, roughness,
//             the lobe knobs). The scatter event tree reads only this.
//   Medium  — everything with units of 1/length plus the refractive index,
//             consumed along segments between interfaces (Beer absorption,
//             volume emission, the scattering walk).
// Fresnel at any interface comes from the RATIO of the two adjacent media —
// see interaction.glsl. Diffuse reflection is the shortcut for "interior too
// dense to walk"; glass is the ballistic (mfp = maxDist) limit of the walk.
//-------------------------------------------------


struct Surface{
    vec3  diffuse;        //tint of the diffuse lobe
    vec3  specular;       //specular tint: F0 for conductors, white for dielectrics
    vec3  emit;           //surface emission
    vec3  transmitTint;   //tint on crossing — white for volumes (Beer owns color);
                          //set it on THIN surfaces (lampshades, leaves)
    float roughness;      //microfacet jitter, shared by all base lobes
    float gloss;          //artistic Fresnel floor (0 = fully physical)
    float transmit;       //fraction of non-reflected light that crosses
    float coat;           //white lacquer lobe: 0 = none, 1 = full clearcoat (n=1.5)
    float coatRoughness;  //blurs only the coat (satin finishes)
    float film;           //thin-film thickness in nm (0 = off): replaces the base
                          //Fresnel with two-beam interference — soap bubbles, oil
                          //slicks; true rainbows need spectral on
    float filmIOR;        //index of the film itself (soap/water ~1.33, oil ~1.45)
};

struct Medium{
    float ior;            //refractive index (dispersed via iorAt)
    vec3  absorb;         //Beer extinction, 1/length
    vec3  emit;           //volume emission, 1/length
    float mfp;            //scatter mean free path (maxDist = ballistic: no walk)
    float blur;           //phase width: 0 = forward, 1 = isotropic
};

struct Material{
    bool    render;
    Surface surf;
    Medium  interior;
};


void initSurface(inout Surface s){
    s.diffuse=vec3(1.);
    s.specular=vec3(1.);
    s.emit=vec3(0.);
    s.transmitTint=vec3(1.);
    s.roughness=0.;
    s.gloss=0.;
    s.transmit=0.;
    s.coat=0.;
    s.coatRoughness=0.;
    s.film=0.;
    s.filmIOR=1.33;
}

void initMedium(inout Medium m){
    m.ior=1.;
    m.absorb=vec3(0.);
    m.emit=vec3(0.);
    m.mfp=maxDist;
    m.blur=1.;
}

//the default material: pure white matte
void initMat(inout Material mat){
    mat.render=true;
    initSurface(mat.surf);
    initMedium(mat.interior);
}


//-------------------------------------------------
// HELPERS
//-------------------------------------------------

//the extinction coefficient that shows `tint` after traveling `depth` through
//the medium: absorbFor(vec3(0.2,0.7,0.8), 0.5) = "this color at half a unit".
//Replaces hand-scaled magic constants like 30.*tealScatter.
vec3 absorbFor(vec3 tint, float depth){
    return -log(max(tint, vec3(0.0001)))/depth;
}


//-------------------------------------------------
// CONSTRUCTORS — matte / gloss / metal / plastic / glass / subsurface / light
//-------------------------------------------------

//pure diffuse: what walls actually are
Material makeMatte(vec3 color){
    Material mat; initMat(mat);
    mat.surf.diffuse=color;
    return mat;
}

//ARTISTIC gloss floor (no physical index): `gloss` is the head-on reflectance,
//ramping to 1 at grazing. Direct art control — rooms and props are tuned in
//these terms.
Material makeGloss(vec3 color, float gloss, float roughness){
    Material mat; initMat(mat);
    mat.surf.diffuse=color;
    mat.surf.gloss=gloss;
    mat.surf.roughness=roughness;
    return mat;
}

//CONDUCTOR F0 MODEL: specular is the metal's reflectance at normal incidence
//(measured F0, always <= 1); the engine whitens it toward total reflection at
//grazing (per-channel Schlick in scatter()) — that whitening is what turns
//"shiny yellow" into gold. specularity < 1 leaves a colored diffuse remainder
//(artistic "dirty metal"), energy-conserving either way.
Material makeMetal(vec3 color, float specularity, float roughness){
    Material mat; initMat(mat);
    mat.surf.diffuse=color;
    mat.surf.specular=color;
    mat.surf.gloss=specularity;
    mat.surf.roughness=roughness;
    return mat;
}

//measured F0 colours (linear). Most metals are nearly COLOURLESS (silver and
//aluminum bright neutrals, iron and chrome dark ones); the strongly coloured
//conductors are gold, copper, and their alloys.
const vec3 GOLD_F0     = vec3(1.000, 0.766, 0.336);
const vec3 COPPER_F0   = vec3(0.955, 0.637, 0.538);
const vec3 BRASS_F0    = vec3(0.910, 0.778, 0.423);
const vec3 BRONZE_F0   = vec3(0.804, 0.498, 0.306);
const vec3 SILVER_F0   = vec3(0.972, 0.960, 0.915);
const vec3 ALUMINUM_F0 = vec3(0.913, 0.921, 0.925);
const vec3 IRON_F0     = vec3(0.560, 0.570, 0.580);
const vec3 CHROME_F0   = vec3(0.550, 0.556, 0.554);

Material makeGold(float roughness)    { return makeMetal(GOLD_F0,     1., roughness); }
Material makeCopper(float roughness)  { return makeMetal(COPPER_F0,   1., roughness); }
Material makeBrass(float roughness)   { return makeMetal(BRASS_F0,    1., roughness); }
Material makeBronze(float roughness)  { return makeMetal(BRONZE_F0,   1., roughness); }
Material makeSilver(float roughness)  { return makeMetal(SILVER_F0,   1., roughness); }
Material makeAluminum(float roughness){ return makeMetal(ALUMINUM_F0, 1., roughness); }
Material makeIron(float roughness)    { return makeMetal(IRON_F0,     1., roughness); }
Material makeChrome(float roughness)  { return makeMetal(CHROME_F0,   1., roughness); }

//PHYSICAL shiny-opaque: no gloss floor — the interior index alone supplies the
//coat via the Fresnel gate in scatter() (~4% head-on at n=1.5, mirror at
//grazing). transmit stays 0: the interior is never entered, its ior only
//shapes the reflection.
Material makePlastic(vec3 color, float roughness, float IOR){
    Material mat; initMat(mat);
    mat.surf.diffuse=color;
    mat.surf.roughness=roughness;
    mat.interior.ior=IOR;
    return mat;
}

Material makePlastic(vec3 color, float roughness){
    return makePlastic(color, roughness, 1.5);
}

//PURE-FRESNEL GLASS: reflectance from the index alone (gloss stays 0), the
//rest crosses into the interior. `clarity` is the frost knob: after Fresnel,
//that fraction refracts and the remainder scatters diffusely (1 = clear).
//absorb is the interior extinction — use absorbFor(tint, depth) to set it.
Material makeGlass(vec3 absorb, float IOR, float clarity){
    Material mat; initMat(mat);
    mat.surf.transmit=clarity;
    mat.interior.ior=IOR;
    mat.interior.absorb=absorb;
    return mat;
}

Material makeGlass(vec3 absorb, float IOR){
    return makeGlass(absorb, IOR, 1.);
}

//SUBSURFACE: glass whose interior scatters — the walk runs when a transmitted
//ray enters a medium with mfp < maxDist, with Fresnel/TIR at the boundary from
//inside (mediumWalk.glsl). As mfp -> maxDist this IS makeGlass.
Material makeSubsurface(vec3 absorb, float IOR, float mfp, float blur){
    Material mat; initMat(mat);
    mat.surf.transmit=1.;
    mat.interior.ior=IOR;
    mat.interior.absorb=absorb;
    mat.interior.mfp=mfp;
    mat.interior.blur=blur;
    return mat;
}

//LIGHTS: surface emission
Material makeLight(vec3 color, float power){
    Material mat; initMat(mat);
    mat.surf.emit=power*color;
    return mat;
}


//-------------------------------------------------
// MODIFIERS — compose on any base material
//-------------------------------------------------

//a white Fresnel lacquer over the base: car paint (over metal), wet stone
//(over darkened matte), varnish (over material-field wood).
Material withCoat(Material mat, float coat, float coatRoughness){
    mat.surf.coat=coat;
    mat.surf.coatRoughness=coatRoughness;
    return mat;
}

Material withCoat(Material mat){
    return withCoat(mat, 1., 0.);
}

//stochastic blend: the hit is material b with probability t, else a. The
//probability IS the coverage fraction, so the mix is energy-correct with no
//weights. Composes with material fields — make t a function of position for
//dust in the crevices, patina, worn paint.
Material mixMaterial(Material a, Material b, float t){
    if(randomFloat() < t){ return b; }
    return a;
}
