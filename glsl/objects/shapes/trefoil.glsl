


mat3 trefoil_RotMat(vec3 axis, float angle)
{
    // http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(oc*axis.x*axis.x+c,         oc*axis.x*axis.y-axis.z*s,  oc*axis.z*axis.x+axis.y*s,
    oc*axis.x*axis.y+axis.z*s,  oc*axis.y*axis.y+c,         oc*axis.y*axis.z-axis.x*s,
    oc*axis.z*axis.x-axis.y*s,  oc*axis.y*axis.z+axis.x*s,  oc*axis.z*axis.z+c);
}

const float dstFar = 100.;

float trefoil_PrBox2Df (vec2 p, vec2 b)
{
    vec2 d;
    d = abs (p) - b;
    return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

vec2 trefoil_Rot2D (vec2 q, float a)
{
    return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

float trefoil_ObjDf (vec3 p, float r)
{
    vec3 q;
    float dMin, d, a;
    dMin = dstFar;
    q = p;
    a = atan (q.z, q.x);
    q.xz = vec2 (length (q.xz) - r, q.y);
    q.xz = trefoil_Rot2D (q.xz, 1.5 * a);
    q.xz = trefoil_Rot2D (q.xz, - PI * (floor (atan (q.z, q.x) / PI + 0.5)));
    q.x -= 1.;
    d = length (trefoil_PrBox2Df (q.xz, vec2 (0.2))) - 0.05;
    if (d < dMin) { dMin = d; }
    return 0.4 * dMin;
}

float sdf_trefoil(vec3 p)
{
    if(length(p)>2.){
        return length(p)-1.9;
    }

    p *= trefoil_RotMat(vec3(1.,0.,0.), PI/2.);
    const float scale = 0.18;
    p *= 1. / scale;
    return trefoil_ObjDf(p, 2.5) * scale;
}


//-------------------------------------------------
//The TREFOIL sdf
//-------------------------------------------------

struct Trefoil{
    Frame frame;
    float size;
    Material mat;
};


//the local-frame sdf
float sdf( vec3 p, Trefoil obj ){
    vec3 pos = p / obj.size;
    return sdf_trefoil(pos);
}

//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(Trefoil)
