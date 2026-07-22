//-------------------------------------------------
// OBJECTS — SUBSURFACE SWEEP (docs/material-system.md §5)
// one row of subsurface spheres sweeping the mean free path left (dense,
// waxy) to right (dilute, glassy). The walk has Fresnel/TIR at the boundary
// from inside, so the dilute end limits toward plain glass and the dense end
// glows near its edges. `absorbFor` sets the interior so the medium shows the
// chosen tint after one mean free path of travel.
//-------------------------------------------------

const int NUM = 6;
Sphere row[NUM];


void buildObjects(){

    vec3 wax = vec3(0.75, 0.45, 0.30);   //tint shown per unit of travel

    for(int i = 0; i < NUM; i++){
        float x = -6. + 2.4*float(i);
        //mfp sweep, geometric: 0.04 -> ~1.3 (waxy-dense to dilute)
        float mfp = 0.04*pow(2., float(i))*sssDensity;

        row[i].frame  = makeFrame(vec3(x, 1.05, 0.));
        row[i].radius = 1.05;

        row[i].mat = makeSubsurface(absorbStrength*absorbFor(wax, 1.), 1.5, mfp, sssScatter);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, row[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//used by the subsurface walk: keep scattering while inside any of these
bool inside_Object( Vector tv ){
    for(int i = 0; i < NUM; i++){
        if(inside(tv, row[i])){ return true; }
    }
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, row[i]);
    }
}
