
//-------------------------------------------------
//Uniforms
//-------------------------------------------------

uniform vec3 iResolution;
uniform float iTime;
uniform sampler2D sky;
uniform sampler2D skySM;
uniform sampler2D acc;
uniform float iFrame;
uniform mat3 facing;
uniform vec3 location;
uniform float seed;




//-------------------------------------------------
//Constants
//-------------------------------------------------


// constants
float PI=3.1415926;
float EPSILON=0.001;
int maxMarchSteps=100;
float maxDist=50.;
int maxBounces=30;



//====camera constants:
float fov=100.;
float focalLength=2.;
float aperature=0.0;


//======spectral constants:
bool doSpectral=true;





















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


vec2 RandomNormal2D(inout uint state){
    float u=RandomFloat01(state);
    float v=RandomFloat01(state);
    
    float r=sqrt(abs(2.*log(u)));
    float x=r*cos(2.*PI*v);
    float y=r*sin(2.*PI*v);
    
    return vec2(x,y);
    
}


float RandomNormal(float mean, float stdev,inout uint state){
    
    //get 1d normal sample:
    float x=RandomNormal2D(state).x;
    
    //adjust for mean and variance:
    return stdev*x+mean;
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
float x=(angles.x+PI)/(2.*PI);
float z=(angles.z+PI)/(2.*PI);
    
float y=1.-angles.y/PI;

vec2 uv=vec2(x,y);
vec2 uv2=vec2(z,y);//grab the other arctan piece;
    
return SRGBToLinear(textureGrad(sky,uv,dFdx(uv2), dFdy(uv2)).rgb);

}




vec3 checkerTex(vec3 v){
    vec2 p=toSphCoords(v);
    return checkerboard(p);
}

















//-------------------------------------------------
//SPECTRAL TRACING
//-------------------------------------------------

float redResponse(float wavelength){
    float R=0.;
    
    if(wavelength>575.){
        return 1.;
    }
    return 0.;
}


float greenResponse(float wavelength){
        if(wavelength>500.&&wavelength<575.){
        return 1.;
    }
    return 0.;
    
}


float blueResponse(float wavelength){
    if(wavelength<500.){
        return 1.;
    }
    return 0.;
}


//converting a wavelength into an rgb color
//from http://www.noah.org/wiki/Wavelength_to_RGB_in_Python

vec3 WaveLengthColor(float wavelength){
    
    
    float gamma=0.8;
    float attenuation;
    float R,G,B;
    
    
    
    float wl=wavelength;
     
        if (wl >= 380. && wl < 440.) {
            R = -1. * (wl - 440.) / (440. - 380.);
            G = 0.;
            B = 1.;
       } else if (wl >= 440. && wl < 490.) {
           R = 0.;
           G = (wl - 440.) / (490.- 440.);
           B = 1.;  
        } else if (wl >= 490. && wl < 510.) {
            R = 0.;
            G = 1.;
            B = -1. * (wl - 510.) / (510. - 490.);
        } else if (wl >= 510. && wl < 580.) {
            R = (wl - 510.) / (580. - 510.);
            G = 1.;
            B = 0.;
        } else if (wl >= 580. && wl < 645.) {
            R = 1.;
            G = -1. * (wl - 645.) / (645. - 580.);
            B = 0.0;
        } else if (wl >= 645. && wl <= 780.) {
            R = 1.;
            G = 0.;
            B = 0.;
        } else {
            R = 0.;
            G = 0.;
            B = 0.;
        }
    
//    
//    R=redResponse(wavelength);
//    G=greenResponse(wavelength);
//    B=blueResponse(wavelength);
    
    return SRGBToLinear(vec3(R,G,B)); 

}
    
    
    

    
    vec3 sampleSpectrum(inout float wavelength, inout uint state){
        
        float percent=RandomFloat01(state);
        
        float min=380.;
        float max=650.;
        float spread=max-min;
 
        wavelength=spread*percent+min;
        
        return WaveLengthColor(wavelength);
        
    }
    




vec3 sampleRed(inout float wavelength, inout uint state){
    
    wavelength=RandomNormal(600.,25.,state);
    
    return WaveLengthColor(wavelength);
}



vec3 sampleGreen(inout float wavelength,inout uint state){
    
    wavelength=RandomNormal(550.,25.,state);
    
    
    return WaveLengthColor(wavelength);
}


vec3 sampleBlue(inout float wavelength, inout uint state){
    
    wavelength=RandomNormal(450.,25.,state);
    
    return WaveLengthColor(wavelength);
}






