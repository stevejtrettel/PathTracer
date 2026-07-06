

//-------------------------------------------------
//The TRIANGLE sdf
//-------------------------------------------------

//the data of a triantle prism is its center and radius
struct Triangle{
    vec3 center;
    mat3 orientation;
    float side;
    float thickness;
    Material mat;
};


//the point-level sdf
float sdf( vec3 p, Triangle obj ){
    //normalize position
    p = p - obj.center;
    p = obj.orientation * p;

    vec3 q = abs(p);
    return max(q.z-obj.thickness,max(q.x*0.86602+p.y*0.5,-p.y)-obj.side*0.5);
}

//the standard interface: at, inside, sdf, normalVec, setData
UNFRAMED_OBJECT_API(Triangle)
