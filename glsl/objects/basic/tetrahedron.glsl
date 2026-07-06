

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
    Frame frame;
    Material mat;
};


//the local-frame sdf: the unit-sized shape at the origin
float sdf( vec3 p, Tetrahedron obj ){
    return sdf_tetrahedron(p);
}

//the standard interface (placement handled by the frame)
OBJECT_API(Tetrahedron)
