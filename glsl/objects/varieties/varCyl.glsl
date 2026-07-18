//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY IN A CYLINDER
// before including this file, provide the function:
// T varCyl_Eqn(T x, T y, T z)   //the defining equation, in dual numbers
// depends on: objects/computations.glsl (bCyl) — always included
//----------------------------------------------------------------------------------------------

//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(varCyl_Data, varCyl_Eqn)

//-------------------------------------------------
// Building a variety that is thick
//-------------------------------------------------

struct VarCyl{
    //placement in the world
    Frame frame;
    //the bounding cylinder: cyl.x = radius, cyl.y = half-height
    vec2 cyl;
    //smoothing between the bounding cylinder and the variety
    float smoothing;
    //scale of the variety on the inside
    float scale;
    //thickness.x = inside thickness, thickness.y = outside thickness
    vec2 thickness;
    //the material
    Material mat;
};


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
    //thickness.x = inside, thickness.y = outside
    dist=abs(dist+var.thickness.x)-var.thickness.x-var.thickness.y;

    //clip to the bounding cylinder
    float bboxDist = bCyl(p,var.cyl);
    dist = smax(dist,bboxDist,var.smoothing);

    return dist;
}


//local bound: the clip cylinder itself. sdf = smax(surface, bCyl(p,cyl), ...) >= bCyl,
//so this is a conservative underestimate — tighter than a circumscribing sphere.
float bound( vec3 p, VarCyl var ){ return bCyl(p, var.cyl); }

//the standard interface: initObject, at, inside, sdf, normalVec, setData (custom bound above)
OBJECT_API_B(VarCyl)
