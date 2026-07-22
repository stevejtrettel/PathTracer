//-------------------------------------------------
// OBJECTS OF THE SCENE — the MATERIAL-FIELDS demo (see docs/material-fields.md)
//
// One sphere whose material is a FIELD, not a constant: the albedo is veined
// marble, the veins are rougher than the polished stone between them, and the
// specular chance (the polish) fades on the veins too. All of it is ordinary
// scene-owned code: sample a Material as a function of LOCAL position in the
// setData followup and hand it to applyMaterial() — the engine keeps every
// interface detail (sides, normals, IOR, dispersion) exactly as for a constant
// material. Knobs: grainFreq (pattern scale), polish (overall specularity).
//-------------------------------------------------

Sphere ball;


void buildObjects(){

    ball.frame=makeFrame(vec3(0,1.2,0));
    ball.radius=2.;

    //the BASE material: everything the fields below don't override
    ball.mat=makeDielectric(vec3(0.9),0.5,0.05);

}


//-------------------------------------------------
// THE FIELDS (scene-owned; mrb_ = private helpers)
// value noise + fbm turbulence -> classic veined marble
//-------------------------------------------------

float mrb_hash(vec3 p){
    return fract(sin(dot(p, vec3(127.1,311.7,74.7)))*43758.5453);
}

//trilinear value noise
float mrb_noise(vec3 p){
    vec3 i = floor(p);
    vec3 f = fract(p);
    vec3 u = f*f*(3.-2.*f);
    return mix( mix( mix(mrb_hash(i+vec3(0,0,0)), mrb_hash(i+vec3(1,0,0)), u.x),
                     mix(mrb_hash(i+vec3(0,1,0)), mrb_hash(i+vec3(1,1,0)), u.x), u.y),
                mix( mix(mrb_hash(i+vec3(0,0,1)), mrb_hash(i+vec3(1,0,1)), u.x),
                     mix(mrb_hash(i+vec3(0,1,1)), mrb_hash(i+vec3(1,1,1)), u.x), u.y), u.z);
}

float mrb_fbm(vec3 p){
    float v = 0.;
    float a = 0.5;
    for(int i = 0; i < 4; i++){
        v += a*mrb_noise(p);
        p *= 2.03;
        a *= 0.5;
    }
    return v;
}

//vein intensity in [0,1]: turbulence-warped sine sheets, sharpened so most of
//the stone is clear and the veins are thin
float mrb_vein(vec3 p){
    float turb = mrb_fbm(grainFreq*p);
    float sheet = sin(grainFreq*(p.x + 0.6*p.y) + 5.*turb);
    return pow(1.-abs(sheet), 4.);
}


//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv,ball));
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//used in subsurface scattering: keep scattering while inside this object
bool inside_Object( Vector tv ){
    return inside(tv,ball);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, ball);                       // geometry + flat base material
    if( at(path.tv, ball) ){                   // material-field followup
        vec3 p = toLocal(ball.frame, path.tv.pos);   //local: the pattern rides with the ball
        float vein = mrb_vein(p);

        Material m = ball.mat;
        m.diffuseColor   = mix(vec3(0.93,0.90,0.85), vec3(0.25,0.30,0.42), vein);  //ivory -> slate veins
        m.roughness      = mix(0.02, 0.4, vein);                                   //veins are rougher
        m.specularChance = polish*(1.-0.7*vein);                                   //and less polished
        applyMaterial(path, m);
    }
}
