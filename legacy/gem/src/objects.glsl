//-------------------------------------------------
// OBJECTS OF THE SCENE — the RAINBOW / FIRE demo
// a brilliant-cut gem (shapes/gem.glsl) at diamond-like IOR. With spectral on,
// every facet chain (refract -> internal reflections -> refract out) exits at a
// wavelength-dependent angle, so the stone throws little spectra ("fire") and
// splashes rainbow caustics on the floor. The knobs that matter: ior (2.42 =
// diamond), Dispersion (Render tab), gemTilt, and small bright lights (see
// environment.glsl — the source must subtend LESS angle than the dispersion fan
// or the colours re-overlap into white).
//-------------------------------------------------

#include ../../../glsl/objects/shapes/gem.glsl

Gem stone;


void buildObjects(){

    //tilted so the camera sees crown and pavilion facets at once; culet clears the floor
    stone.frame = makeFrame(vec3(0, 2.3, 0), vec3(0,0,1), gemTilt);
    stone.size  = 2.;

    //colourless, highly refractive: the colour comes from dispersion alone
    stone.mat = makeGlass(vec3(0.0), ior, 0.98);

}


//-------------------------------------------------
// Finding the Objects  (the gem is SDF-marched: no analytic trace)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    return dist;
}

float sdf_Objects( Vector tv ){
    float dist=maxDist;
    dist = min(dist, sdf(tv, stone));
    return dist;
}


bool inside_Object( Vector tv ){
    return inside(tv, stone);
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, stone);
}
