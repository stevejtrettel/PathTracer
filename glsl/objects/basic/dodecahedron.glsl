
#include ./gdf.glsl

float fDodecahedron(vec3 p, float r) {
    fGDFBegin
    fGDF(GDFVector13) fGDF(GDFVector14) fGDF(GDFVector15) fGDF(GDFVector16)
    fGDF(GDFVector17) fGDF(GDFVector18)
    fGDFEnd
}

float sdf_dodecahedron(vec3 p) {
    const float scale = 0.7;
    p *= 1./scale;
    return fDodecahedron(p, 1.0) * scale;
}


//-------------------------------------------------
//The DODECAHEDRON sdf
//-------------------------------------------------

struct Dodecahedron{
    Frame frame;
    Material mat;
};


//the local-frame sdf: the unit-sized shape at the origin
float sdf( vec3 p, Dodecahedron obj ){
    return sdf_dodecahedron(p);
}

//the standard interface (placement handled by the frame)
OBJECT_API(Dodecahedron)
