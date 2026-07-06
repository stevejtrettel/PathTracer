//-------------------------------------------------
//The BOX sdf
//-------------------------------------------------

struct Box{
    Frame frame;
    vec3 sides;
    float rounded;
    Material mat;
};


//the local-frame sdf
float sdf( vec3 p, Box box ){
    vec3 q = abs(p) - box.sides;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded;
}

//the standard interface
OBJECT_API(Box)
