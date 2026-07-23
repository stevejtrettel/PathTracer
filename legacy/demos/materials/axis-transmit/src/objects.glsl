//-------------------------------------------------
// OBJECTS — THE TRANSMIT (CLARITY) SWEEP
// (docs/material-system.md §3, Tier 3)
//
// `transmit` is the fraction of NON-REFLECTED light that crosses the interface
// instead of diffusing back out — makeGlass exposes it as the `clarity` knob.
// Sweeping it 0 -> 1 is the opaque/transparent axis:
//
//   0 ----------------------------------------------------> 1
//   solid          frosted           hazy            CLEAR GLASS
//   (everything    (some crosses,    (most crosses)  (all non-reflected
//    diffuses)      rest diffuses)                    light crosses)
//
// Note this is a DIFFERENT axis from axis-density: there the interior decides
// what happens to light that already got in; here we decide how much gets in
// at all. Fresnel is untouched by either — the specular reflection is the same
// all the way across, which is why even the leftmost sphere keeps its highlight.
//
//   FRONT row: clear interior — white solid -> colourless glass
//   BACK  row: absorbing interior — the tint is INVISIBLE at transmit 0 and
//     emerges as the door opens: Beer's law only bills light that got inside.
//-------------------------------------------------

const int NUM = 7;
Sphere clearRow[NUM];
Sphere tintedRow[NUM];


void buildObjects(){

    vec3 teal = vec3(0.25, 0.65, 0.70);          //shown per unit of travel
    vec3 absorb = absorbStrength*absorbFor(teal, 1.);

    for(int i = 0; i < NUM; i++){
        float x = -7.2 + 2.4*float(i);
        float clarity = float(i)/float(NUM - 1);   //0 -> 1

        clearRow[i].frame  = makeFrame(vec3(x, 1.05, 2.));
        clearRow[i].radius = 1.05;
        clearRow[i].mat    = makeGlass(vec3(0.), IOR, clarity);

        tintedRow[i].frame  = makeFrame(vec3(x, 1.05, -2.5));
        tintedRow[i].radius = 1.05;
        tintedRow[i].mat    = makeGlass(absorb, IOR, clarity);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, clearRow[i]));
        dist = min(dist, trace(tv, tintedRow[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    for(int i = 0; i < NUM; i++){
        if(inside(tv, clearRow[i])){  return true; }
        if(inside(tv, tintedRow[i])){ return true; }
    }
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, clearRow[i]);
        setData(path, tintedRow[i]);
    }
}
