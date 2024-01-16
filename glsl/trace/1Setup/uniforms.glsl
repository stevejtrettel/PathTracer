
//-------------------------------------------------
//Uniforms
//-------------------------------------------------

uniform vec3 iResolution;
uniform sampler2D sky;
uniform sampler2D skySM;
uniform mat3 facing;
uniform vec3 location;
uniform float frameNumber;
uniform float exposure;
uniform bool renderBlocks;

uniform float aperture;
uniform float focalLength;
uniform float fov;
uniform bool focusHelp;
uniform float extra;
uniform float extra2;
uniform float extra3;
uniform float extra4;
//-------------------------------------------------
//Constants
//-------------------------------------------------


// constants
float PI=3.1415926;
float EPSILON=0.001;
float AT_THRESH=0.002;
int maxMarchSteps=2000;
float maxDist=55.;
int maxBounces=50;

//======trash constants:
bool trashBool;
float trashFloat;
vec3 debug;