
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY IN RECTANGULAR BOUNDING BOX:
// before including this file need to provide the function:
// T varEqn(T x, T y, T z)
//----------------------------------------------------------------------------------------------------


//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(varCyl_Data, varCyl_Eqn)

//-------------------------------------------------
// Building a variety that is thick
// ------------------------------------------------

struct VarCyl{
//placement in the world
    Frame frame;
//the bounding cylinder
    vec2 cyl;//dims.x=rad, dims.y=height
//smoothing between bounding sphere and variety
    float smoothing;
//scale of the variety on the inside
    float scale;
//thickness.x = inside thickness, thickness.y = outside thickness
    vec2 thickness;
//the material
    Material mat;
};



//dist to bounding box
float bCyl(vec3 pos, vec2 cyl){

    float r = length(pos.xz)-cyl.x;
    float h = abs(pos.y)-cyl.y;
    float bboxDist = max(r,h);

    return bboxDist;
}

//the point-level sdf (local coordinates)
float sdf( vec3 p, VarCyl var ){

    //internal zoom of the defining equation
    vec3 scaledPos = var.scale * p;

    //get the distance estimate
    vec4 data = varCyl_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * var.scale;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    //thickness.x = inside, thickness.y = outisde
    dist=abs(dist+var.thickness.x)-var.thickness.x-var.thickness.y;

    // //bounding box
    float bboxDist = bCyl(p,var.cyl);

    //adjust for the bounding box
    dist = smax(dist,bboxDist,var.smoothing);

    //return dist;
    return dist;
}



//local bounding radius: cylinder (rad,height) extent, padded for the smax
//rounding and the outward thickness so the soft edge is never clipped
float bound( VarCyl var ){ return length(var.cyl) + var.smoothing + var.thickness.y; }

//the standard interface: initObject, at, inside, sdf, normalVec, setData (custom bound above)
OBJECT_API_B(VarCyl)
