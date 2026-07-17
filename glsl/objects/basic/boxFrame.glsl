//-------------------------------------------------
//The BOXFRAME sdf
//-------------------------------------------------

struct BoxFrame{
    Frame frame;
    vec3 sides;
    float edge;
    Material mat;
};


//the frame (edges) of a box: b = half-widths, e = strut thickness (from IQ)
float sdBoxFrame( vec3 p, vec3 b, float e ){
    p = abs(p)-b;
    vec3 q = abs(p+e)-e;

    return min(min(
    length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
    length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
    length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}


//the local-frame sdf
float sdf( vec3 p, BoxFrame obj ){
    return sdBoxFrame(p, obj.sides, obj.edge);
}

//the standard interface (placement handled by the frame)
OBJECT_API(BoxFrame)
