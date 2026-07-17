//-------------------------------------------------
//The TORUS sdf
//-------------------------------------------------

struct Torus{
    Frame frame;
    float innerR;
    float outerR;
    Material mat;
};


//signed dist in terms of basic parameters
//ra = ring radius (center of tube to origin), rb = tube radius
float sdTorus( vec3 pos, float ra, float rb  ){
    //rotate so the torus stands vertically (symmetry axis = z)
    vec3 p = vec3(pos.x,pos.z,-pos.y);

    float h = length(p.xz);
    float dist =  length(vec2(h-ra,p.y))-rb;

    return dist;
}


//the local-frame sdf (a vertical torus about the origin)
//note: outerR is the ring radius, innerR the tube radius
float sdf( vec3 pos, Torus torus ){
    return sdTorus(pos, torus.outerR, torus.innerR);
}

//the standard interface
OBJECT_API(Torus)
