
//-------------------------------------------------
//Uniforms
//-------------------------------------------------

uniform vec3 iResolution;
uniform sampler2D sky;
uniform sampler2D skySM;
uniform mat3 facing;
uniform vec3 location;
uniform float frameSeed;
uniform float brightness;

uniform float aperture;
uniform float focalLength;
uniform float fov;
uniform bool focusHelp;


//-------------------------------------------------
//Constants
//-------------------------------------------------


// constants
float PI=3.1415926;
float EPSILON=0.001;
float AT_THRESH=0.002;
int maxMarchSteps=500;
float maxDist=75.;
int maxBounces=50;

//======trash constants:
bool trashBool;
float trashFloat;
vec3 debug;