
#include ./gdf.glsl

float fIcosahedron(vec3 p, float r) {
    fGDFBegin
    fGDF(GDFVector3) fGDF(GDFVector4) fGDF(GDFVector5) fGDF(GDFVector6)
    fGDF(GDFVector7) fGDF(GDFVector8) fGDF(GDFVector9) fGDF(GDFVector10)
    fGDF(GDFVector11) fGDF(GDFVector12)
    fGDFEnd
}

float sdf_icosahedron(vec3 p) {
    const float scale = 0.7;
    p *= 1./scale;
    return fIcosahedron(p, 1.0) * scale;
}


//-------------------------------------------------
//The ICOSAHEDRON sdf
//-------------------------------------------------

struct Icosahedron{
    Frame frame;
    Material mat;
};


//the local-frame sdf: the unit-sized shape at the origin
float sdf( vec3 p, Icosahedron obj ){
    return sdf_icosahedron(p);
}

//the standard interface (placement handled by the frame)
OBJECT_API(Icosahedron)
