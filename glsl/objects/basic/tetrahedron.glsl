

float sdf_tetrahedron(vec3 p) {
    p *= 0.5;
    return max(
    // Vertical bound
    abs(p.y) - 0.5,

    // Horizontal bound
    max(abs(p.x) * 0.866025 + p.z * 0.5, -p.z) - 0.25 * abs(0.5 - p.y)
    ) * 2.0;
}


//-------------------------------------------------
//The TETRAHEDRON sdf
//-------------------------------------------------

struct Tetrahedron{
    vec3 center;
    float size;
    Material mat;
};


//the point-level sdf
float sdf( vec3 p, Tetrahedron obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdf_tetrahedron(pos);
}

//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(Tetrahedron)
