

float sdf_mobius(in vec3 p)
{
    if(length(p)>1.){
        return length(p)-.9;
    }
    float a = atan(p.z, p.x);
    p.xz *= mat2(cos(a), sin(a), -sin(a), cos(a));
    p.x -= 0.33;
    p.xy *= mat2(cos(a*0.5), sin(a*0.5), -sin(a*0.5), cos(a*0.5));
    return 0.5*(abs(p.x) + abs(4.*p.y) - 0.2);
}


//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

struct Mobius{
    Frame frame;
    float size;
    Material mat;
};


//the local-frame sdf
float sdf( vec3 p, Mobius obj ){
    vec3 pos = p / obj.size;
    return sdf_mobius(pos);
}

//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(Mobius)
