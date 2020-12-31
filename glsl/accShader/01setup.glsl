
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
int maxMarchSteps=200;
float maxDist=75.;
int maxBounces=50;



//====camera constants:
float fov=60.;
float focalLength=9.3;
float aperature=0.;


//======spectral constants:
bool doSpectral=false;

bool trashBool;
float trashFloat;


















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
//Utilities
//-------------------------------------------------


// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}



float smax( float a, float b, float k )
{
    return -smin(-a,-b,k);
}





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







