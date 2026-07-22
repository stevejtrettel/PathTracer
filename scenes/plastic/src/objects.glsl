//-------------------------------------------------
// OBJECTS OF THE SCENE — the PLASTIC MATERIAL demo
// two rows of spheres sweeping roughness left to right (0 -> 0.5):
//   FRONT row: makePlastic — the PHYSICAL clearcoat. The coat comes from the IOR
//     alone (~4% head-on at n=1.5) and ramps to a mirror at grazing angles —
//     watch the floor-facing silhouettes of the spheres and compare rows.
//   BACK row: makeDielectric with the same nominal 4% gloss — the ARTISTIC floor
//     model, no IOR, so its gloss stays flat with angle.
// Knobs: plasticIOR (coat strength of the front row), lightPower, roomLight.
//-------------------------------------------------

const int NUM = 5;
Sphere physical[NUM];
Sphere artistic[NUM];


void buildObjects(){

    vec3 cherry = vec3(0.55, 0.08, 0.10);

    for(int i = 0; i < NUM; i++){
        float x = -5. + 2.5*float(i);
        float rough = 0.5*float(i)/float(NUM - 1);   //0 -> 0.5

        physical[i].frame  = makeFrame(vec3(x, 1.1, 2.));
        physical[i].radius = 1.1;
        physical[i].mat    = makePlastic(cherry, rough, plasticIOR);

        artistic[i].frame  = makeFrame(vec3(x, 1.1, -2.5));
        artistic[i].radius = 1.1;
        artistic[i].mat    = makeDielectric(cherry, 0.04, rough);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, physical[i]));
        dist = min(dist, trace(tv, artistic[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, physical[i]);
        setData(path, artistic[i]);
    }
}
