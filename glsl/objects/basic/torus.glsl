

//-------------------------------------------------
//The TORUS sdf
//-------------------------------------------------

//the data of a torus is its inner and outer radii, and its center
//(also orientation, but for now all tori are vertical until I am more careful)


struct Torus{
    vec3 center;
    float innerR;
    float outerR;
    Material mat;
};




//signed dist in terms of basic parameters
float sdTorus( vec3 pos, float ra, float rb  ){
    //normalize position
    vec3 p = vec3(pos.x,pos.z,-pos.y);

    float h = length(p.xz);
    float dist =  length(vec2(h-ra,p.y))-rb;

    return dist;
}


//the point-level sdf
float sdf( vec3 pos, Torus torus ){
    //normalize position
    pos = vec3(pos.x,pos.z,-pos.y);
    vec3 p = (pos - torus.center);

    float rb = torus.innerR;
    float ra = torus.outerR;

    float h = length(p.xz);
    float dist =  length(vec2(h-ra,p.y))-rb;

    return dist;
}

//the standard interface: at, inside, sdf, normalVec, setData
UNFRAMED_OBJECT_API(Torus)
