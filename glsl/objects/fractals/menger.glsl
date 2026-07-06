


float maxcomp(in vec3 p) { return max(p.x, max(p.y, p.z)); }


float sdBox(vec3 p, vec3 b)
{
    vec3  di = abs(p) - b;
    float mc = maxcomp(di);
    return min(mc, length(max(di, 0.0)));
}


float sdf_menger(in vec3 p)
{

    if(length(p)>2.){
        return length(p)-1.9;
    }

    float d = sdBox(p, vec3(1.0));

    float s = 1.0;
    for (int m = 0; m < 7; ++m)
    {
        vec3 a = mod(p * s, 2.0) - 1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0 * abs(a));

        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        float c = (min(da, min(db, dc)) - 1.0) / s;

        d = max(d, c);
    }

    return d;
}










//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct MengerSponge{
    vec3 center;
    float size;
    Material mat;
};


//the point-level sdf
float sdf( vec3 p, MengerSponge obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdf_menger(pos);
}

//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(MengerSponge)

