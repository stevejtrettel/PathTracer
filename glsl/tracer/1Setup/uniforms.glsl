
//-------------------------------------------------
//Uniforms
//-------------------------------------------------

uniform vec3 iResolution;
uniform sampler2D sky;
uniform mat3 facing;
uniform vec3 location;
uniform float frameNumber;
uniform float exposure;

uniform float aperture;
uniform float focalLength;
uniform float fov;
uniform bool focusHelp;
uniform float extra;
uniform float extra2;
uniform float extra3;
uniform float extra4;

uniform int maxBounces;

uniform bool renderPanel;
uniform float numPanels;
uniform float panelToRender;


//-------------------------------------------------
//Constants
//-------------------------------------------------


// constants
float PI=3.1415926;
float pi = 3.14159;
float EPSILON=0.001;
float AT_THRESH=0.002;
int maxMarchSteps=2000;
float maxDist=100.;

//throwaway sink for unused out-parameters (see shapes/bottle.glsl etc)
float trashFloat;
