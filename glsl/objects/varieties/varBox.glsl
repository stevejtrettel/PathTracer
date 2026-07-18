//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY IN A BOX
// before including this file, provide the function:
// T varBox_Eqn(T x, T y, T z)   //the defining equation, in dual numbers
// depends on: objects/computations.glsl (bBox) — always included
//----------------------------------------------------------------------------------------------

//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(varBox_Data, varBox_Eqn)

//-------------------------------------------------
// Building a variety that is thick
//-------------------------------------------------

struct VarBox{
    //placement in the world
    Frame frame;
    //half-widths of the bounding box
    vec3 box;
    //smoothing between the bounding box and the variety
    float smoothing;
    //scale of the variety on the inside
    float scale;
    //thickness.x = inside thickness, thickness.y = outside thickness
    vec2 thickness;
    //the material
    Material mat;
};


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
    //thickness.x = inside, thickness.y = outside
    dist=abs(dist+var.thickness.x)-var.thickness.x-var.thickness.y;

    //clip to the bounding box
    float bboxDist = bBox(p,var.box);
    dist = smax(dist,bboxDist,var.smoothing);

    return dist;
}


//local bound: the clip box itself. sdf = smax(surface, bBox(p,box), ...) >= bBox,
//so this is a conservative underestimate — tighter than a circumscribing sphere.
float bound( vec3 p, VarBox var ){ return bBox(p, var.box); }

//the standard interface: initObject, at, inside, sdf, normalVec, setData (custom bound above)
OBJECT_API_B(VarBox)
