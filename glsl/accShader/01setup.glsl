
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
float EPSILON=0.001;
int maxMarchSteps=100;
float maxDist=10.;
float fov=100.;
int maxBounces=10;

























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



//--- the function we call in main() which sets rngState
//--- based on the frag coord and the frame number

uint randomSeed(vec2 fCoord,float frame){

uint rngState = uint(uint(fCoord.x) * uint(1973) + uint(fCoord.y) * uint(925277) + uint(frame) * uint(26699)) | uint(1);

return rngState;

}










//-------------------------------------------------
//Utilities
//-------------------------------------------------

vec3 checkerboard(vec2 v){
    float x=mod(20.*v.x/6.28,2.);
    float y=mod(20.*v.y/3.14,2.);
    
    if(x<1.&&y<1.||x>1.&&y>1.){
        return vec3(1.);
    }
    else return vec3(0.0);
}



vec2 toSphCoords(vec3 v){
float theta=atan(-v.z,v.x);
float phi=acos(v.y);
return vec2(theta,phi);
}



vec3 toSphCoordsNoSeam(vec3 v){
    
    float theta=atan(-v.z,v.x);
    float theta2=atan(v.y,abs(v.x));
    float phi=acos(v.y);
return vec3(theta,phi,theta2);
}








//-------------------------------------------------
//Backgrounds
//-------------------------------------------------


vec3 skyTex(vec3 v){

vec3 angles=toSphCoordsNoSeam(v);
    
//theta coordinates (x=real, y=to trick the derivative so there's no seam)
float x=(angles.x+3.1415)/(2.*3.1415);
float z=(angles.z+3.1415)/(2.*3.1415);
    
float y=1.-angles.y/3.1415;

vec2 uv=vec2(x,y);
vec2 uv2=vec2(z,y);//grab the other arctan piece;
    
return SRGBToLinear(textureGrad(sky,uv,dFdx(uv2), dFdy(uv2)).rgb);

}




vec3 checkerTex(vec3 v){
    vec2 p=toSphCoords(v);
    return checkerboard(p);
}


