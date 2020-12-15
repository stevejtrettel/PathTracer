
//-------------------------------------------------
//Uniforms
//-------------------------------------------------

uniform vec3 iResolution;
uniform float iTime;
uniform sampler2D sky;
uniform sampler2D skySM;
uniform sampler2D acc;
uniform float iFrame;








//-------------------------------------------------
//Constants
//-------------------------------------------------


// constants
float eps=0.001;
int maxMarchSteps=300;
float maxDist=6.5;
float distToViewer;
bool isSky=false;
float fov=100.;


vec3 pixelColor=vec3(0.);
vec3 lightColor=vec3(1.);
vec3 albedo;
vec3 emissive;













//-------------------------------------------------
//Utilities
//-------------------------------------------------




vec2 toSphCoords(vec3 v){
float theta=atan(-v.z,v.x);
float phi=acos(v.y);
return vec2(theta,phi);
}



vec3 skyTex(vec3 v){

vec2 angles=toSphCoords(v);
float x=(angles.x+3.1415)/(2.*3.1415);
float y=1.-angles.y/3.1415;

return texture(sky,vec2(x,y)).rgb;
}













//-------------------------------------------------
//Post-Processing
//-------------------------------------------------



vec3 LessThan(vec3 f, float value)
{
    return vec3(
        (f.x < value) ? 1.0f : 0.0f,
        (f.y < value) ? 1.0f : 0.0f,
        (f.z < value) ? 1.0f : 0.0f);
}


vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);
    
    return mix(
        pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
        rgb * 12.92f,
        LessThan(rgb, 0.0031308f)
    );
}

vec3 SRGBToLinear(vec3 rgb)
{   
    rgb = clamp(rgb, 0.0f, 1.0f);
    
    return mix(
        pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
        rgb / 12.92f,
        LessThan(rgb, 0.04045f)
	);
}













//-------------------------------------------------
//Random Number Generators
//-------------------------------------------------




uint wang_hash(inout uint seed)
{
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}
 
float RandomFloat01(inout uint state)
{
    return float(wang_hash(state)) / 4294967296.0;
}
 
vec3 RandomUnitVector(inout uint state)
{
    float z = RandomFloat01(state) * 2.0f - 1.0f;
    float a = RandomFloat01(state) * 6.28;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}
















