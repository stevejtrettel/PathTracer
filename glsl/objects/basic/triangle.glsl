//-------------------------------------------------
//The TRIANGLE sdf
//-------------------------------------------------

//an equilateral triangle prism; rotate it via the frame (makeFrame(pos, axis, angle))

struct Triangle{
    Frame frame;
    float side;
    float thickness;
    Material mat;
};


//the local-frame sdf
float sdf( vec3 p, Triangle obj ){
    vec3 q = abs(p);
    return max(q.z-obj.thickness,max(q.x*0.86602+p.y*0.5,-p.y)-obj.side*0.5);
}

//the standard interface
OBJECT_API(Triangle)
