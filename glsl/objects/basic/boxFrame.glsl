

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
    Frame frame;
    vec3 sides;
    float edge;
    Material mat;
};


//the local-frame sdf
float sdfLocal( vec3 p, BoxFrame obj ){
    return sdBoxFrame(p, obj.sides, obj.edge);
}

//world placement + the standard interface
FRAMED_OBJECT_API(BoxFrame)
