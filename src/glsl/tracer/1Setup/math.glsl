
float L1_Norm(vec3 p){
    return abs(p.x)+abs(p.y)+abs(p.z);
}

float L2_Norm(vec3 p){
    return length(p);
}

float LInf_Norm(vec3 p){
    p=abs(p);
    return max(p.x,max(p.y,p.z));
}

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


float smin(float a, float b){
    return smin(a,b,0.1);
}

float smax(float a, float b){
    return smax(a,b,0.1);
}

float sq(float x){return x*x;}












