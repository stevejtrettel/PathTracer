
//-------------------------------------------------
//Uniforms
//-------------------------------------------------

uniform vec3 iResolution;
uniform sampler2D sky;
uniform int skyMode;      //0 image · 1 solid · 2 gradient
uniform vec3 skyColor1;   //solid color / gradient top
uniform vec3 skyColor2;   //gradient bottom
uniform mat3 facing;
uniform vec3 location;
uniform float frameNumber;

//camera/render/scratch knob uniforms (aperture, fov, exposure, focusHelp,
//maxBounces, scratch1..4, ...) are generated from the knob lists and injected
//at the top of the shader by buildTraceShader.js. See js/shaderData/knobs.js.

uniform bool renderPanel;
uniform float numPanels;
uniform float panelToRender;


//-------------------------------------------------
//Constants
//-------------------------------------------------


// constants
//(one value of pi, under two names: the sdf_gallery files use lowercase `pi`)
const float PI = 3.14159265;
const float pi = PI;
float EPSILON=0.001;
float AT_THRESH=0.002;
int maxMarchSteps=2000;
float maxDist=100.;

//margin (> EPSILON) at which a bounded object switches from returning its
//bounding-sphere distance to evaluating its real sdf. Keeps the raw bound out
//of the hit band (abs(sdf) < EPSILON) so a bounding volume is never itself hit.
//(see bound() in objects/objectAPI.glsl)
float BOUND_MARGIN=0.05;

//throwaway sink for unused out-parameters (see shapes/bottle.glsl etc)
float trashFloat;
