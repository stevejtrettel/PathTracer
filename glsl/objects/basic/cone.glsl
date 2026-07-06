

//-------------------------------------------------
//The TRUNCATED CONE sdf
//-------------------------------------------------

struct Cone{
    vec3 center;
    float height;
    float base;
//this is an extra parameter letting you extend the top
    float flare;
    Material mat;
};



//auxilary function (From IQ) which is the truncated cone:
float sdCappedCone( vec3 p, float h, float r1, float r2 )
{
    vec2 q = vec2( length(p.xz), p.y );
    vec2 k1 = vec2(r2,h);
    vec2 k2 = vec2(r2-r1,2.0*h);
    vec2 ca = vec2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
    vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot(k2,k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot(ca,ca),dot(cb,cb)) );
}


//the point-level sdf
float sdf( vec3 p, Cone cone ){
    //normalize position
    vec3 pos = p - cone.center;
    return sdCappedCone(pos,cone.height,cone.base,cone.flare*cone.base);
}

//the standard interface: at, inside, sdf, normalVec, setData
UNFRAMED_OBJECT_API(Cone)
