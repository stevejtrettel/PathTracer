//-------------------------------------------------
// OBJECTS — COAT SWEEP (docs/material-system.md §3, Tier 1)
// two rows of spheres sweeping the coat 0 -> 1 left to right:
//   FRONT row: matte cherry — the WET-STONE test: bare matte on the left, full
//     clearcoat (white Fresnel: ~4% head-on, mirror at grazing) on the right.
//   BACK row: gold, roughness 0.6 — the LACQUERED-METAL test. NOTE: on a metal
//     the coat's only strong tell is SHARPNESS (crisp white highlights over the
//     blurry brushed base): the base is already fully specular, and at grazing
//     both rows converge (conductor whitening and the coat's Fresnel each go to
//     white). Hence the deliberately rough base and the bright key light.
// coatRough blurs only the coat (satin finishes); the base roughness is fixed.
//-------------------------------------------------

const int NUM = 7;
Sphere matteRow[NUM];
Sphere goldRow[NUM];


void buildObjects(){

    vec3 cherry = vec3(0.55, 0.08, 0.10);

    for(int i = 0; i < NUM; i++){
        float x = -7.2 + 2.4*float(i);
        float coatAmt = float(i)/float(NUM - 1);   //0 -> 1

        matteRow[i].frame  = makeFrame(vec3(x, 1.05, 2.));
        matteRow[i].radius = 1.05;
        matteRow[i].mat    = withCoat(makeMatte(cherry), coatAmt, coatRough);

        goldRow[i].frame  = makeFrame(vec3(x, 1.05, -2.5));
        goldRow[i].radius = 1.05;
        goldRow[i].mat    = withCoat(makeGold(0.6), coatAmt, coatRough);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, matteRow[i]));
        dist = min(dist, trace(tv, goldRow[i]));
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
        setData(path, matteRow[i]);
        setData(path, goldRow[i]);
    }
}
