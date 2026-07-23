//-------------------------------------------------
// OBJECTS OF THE SCENE
// a triangular glass prism (basic/triangle.glsl) to disperse the light.
// Turn up the Dispersion knob (Render tab) to spread the light into a spectrum.
//-------------------------------------------------

Triangle prism;


void buildObjects(){

    //a chunky triangular prism: triangle cross-section in xy, extruded along z.
    //tilt it so a face catches the light at an angle (that angle is what disperses).
    prism.frame = makeFrame(vec3(0, 2.0, 0), vec3(0, 0, 1), 12.);
    prism.side = 4.;
    prism.thickness = 2.5;

    //near-colourless glass, highly refractive. ior is a scene knob (settings.js);
    //higher ior = stronger bending AND stronger dispersion.
    prism.mat = makeGlass(vec3(0.0), ior, 0.98);

}


//-------------------------------------------------
// Finding the Objects  (Triangle is SDF-marched: no analytic trace)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    return dist;
}

float sdf_Objects( Vector tv ){
    float dist=maxDist;
    dist = min(dist, sdf(tv, prism));
    return dist;
}


bool inside_Object( Vector tv ){
    return inside(tv, prism);
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, prism);
}
