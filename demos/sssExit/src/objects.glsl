//-------------------------------------------------
// OBJECTS — SUBSURFACE EXIT-FRESNEL A/B (docs/material-system.md §5)
// one row of subsurface spheres sweeping meanFreePath left (dense, waxy) to
// right (dilute, glassy). This page runs the LEGACY walk (rays leave the
// boundary with no Fresnel); demos/sssExitFresnel loads the SAME src with
// settings.defines = ['SSS_EXIT_FRESNEL'], adding the internal Fresnel/TIR
// bounce-back at the boundary — watch for deeper saturation and the glow
// concentrating near edges, and for the dilute (right) end drifting toward how
// plain glass renders.
//-------------------------------------------------

const int NUM = 6;
Sphere row[NUM];


void buildObjects(){

    vec3 tealScatter = vec3(0.25, 0.65, 0.7);

    for(int i = 0; i < NUM; i++){
        float x = -6. + 2.4*float(i);
        //mfp sweep, geometric: 0.04 -> ~1.3 (waxy-dense to dilute)
        float mfp = 0.04*pow(2., float(i));

        row[i].frame  = makeFrame(vec3(x, 1.05, 0.));
        row[i].radius = 1.05;

        row[i].mat = makeGlass(absorbStrength*tealScatter, 1.5, 1.);
        row[i].mat.refractionChance = 0.;
        row[i].mat.subSurface       = true;
        row[i].mat.meanFreePath     = mfp*sssDensity;
        row[i].mat.isotropicScatter = sssScatter;
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
