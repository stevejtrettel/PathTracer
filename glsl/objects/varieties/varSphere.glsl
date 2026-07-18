//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY IN A SPHERE
// before including this file, provide the function:
// T varSphere_Eqn(T x, T y, T z)   //the defining equation, in dual numbers
//----------------------------------------------------------------------------------------------

//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(varSphere_Data, varSphere_Eqn)

//-------------------------------------------------
// Building a variety that is thick
//-------------------------------------------------

struct VarSphere{
    //placement in the world
    Frame frame;
    //radius of the bounding sphere
    float radius;
    //smoothing between the bounding sphere and the variety
    float smoothing;
    //scale of the variety on the inside
    float scale;
    //thickness.x = inside thickness, thickness.y = outside thickness
    vec2 thickness;
    //the material
    Material mat;
};


//the point-level sdf (local coordinates)
float sdf( vec3 p, VarSphere var ){

    //internal zoom of the defining equation
    vec3 scaledPos = var.scale * p;

    //get the distance estimate
    vec4 data = varSphere_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * var.scale;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    //thickness.x = inside, thickness.y = outside
    dist=abs(dist+var.thickness.x)-var.thickness.x-var.thickness.y;

    //clip to the bounding sphere
    float bboxDist = length(p)-var.radius;
    dist = smax(dist,bboxDist,var.smoothing);

    return dist;
}


//local bounding sphere, padded for the smax rounding and the outward thickness
//so the soft edge is never clipped
float bound( vec3 p, VarSphere var ){ return length(p) - (var.radius + var.smoothing + var.thickness.y); }

//the standard interface: initObject, at, inside, sdf, normalVec, setData (custom bound above)
OBJECT_API_B(VarSphere)
