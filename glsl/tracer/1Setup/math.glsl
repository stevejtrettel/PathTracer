
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




// Standard 2D rotation formula.
mat2 rot2(in float a){ float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }




//rotate Z axis to the vector targetNormal
mat3 rotateZto(vec3 targetNormal) {
    vec3 from = vec3(0.0, 0.0, 1.0);
    vec3 to = normalize(targetNormal);

    float cosTheta = dot(from, to);
    vec3 rotationAxis = cross(from, to);
    float axisLength = length(rotationAxis);

    if (axisLength < 0.0001) { // parallel vectors
        if (cosTheta > 0.9999) {
            return mat3(1.0); // no rotation
        } else {
            // 180-degree rotation around X axis (any axis perpendicular to from)
            return mat3(
            1.0,  0.0,  0.0,
            0.0, -1.0,  0.0,
            0.0,  0.0, -1.0
            );
        }
    }

    vec3 k = rotationAxis / axisLength;
    float s = axisLength;
    float c = cosTheta;
    float ic = 1.0 - c;

    return mat3(
    k.x * k.x * ic + c,        k.x * k.y * ic - k.z * s,  k.x * k.z * ic + k.y * s,
    k.y * k.x * ic + k.z * s,  k.y * k.y * ic + c,        k.y * k.z * ic - k.x * s,
    k.z * k.x * ic - k.y * s,  k.z * k.y * ic + k.x * s,  k.z * k.z * ic + c
    );
}


//inverse of the above: rotate this vector to Z
mat3 rotateToZ(vec3 targetNormal){
    mat3 rot = rotateZto(targetNormal);
    return inverse(rot);
}

mat3 rotateAboutZ(float theta){
    float c = cos(theta);
    float s = sin(theta);

    return mat3(c,-s,0, s, c, 0, 0,0,1);
}


//
//
//// Build R that sends (0,0,1) → normalize(vec3(a,b,c))
//mat3 makeRotationToNormal(vec3 a_b_c) {
//    vec3 up    = vec3(0.,0.,1.);
//    vec3 n     = normalize(a_b_c);
//    float cosA = clamp(dot(up, n), -1.0, 1.0);
//    float angle = acos(cosA);
//
//    vec3 axis = cross(up, n);
//    float axisLen = length(axis);
//    if (axisLen < 1e-6) {
//        // up || n: if pointing opposite, rotate 180° around X
//        if (cosA < 0.) return mat3(-1.,0.,0., 0.,1.,0., 0.,0.,-1.);
//        else           return mat3(1.0);  // no rotation
//    }
//    axis /= axisLen;
//
//    mat3 K = mat3(
//    0.,       -axis.z,  axis.y,
//    axis.z,   0.,      -axis.x,
//    -axis.y,   axis.x,   0.
//    );
//    return mat3(1.0)
//    + K * sin(angle)
//    + (K * K) * (1.0 - cosA);
//}
//
