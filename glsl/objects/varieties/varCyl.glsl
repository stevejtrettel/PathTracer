
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY IN RECTANGULAR BOUNDING BOX:
// before including this file need to provide the function:
// T varEqn(T x, T y, T z)
//----------------------------------------------------------------------------------------------------


//use the variety equation to compute gradient and value
//for use in the raymarch
vec4 varCyl_Data( vec3 p ){

    //Compute gradient.
    T vx = varCyl_Eqn( T(p.x, 1.), T(p.y, 0.), T(p.z, 0.) );
    T vy = varCyl_Eqn( T(p.x, 0.), T(p.y, 1.), T(p.z, 0.) );
    T vz = varCyl_Eqn( T(p.x, 0.), T(p.y, 0.), T(p.z, 1.) );
    vec3 grad = vec3(vx.y,vy.y,vz.y);

    //the value of the function is automatically computed in each of the above:
    float val = vx.x;

    return vec4(grad,val);
}

//-------------------------------------------------
// Building a variety that is thick
// ------------------------------------------------

struct VarCyl{
//the bounding cylinder
    vec3 center;
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

//the point-level sdf
float sdf( vec3 p, VarCyl var ){

    //normalize position
    vec3 pos = p - var.center;
    vec3 scaledPos = var.scale * pos;

    //get the distance estimate
    vec4 data = varCyl_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * var.scale;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    //thickness.x = inside, thickness.y = outisde
    dist=abs(dist+var.thickness.x)-var.thickness.x-var.thickness.y;

    // //bounding box
    float bboxDist = bCyl(pos,var.cyl);

    //adjust for the bounding box
    dist = smax(dist,bboxDist,var.smoothing);

    //return dist;
    return dist;
}



//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(VarCyl)
