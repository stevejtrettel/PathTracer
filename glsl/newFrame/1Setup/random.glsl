
//-------------------------------------------------
//Random Number Generators
//all the random functions go here
//which are geometry independent
//-------------------------------------------------



//a global variable which will get passed around
//as a seed for the random number generators.
uint seed;





uint wang_hash()
{
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}



//return a random float in the interval [0,1]
float randomFloat(){
    return float(wang_hash()) / 4294967296.0;
}


//return a random float in the interval [a,b]
float randomFloat(float a,float b){
    return a+(b-a)*randomFloat();
}





//this is thanks to archimedes sphere and the cylinder
//uniform distribution on a sphere is the horizontal projection of uniform distribution on a cylinder
//which unrolls to uniform on a rectangle
vec3 randomUnitVector()
{
    float z = randomFloat() * 2.0f - 1.0f;
    float a = randomFloat() * 6.28;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}




//==== this is an idea for sampling a normal distribution from wikipedia by getting two independent normally distributed values out of two uniform distributed values
vec2 randomGaussian2D(){
    float u=randomFloat();
    float v=randomFloat();

    float r=sqrt(abs(2.*log(u)));
    float x=r*cos(2.*PI*v);
    float y=r*sin(2.*PI*v);

    return vec2(x,y);

}

//get a single one by just projecting off one of them
float randomGaussian(float mean, float stdev){

    //get 1d normal sample:
    float x=randomGaussian2D().x;

    //adjust for mean and variance:
    return stdev*x+mean;
}




//--- the function we call in main() which sets seed
//--- based on the frag coord and the frame number

uint randomSeed(vec2 fCoord,float frame){

    uint seed = uint(uint(fCoord.x) * uint(1973) + uint(fCoord.y) * uint(925277) + uint(frame) * uint(26699)) | uint(1);
    return seed;

}




