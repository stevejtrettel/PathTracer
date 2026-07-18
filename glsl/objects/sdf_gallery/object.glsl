//the gallery object is chosen by swapping this include: each sdfs/ file provides float sdf(vec3 p), and only ONE can be compiled at a time (their internal helper names collide)
#include ./sdfs/Vase.glsl

//local bounding radius for the CURRENTLY-INCLUDED model, in object-local units.
//SET THIS TOGETHER WITH THE #include ABOVE. It must be >= the model's local extent
//or the model is clipped; the tighter it is, the sooner far-away rays skip the
//(expensive) gallery sdf. Known extents: most models <= 1.5; PixarMike and
//Serpinski reach ~3. When in doubt, err large.
const float GALLERY_BOUND = 2.0;   //safe for Vase

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

//local bounding sphere: the model is contained in radius GALLERY_BOUND (set above)
float bound( vec3 p, Object obj ){ return length(p) - GALLERY_BOUND; }

//the standard interface: initObject, at, inside, sdf, normalVec, setData (custom bound above)
OBJECT_API_B(Object)
