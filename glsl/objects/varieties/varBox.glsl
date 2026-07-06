
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY IN RECTANGULAR BOUNDING BOX:
// before including this file need to provide the function:
// T varEqn(T x, T y, T z)
//----------------------------------------------------------------------------------------------------


//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(varBox_Data, varBox_Eqn)

//-------------------------------------------------
// Building a variety that is thick
// ------------------------------------------------

struct VarBox{
//placement in the world
    Frame frame;
//the bounding box
    vec3 box;
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
float bBox(vec3 pos, vec3 box){
    vec3 q = abs(pos) - box;
    float bboxDist =  length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
    return bboxDist;
}



//the point-level sdf (local coordinates)
float sdf( vec3 p, VarBox var ){

    //internal zoom of the defining equation
    vec3 scaledPos = var.scale * p;

    //get the distance estimate
    vec4 data = varBox_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * var.scale;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    //thickness.x = inside, thickness.y = outisde
    dist=abs(dist+var.thickness.x)-var.thickness.x-var.thickness.y;

    // //bounding box
    float bboxDist = bBox(p,var.box);

    //adjust for the bounding box
    dist = smax(dist,bboxDist,var.smoothing);

    //return dist;
    return dist;
}



//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(VarBox)
