//-------------------------------------------------
//The BOX sdf
//-------------------------------------------------

struct Box{
    vec3 center;
    vec3 sides;
    float rounded;
    Material mat;
};


//the point-level sdf: the geometry of the box
float sdf( vec3 p, Box box ){
    //normalize position
    vec3 pos = p - box.center;

    vec3 q = abs(pos) - box.sides;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded;
}

//the standard interface: at, inside, sdf, normalVec, setData
UNFRAMED_OBJECT_API(Box)
