//-------------------------------------------------
// OBJECTS — THE PLAYGROUND
// one sphere, every field of Surface and Medium wired to a live knob. This is
// the page for ANSWERING "what does this parameter actually do?" — the charts
// show you finished materials, this one lets you build one.
//
// The material is assembled field-by-field rather than through a constructor,
// so the panel maps 1:1 onto the structs in 3Materials/material.glsl:
//   Surface — diffuse, roughness, gloss, transmit, coat, coatRoughness, film
//   Medium  — ior, absorb (as tint + depth), mfp, blur
//
// Recipes to try:
//   clear glass   transmit 1, ballistic ON, absorb depth high
//   frosted glass transmit 0.5, roughness 0.25
//   jade          transmit 1, ballistic OFF, mfp 0.1, blur 0.8
//   wax           as jade, plus roughness 0.45
//   gold          gloss 1, diffuse gold, roughness 0.15
//   car paint     gloss 1, roughness 0.4, coat 1, coatRoughness 0
//   soap bubble   transmit 1, film ~400, IOR 1 (spectral ON in settings)
//-------------------------------------------------

Sphere ball;


void buildObjects(){

    Material mat; initMat(mat);

    //----- the Surface: everything angular, consumed at the interface --------
    mat.surf.diffuse       = baseColor;
    mat.surf.roughness     = roughness;
    mat.surf.gloss         = gloss;
    mat.surf.transmit      = transmit;
    mat.surf.coat          = coat;
    mat.surf.coatRoughness = coatRoughness;
    mat.surf.film          = film;
    mat.surf.filmIOR       = filmIOR;

    //----- the Medium: everything per unit length, plus the index -----------
    mat.interior.ior    = IOR;
    //absorbFor turns "show this tint after travelling this far" into the
    //extinction coefficient — the honest way to author Beer's law
    mat.interior.absorb = absorbFor(absorbTint, absorbDepth);
    //ballistic pins mfp at maxDist: the walk never runs, so the interior is
    //clear glass. Turn it off and the mfp slider takes over (subsurface).
    mat.interior.mfp    = ballistic ? maxDist : mfp;
    mat.interior.blur   = blur;

    ball.frame  = makeFrame(vec3(0., 2., 0.));
    ball.radius = 2.;
    ball.mat    = mat;

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    return trace(tv, ball);
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//used by the medium walk whenever ballistic is off
bool inside_Object( Vector tv ){
    return inside(tv, ball);
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, ball);
}
