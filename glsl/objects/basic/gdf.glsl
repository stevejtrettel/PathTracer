#ifndef gdf_glsl
#define gdf_glsl

//-------------------------------------------------
// GDF (generalized distance function) machinery
// shared by dodecahedron.glsl and icosahedron.glsl:
// a polyhedron as the intersection of slabs along symmetry directions
//-------------------------------------------------

//golden ratio, used by the GDF direction vectors below
#define PHI 1.6180339887

#define GDFVector3 normalize(vec3(1, 1, 1 ))
#define GDFVector4 normalize(vec3(-1, 1, 1))
#define GDFVector5 normalize(vec3(1, -1, 1))
#define GDFVector6 normalize(vec3(1, 1, -1))

#define GDFVector7 normalize(vec3(0, 1, PHI+1.))
#define GDFVector8 normalize(vec3(0, -1, PHI+1.))
#define GDFVector9 normalize(vec3(PHI+1., 0, 1))
#define GDFVector10 normalize(vec3(-PHI-1., 0, 1))
#define GDFVector11 normalize(vec3(1, PHI+1., 0))
#define GDFVector12 normalize(vec3(-1, PHI+1., 0))

#define GDFVector13 normalize(vec3(0, PHI, 1))
#define GDFVector14 normalize(vec3(0, -PHI, 1))
#define GDFVector15 normalize(vec3(1, 0, PHI))
#define GDFVector16 normalize(vec3(-1, 0, PHI))
#define GDFVector17 normalize(vec3(PHI, 1, 0))
#define GDFVector18 normalize(vec3(-PHI, 1, 0))

#define fGDFBegin float d = 0.;
#define fGDF(v) d = max(d, abs(dot(p, v)));
#define fGDFEnd return d - r;

#endif
