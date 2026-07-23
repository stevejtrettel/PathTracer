//-------------------------------------------------
// ENVIRONMENT — none. The glass cube floats in the image sky (set in settings.js),
// so the lensing acts on the background: rays that exit the cube sample the sky in
// their bent direction. Keeping it geometry-free isolates the cube's optics.
//-------------------------------------------------


void buildEnvironment(){}

float trace_Environment( Vector tv ){ return maxDist; }

float sdf_Environment( Vector tv ){ return maxDist; }

void setData_Environment( inout Path path ){}
