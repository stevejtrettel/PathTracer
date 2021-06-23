//-------------------------------------------------
// COMPUTATIONS FOR CREATING OBJECTS
// every function here  is only used in basicObject and compoundObject
// these should never appear outside this folder
//-------------------------------------------------


//-------------------------------------------------
//-------------------------------------------------
//=====useful
//====OPERATIONS
//-------------------------------------------------
//-------------------------------------------------


//get the input for a 2d sdf/normal from a 3d point
vec2 opRevolution( in vec3 p, float w )
{
    return vec2( length(p.xz) - w, p.y );
}

vec3 opRevolutionOutputNormal(in vec3 p, float w, vec2 n){

    //right now this STRAIGHT UP IGNORES W
    vec3 rVec=normalize(vec3(p.x,0,p.z));
    vec3 hVec=vec3(0,1,0);

    return n.x*rVec+n.y*hVec;
}



//smooth min of signed distance functions
float opMinDist(float distA, float distB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float m = 0.25*h*h/k;
    return min(distA,distB)-m;
}


//smooth min of two normal vectors
vec3 opMinVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float n=0.5*h/k;
    float f=(distA<distB)?n:1.-n;
    return normalize(mix(nvecA, nvecB, f));
}



float opMaxDist( float a, float b, float k )
{
    return -opMinDist(-a,-b,k);
}

vec3 opMaxVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    return opMinVec(-distA, nvecA,-distB, nvecB,k);
}


float opOnionDist(float dist, float thickness){
    return abs(dist)-thickness;
}


vec3 opOnionVec(float dist,vec3 nVec){
    return sign(dist)*nVec;
}




vec3 opTwist( vec3 p )
{
    float k =50.0; // or some other amount
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec2 rot=m*p.xz;
    vec3  q = vec3(rot.x,p.y,rot.y);
    return q;
}


















//-------------------------------------------------
//  Basic Functions
//-------------------------------------------------

float sphereDist(vec3 pos, float radius){

    return length(pos)-radius;
}


//the directed distance function: this can be improved with a better sphere locator test
float sphereDist(Vector tv, float radius){

    float d = sphereDist(tv.pos.coords, radius);

    //if you are looking away from the sphere, stop
    //if(d>0.&&dot(tv.dir,tv.pos.coords)>0.){return maxDist;}

    //otherwise return the actual distance
    return d;
}


//----normal vector
vec3 sphereGrad(vec3 pos,  float radius){
    return normalize(pos);
}

//----normal vector
vec3 sphereGrad(Vector tv,  float radius){
    return normalize(tv.pos.coords);
}










//-------------------------------------------------
//-------------------------------------------------
//=====distance to a
//========PLANE
//-------------------------------------------------
//-------------------------------------------------


//-------------------------------------------------
//  Basic Functions
//-------------------------------------------------


float planeDist(vec3 pos, vec3 normal){

    return dot(pos,normal);
}


float planeDist(Vector tv, vec3 normal){

    if(dot(tv.dir,normal)>0.){return maxDist;}
    //otherwise, aimed at plane
    return dot(tv.pos.coords,normal);
}


vec3 planeGrad(vec3 pos, vec3 normal){
    return normal;
}















//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======CYLINDER
//==from rotating a box
//-------------------------------------------------
//-------------------------------------------------


//from https://www.iquilezles.org/www/articles/distgradfunctions2d/distgradfunctions2d.htm
//get the distnance as .x and the 2d normal as .yz
vec3 sdgBox( in vec2 p, in vec2 b )
{
    vec2 w = abs(p)-b;
    vec2 s = vec2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
    return vec3(   (g>0.0)?l  :g,
    s*((g>0.0)?q/l:((w.x>w.y)?vec2(1,0):vec2(0,1))));
}



float cylinderDist(vec3 pos, float radius, float height, float rounded){

    vec2 p=vec2( length(pos.xz) , pos.y);
    //the box we rotate about its central axis has width 2rad and height = 2height.
    vec2 b=vec2(radius-rounded, height);

    vec2 w = abs(p)-b;
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);

    float dist= (g>0.0) ?  l  :g;
    return dist-rounded;
}