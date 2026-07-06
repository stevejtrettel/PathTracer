
//-------------------------------------------------
//Uniforms
//-------------------------------------------------

uniform vec3 iResolution;
uniform sampler2D sky;
uniform mat3 facing;
uniform vec3 location;
uniform float frameNumber;

//camera/render/scratch knob uniforms (aperture, fov, exposure, focusHelp,
//maxBounces, extra1..4, ...) are generated from the knob lists and injected
//at the top of the shader by buildTraceShader.js. See js/shaderData/knobs.js.

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
