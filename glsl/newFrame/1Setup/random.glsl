
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









//this is thanks to archimedes sphere and the cylinder
//uniform distribution on a sphere is the horizontal projection of uniform distribution on a cylinder
//which unrolls to uniform on a rectangle
vec3 RandomUnitVector(inout uint state)
{
    float z = RandomFloat01(state) * 2.0f - 1.0f;
    float a = RandomFloat01(state) * 6.28;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}







//==== this is an idea for sampling a normal distribution from wikipedia by getting two independent normally distributed values out of two uniform distributed values
vec2 RandomNormal2D(inout uint state){
    float u=RandomFloat01(state);
    float v=RandomFloat01(state);

    float r=sqrt(abs(2.*log(u)));
    float x=r*cos(2.*PI*v);
    float y=r*sin(2.*PI*v);

    return vec2(x,y);

}

//get a single one by just projecting off one of them
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



