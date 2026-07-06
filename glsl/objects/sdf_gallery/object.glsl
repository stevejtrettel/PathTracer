#include ./sdfs/Vase.glsl

//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Object{
    vec3 center;
    Material mat;
};


//the point-level sdf
//NOTE: sdf(pos) below is the vendored one-argument gallery sdf;
//this two-argument version is an overload of it, not a recursion
float sdf( vec3 p, Object obj ){
    //normalize position
    vec3 pos = p - obj.center;

    return sdf(pos);
}

//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(Object)
