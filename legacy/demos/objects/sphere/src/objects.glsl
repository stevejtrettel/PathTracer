//-------------------------------------------------
// OBJECTS — SPHERE  (glsl/objects/ — the analytic primitive)
//
// The first page of the object library: one glass sphere in an empty studio.
// The sphere is ANALYTIC — trace() solves the ray/sphere intersection in closed
// form rather than marching an SDF, so it is exact at any scale and costs the
// same however close the camera gets. That is why it is the object every
// material chart is built out of.
//
// Glass is the deliberate choice for an object reference: a transmissive
// material shows the shape's silhouette, its shadow, AND the whole room bent
// through its interior, so the geometry is legible from one view.
//
// Knobs: radius (the sphere stays resting on the floor as it grows), IOR.
//-------------------------------------------------

Sphere ball;


void buildObjects(){

    //centre at y = radius: the sphere sits ON the floor for any radius
    ball.frame  = makeFrame(vec3(0., radius, 0.));
    ball.radius = radius;
    ball.mat    = makeGlass(vec3(0.), IOR);

}


//-------------------------------------------------
// Finding the Objects  (analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    return trace(tv, ball);
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//no scattering interior here (clear glass is ballistic), but the walk asks
bool inside_Object( Vector tv ){
    return inside(tv, ball);
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, ball);
}
