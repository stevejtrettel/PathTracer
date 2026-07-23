//-------------------------------------------------
// ENVIRONMENT — none. The holes float in the image sky (set in settings.js);
// escaped rays sample it in their bent direction, so the background lenses around
// each shadow. Geometry-free to isolate the multi-hole lensing.
//-------------------------------------------------


void buildEnvironment(){}

float trace_Environment( Vector tv ){ return maxDist; }

float sdf_Environment( Vector tv ){ return maxDist; }

void setData_Environment( inout Path path ){}
