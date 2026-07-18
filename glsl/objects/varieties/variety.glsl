//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY, CUSTOM BOUND
// before including this file, provide TWO functions:
// T var_Eqn(T x, T y, T z)      //the defining equation, in dual numbers
// float var_bBox( vec3 pos )    //sdf of the bounding region that clips it
//----------------------------------------------------------------------------------------------

//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(var_Data, var_Eqn)

//-------------------------------------------------
// Building a variety that is thick
//-------------------------------------------------

struct Variety{
    //placement in the world
    Frame frame;
    //smoothing between the bounding region and the variety
    float smoothing;
    //scale of the variety on the inside
    float scale;
    //thickness.x = inside thickness, thickness.y = outside thickness
    vec2 thickness;
    //the material
    Material mat;
};


//the point-level sdf (local coordinates)
float sdf( vec3 p, Variety var ){

    //internal zoom of the defining equation
    vec3 scaledPos = var.scale * p;

    //get the distance estimate
    vec4 data = var_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * var.scale;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    //thickness.x = inside, thickness.y = outside
    dist=abs(dist+var.thickness.x)-var.thickness.x-var.thickness.y;

    //clip to the bounding region
    float bboxDist = var_bBox(p);
    dist = smax(dist,bboxDist,var.smoothing);

    return dist;
}


//local bound: the clip region itself. The sdf is smax(surface, var_bBox, ...),
//and smax >= max >= var_bBox, so var_bBox is a conservative underestimate — the
//object is contained in the clip region, and this is the exact clip term reused.
float bound( vec3 p, Variety var ){ return var_bBox(p); }

//the standard interface: initObject, at, inside, sdf, normalVec, setData (custom bound above)
OBJECT_API_B(Variety)
