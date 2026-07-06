

float sdBoxFrame( vec3 p, vec3 b, float e )
{
    p = abs(p  )-b;
    vec3 q = abs(p+e)-e;

    return min(min(
    length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
    length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
    length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}


//-------------------------------------------------
//The BOXFRAME sdf
//-------------------------------------------------

struct BoxFrame{
    vec3 center;
    vec3 sides;
    float edge;
    float size;
    Material mat;
};


//the point-level sdf
float sdf( vec3 p, BoxFrame obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdBoxFrame(pos,obj.sides,obj.edge);
}

//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(BoxFrame)
