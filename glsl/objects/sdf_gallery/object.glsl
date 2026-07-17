//the gallery object is chosen by swapping this include: each sdfs/ file provides float sdf(vec3 p), and only ONE can be compiled at a time (their internal helper names collide)
#include ./sdfs/Vase.glsl

//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

//the data of a gallery object is its frame and its material
struct Object{
    Frame frame;
    Material mat;
};


//the local-frame sdf
//NOTE: sdf(p) below is the vendored one-argument gallery sdf;
//this two-argument version is an overload of it, not a recursion
float sdf( vec3 p, Object obj ){
    return sdf(p);
}

//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(Object)
