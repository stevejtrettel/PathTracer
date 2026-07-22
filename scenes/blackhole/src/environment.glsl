//-------------------------------------------------
// ENVIRONMENT — none. No walls, no floor, no lights.
// The only backdrop is the image sky (set in settings.js): escaped rays sample
// it in their bent direction, so the sky itself is what lenses into rings.
//-------------------------------------------------


void buildEnvironment(){}

float trace_Environment( Vector tv ){ return maxDist; }

float sdf_Environment( Vector tv ){ return maxDist; }

void setData_Environment( inout Path path ){}
