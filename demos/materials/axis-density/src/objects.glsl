//-------------------------------------------------
// OBJECTS — THE DENSITY CONTINUUM (docs/material-system.md §2, §5)
//
// THE flagship page: the claim that organizes the whole material system is
// that diffuse, subsurface, and glass are not three mechanisms but ONE axis —
// the interior mean free path. Left to right, mfp climbs from dense to
// ballistic and the same material walks through every look:
//
//   dense  ---------------------------------------------->  ballistic
//   opaque      waxy      milky      jade      hazy      CLEAR GLASS
//   (diffuse                                             (the mfp = maxDist
//    shortcut)                                            limit: no walk)
//
// The rightmost sphere is literally makeGlass — mfp pinned at maxDist so the
// walk never runs. Everything else differs from it in ONE number.
//
// Two rows isolate the second half of the story — the interior sets the LOOK,
// the surface finish sets the FEEL:
//   FRONT row: smooth exit (roughness 0)    — polished: jade, marble, glass
//   BACK  row: rough exit (roughness 0.45)  — waxy matte: wax, clay, skin
// Same interiors in both. absorb is per-unit-LENGTH, so it is identical all
// the way across: only the scattering changes.
//
// Knobs: mfpScale (shifts the whole sweep), absorbStrength, scatterBlur.
//-------------------------------------------------

const int NUM = 7;
Sphere smoothRow[NUM];
Sphere roughRow[NUM];


//the mfp for column i: geometric 0.02 -> 2.0 across the first six, then the
//ballistic limit (maxDist) for the last — the sweep's endpoint IS plain glass.
float columnMFP(int i){
    if(i == NUM - 1){ return maxDist; }
    return 0.02*pow(2.512, float(i))*mfpScale;
}


void buildObjects(){

    vec3 tint = vec3(0.75, 0.45, 0.30);          //shown per unit of travel
    vec3 absorb = absorbStrength*absorbFor(tint, 1.);

    for(int i = 0; i < NUM; i++){
        float x = -7.2 + 2.4*float(i);
        float mfp = columnMFP(i);

        smoothRow[i].frame  = makeFrame(vec3(x, 1.05, 2.));
        smoothRow[i].radius = 1.05;
        smoothRow[i].mat    = makeSubsurface(absorb, 1.5, mfp, scatterBlur);

        roughRow[i].frame  = makeFrame(vec3(x, 1.05, -2.5));
        roughRow[i].radius = 1.05;
        roughRow[i].mat    = makeSubsurface(absorb, 1.5, mfp, scatterBlur);
        roughRow[i].mat.surf.roughness = 0.45;   //the waxy exit
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, smoothRow[i]));
        dist = min(dist, trace(tv, roughRow[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//used by the medium walk: keep scattering while inside any of these
bool inside_Object( Vector tv ){
    for(int i = 0; i < NUM; i++){
        if(inside(tv, smoothRow[i])){ return true; }
        if(inside(tv, roughRow[i])){  return true; }
    }
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, smoothRow[i]);
        setData(path, roughRow[i]);
    }
}
