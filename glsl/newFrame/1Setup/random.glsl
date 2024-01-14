
//-------------------------------------------------
//Random Number Generators
//all the random functions go here
//which are geometry independent
//-------------------------------------------------



//a global variable which will get passed around
//as a seed for the random number generators.
uint seed;


//--- the function we call in main() which sets seed
uint randomSeed(vec2 fCoord,float frame){

    uint seed = uint(uint(fCoord.x) * uint(1973) + uint(fCoord.y) * uint(925277) + uint(frame) * uint(26699)) | uint(1);
    return seed;

}


//hash function that gets us our random numbers
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



vec2 randomDiskPolar(float r){
    float theta = 2.*PI*randomFloat();
    float rad = sqrt(randomFloat());
    rad *= r;

    return vec2(rad, theta);
}


vec2 randomDiskXY( float r){
    vec2 polar = randomDiskPolar(r);
    float rad = polar.x;
    float ang = polar.y;
    return rad*vec2(cos(ang),sin(ang));
}



//random unit vector at origin
//this is thanks to archimedes sphere and the cylinder
vec3 randomUnitVec3()
{
    float z = randomFloat() * 2.0f - 1.0f;
    float a = randomFloat() * 6.28;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}




//this is an idea for sampling a normal distribution from wikipedia
//by getting two independent normally distributed values out of two uniform distributed values
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



// get a single random sample from an exponential distribtution of specified mean
//calculated by sampling uniform, and inverting CDF:
//https://www.baeldung.com/cs/sampling-exponential-distribution
float randomExponential(float mean){
    float u = randomFloat();
    float x = - mean * log(1.-u);
    return x;
}






