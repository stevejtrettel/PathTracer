//-------------------------------------------------
//The CAPSULE sdf
// a line segment a -> b (in local coords) thickened by a radius:
// the exact distance to the segment, minus the radius.
//-------------------------------------------------

struct Capsule{
    Frame frame;
    vec3 a;        //segment endpoints, in the object's local coordinates
    vec3 b;
    float radius;
    Material mat;
};


//the local-frame sdf (IQ's capsule / rounded line segment)
float sdf( vec3 p, Capsule cap ){
    vec3 pa = p - cap.a;
    vec3 ba = cap.b - cap.a;
    float h = clamp(dot(pa, ba)/dot(ba, ba), 0.0, 1.0);
    return length(pa - ba*h) - cap.radius;
}

//local bounding sphere: the farther endpoint plus the radius
float bound( vec3 p, Capsule cap ){ return length(p) - (max(length(cap.a), length(cap.b)) + cap.radius); }

//the standard interface (custom bound above)
OBJECT_API_B(Capsule)
