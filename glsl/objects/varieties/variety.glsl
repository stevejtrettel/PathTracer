
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY IN SPHERICAL BOUNDING BOX:
// before including this file need to provide TWO functions:
// T var_Eqn(T x, T y, T z)
// float var_bBox( vec3 pos )
//----------------------------------------------------------------------------------------------------


//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(var_Data, var_Eqn)

//-------------------------------------------------
// Building a variety that is thick
// ------------------------------------------------

struct Variety{
    //the bounding sphere
    vec3 center;
    //smoothing between bounding box and variety
    float smoothing;
    //scale of the variety on the inside
    float scale;
    //thickness.x = inside thickness, thickness.y = outside thickness
    vec2 thickness;
    //the material
    Material mat;
};


//the point-level sdf
float sdf( vec3 p, Variety var ){

    //normalize position
    vec3 pos = p - var.center;
    vec3 scaledPos = var.scale * pos;

    //get the distance estimate
    vec4 data = var_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * var.scale;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    //thickness.x = inside, thickness.y = outisde
    dist=abs(dist+var.thickness.x)-var.thickness.x-var.thickness.y;

    // //bounding sphere
    float bboxDist = var_bBox(pos);

    //adjust for the bounding box
    dist = smax(dist,bboxDist,var.smoothing);

    //return dist;
    return dist;
}



//the standard interface: at, inside, sdf, normalVec, setData
UNFRAMED_OBJECT_API(Variety)
