
//-------------------------------------------------
//Random Number Generators
//all the random functions go here
//which are geometry independent
//-------------------------------------------------



//-------------------------------------------------
// The per-path random stream: PCG
//-------------------------------------------------
// A pixel's samples come from its own stream, set up once per frame by
// initRandom(). The generator is PCG (an LCG step plus a permuted output —
// "PCG RXS-M-XS", Jarzynski & Olano, "Hash Functions for GPU Rendering", 2020):
// full 2^32 period, and far better statistics than the old wang_hash chain on
// a linear seed (x*1973 + y*925277 + frame*26699), whose pixel/frame
// combinations could collide.

uint seed;          //the stream state
uint pixelHash;     //hash of (pixel, HD tile): scrambles this pixel's low-discrepancy samples
uint sampleIndex;   //this pixel's sample number (the frame): indexes its low-discrepancy sequence
int  pathBounce;    //which bounce the path is on (set by pathTrace): 0 = the first hit


//a good 32-bit integer hash (the PCG permutation applied to one LCG step)
uint pcgHash(uint v){
    uint state = v * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}


//set up this pixel's randomness for this frame. tile separates the tiles of an
//HD render (0 when not tiling): they see tile-local pixel coordinates and each
//restarts the frame count, so without it every tile would repeat the others.
void initRandom(vec2 fCoord, float frame, uint tile){
    pixelHash   = pcgHash(uint(fCoord.x) + pcgHash(uint(fCoord.y) + pcgHash(tile)));
    sampleIndex = uint(frame);
    seed        = pcgHash(pixelHash ^ pcgHash(sampleIndex + 0x632be5abu));
    pathBounce  = 0;
}


//return a random float in [0,1): the top 24 bits, so exactly representable
//(it can never round up to 1.0)
float randomFloat(){
    seed = seed * 747796405u + 2891336453u;
    uint word = ((seed >> ((seed >> 28u) + 4u)) ^ seed) * 277803737u;
    word = (word >> 22u) ^ word;
    return float(word >> 8u) * (1. / 16777216.);
}


//-------------------------------------------------
// Low-discrepancy samples for the dimensions that matter most
//-------------------------------------------------
// Independent random samples clump: after N frames a pixel's jitter, lens and
// first-bounce samples cover their domains unevenly, and the error falls like
// 1/sqrt(N). A low-discrepancy sequence spreads them evenly over the frames, so
// those dimensions converge faster. This is Owen-scrambled, index-shuffled
// Sobol (Burley, "Practical Hash-based Owen Scrambling", JCGT 2020): each
// pixel and each 2D "slot" gets its own scramble, so neighbouring pixels and
// different slots are decorrelated, and any frame count is a good prefix.
// Only a few slots use it (see LD_* below); everything else is PCG.

const uint LD_JITTER     = 0u;   //sub-pixel jitter (camera.glsl)
const uint LD_APERTURE   = 1u;   //lens sample (camera.glsl)
const uint LD_BOUNCE_DIR = 2u;   //first-bounce diffuse direction (scatter.glsl)
const uint LD_BOUNCE_EVT = 3u;   //first-bounce event choice + wavelength (scatter.glsl, traceShader.glsl)

uint reverseBits(uint x){
    x = ((x & 0xaaaaaaaau) >> 1u) | ((x & 0x55555555u) << 1u);
    x = ((x & 0xccccccccu) >> 2u) | ((x & 0x33333333u) << 2u);
    x = ((x & 0xf0f0f0f0u) >> 4u) | ((x & 0x0f0f0f0fu) << 4u);
    x = ((x & 0xff00ff00u) >> 8u) | ((x & 0x00ff00ffu) << 8u);
    return (x >> 16u) | (x << 16u);
}

//Laine-Karras style permutation: a hash in which each bit depends only on the
//bits below it — the building block of Owen scrambling
uint lkPermutation(uint x, uint s){
    x += s;
    x ^= x * 0x6c50b47cu;
    x ^= x * 0xb82f1e52u;
    x ^= x * 0xc7afe638u;
    x ^= x * 0x8d22f6e6u;
    return x;
}

//Owen scrambling of a binary fraction (most significant bit first)
uint nestedUniformScramble(uint x, uint s){
    return reverseBits(lkPermutation(reverseBits(x), s));
}

//the second Sobol dimension (the first is reverseBits(i)): direction numbers
//from the polynomial x + 1, i.e. v_k = v_{k-1} ^ (v_{k-1} >> 1)
uint sobol1(uint i){
    uint r = 0u;
    uint v = 0x80000000u;
    for(int k = 0; k < 32; k++){
        if(i == 0u){ break; }
        if((i & 1u) != 0u){ r ^= v; }
        i >>= 1u;
        v ^= v >> 1u;
    }
    return r;
}

//this pixel's sample number `sampleIndex` of 2D slot `slot`, in [0,1)^2
vec2 ldSample2D(uint slot){
    uint s = pcgHash(pixelHash ^ (slot * 0x9e3779b9u + 0x85ebca6bu));
    uint i = nestedUniformScramble(sampleIndex, s);          //shuffle: decorrelates slots
    uint x = nestedUniformScramble(reverseBits(i), pcgHash(s ^ 0x68bc21ebu));
    uint y = nestedUniformScramble(sobol1(i),       pcgHash(s ^ 0x02e5be93u));
    return vec2(float(x >> 8u), float(y >> 8u)) * (1. / 16777216.);
}


//return a random float in the interval [a,b]
float randomFloat(float a,float b){
    return a+(b-a)*randomFloat();
}




//unit vector from a point u in [0,1)^2, uniform on the sphere when u is:
//this is thanks to archimedes sphere and the cylinder
vec3 unitVec3From(vec2 u)
{
    float z = u.x * 2.0f - 1.0f;
    float a = u.y * 2.*PI;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}

//random unit vector at origin
vec3 randomUnitVec3()
{
    float u = randomFloat();
    float v = randomFloat();
    return unitVec3From(vec2(u, v));
}




//this is an idea for sampling a normal distribution from wikipedia
//by getting two independent normally distributed values out of two uniform distributed values
vec2 randomGaussian2D(){
    float u=randomFloat();
    float v=randomFloat();

    //(u is exactly 0 once in 2^32 draws: log(0) = -inf -> a NaN sample)
    float r=sqrt(abs(2.*log(max(u, 1e-37))));
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
    //(randomFloat() rounds to exactly 1.0 about once in 2^25 draws: log(0) would
    //make an infinite flight)
    float x = - mean * log(max(1.-u, 1e-30));
    return x;
}






