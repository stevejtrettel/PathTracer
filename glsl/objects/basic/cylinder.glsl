//-------------------------------------------------
//The CYLINDER sdf
// a capped cylinder standing on the y-axis (like torus, it's vertical).
// radius, height (HALF-height), and an optional rounded edge.
//-------------------------------------------------

struct Cylinder{
    Frame frame;
    float radius;
    float height;    //half-height
    float rounded;   //rounded rim (0 = sharp edges)
    Material mat;
};


//the local-frame sdf (IQ's rounded capped cylinder, axis = y)
float sdf( vec3 p, Cylinder cyl ){
    vec2 d = abs(vec2(length(p.xz), p.y))
           - vec2(cyl.radius - cyl.rounded, cyl.height - cyl.rounded);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - cyl.rounded;
}

//local bounding sphere: the far top rim + the rounding
float bound( vec3 p, Cylinder cyl ){ return length(p) - (length(vec2(cyl.radius, cyl.height)) + cyl.rounded); }

//the standard interface (custom bound above)
OBJECT_API_B(Cylinder)
