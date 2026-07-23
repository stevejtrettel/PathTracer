//-------------------------------------------------
// OBJECTS — ROUGHNESS SWEEP (docs/material-system.md §4)
// two rows of spheres sweeping roughness 0 -> maxRough left to right:
//   FRONT row: clear glass (IOR 1.5) — the ground-glass test: the blur is real
//     rough refraction (facet-shared Fresnel, facet-TIR edge glow).
//   BACK row: gold — the conductor test: the rough end SATURATES (multi-bounce
//     inter-facet reflections pick up the F0 tint repeatedly) instead of
//     graying.
//-------------------------------------------------

const int NUM = 7;
Sphere glassRow[NUM];
Sphere goldRow[NUM];


void buildObjects(){

    for(int i = 0; i < NUM; i++){
        float x = -7.2 + 2.4*float(i);
        float rough = maxRough*float(i)/float(NUM - 1);   //0 -> maxRough

        glassRow[i].frame  = makeFrame(vec3(x, 1.05, 2.));
        glassRow[i].radius = 1.05;
        glassRow[i].mat    = makeGlass(vec3(0.), 1.5);
        glassRow[i].mat.surf.roughness = rough;

        goldRow[i].frame  = makeFrame(vec3(x, 1.05, -2.5));
        goldRow[i].radius = 1.05;
        goldRow[i].mat    = makeGold(rough);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, glassRow[i]));
        dist = min(dist, trace(tv, goldRow[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    for(int i = 0; i < NUM; i++){
        if(inside(tv, glassRow[i])){ return true; }
    }
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, glassRow[i]);
        setData(path, goldRow[i]);
    }
}
