//----------------------------------------------------------------------------------------------
// ADJUSTABLE SURFACE IN A SPHERE: an infinitesimally thin variety
// before including this file, provide the function:
// T surfSphere_Eqn(T x, T y, T z)   //the defining equation, in dual numbers
//----------------------------------------------------------------------------------------------

//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(surfSphere_Data, surfSphere_Eqn)

//-------------------------------------------------
// Building a variety that is infinitesimally thin
//-------------------------------------------------

struct SurfSphere{
    Frame frame;
    //radius of the bounding sphere
    float radius;
    float scale;
    Material mat;
};


//the point-level sdf (local coordinates)
float sdf( vec3 p, SurfSphere surf ){

    //internal zoom of the defining equation
    vec3 scaledPos = surf.scale * p;

    //get the distance estimate
    vec4 data = surfSphere_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * surf.scale;
    float dist = DE(val, gradLength);

    dist=abs(dist);

    //clip to the bounding sphere
    float bboxDist = length(p)-surf.radius;
    dist = max(dist,bboxDist);

    return dist;
}


//local bounding sphere: the surface is hard-clipped to this sphere
float bound( vec3 p, SurfSphere surf ){ return length(p) - surf.radius; }

//the standard interface: initObject, at, inside, sdf, normalVec
OBJECT_INIT(SurfSphere)
OBJECT_LOCATORS_B(SurfSphere)
OBJECT_NORMAL_FD(SurfSphere)

//setData for a two sided surface
void setData( inout Path path, SurfSphere surf ){

    //if we are at the surface
    if(at(path.tv, surf)){
        //compute the normal
        Vector normal=normalVec(path.tv,surf);
        Material mat=surf.mat;

        //local position on the surface
        vec3 q = toLocal(surf.frame, path.tv.pos);

        //check if we are on the outside edge:
        //(compare in LOCAL units against surf.radius: with frame.scale != 1
        // the corresponding world-space band scales by frame.scale)
        float rad = length(q);
        bool onEdge = (abs(rad-surf.radius)<0.005);

        if(onEdge){
            //average of the front color and the white back
            mat.surf.diffuse=0.5*(mat.surf.diffuse + vec3(1.));
            //set the material
            setObjectInAir(path.dat, false, normal, mat);
        }
        else {

            //what side of the variety are we on?
            vec3 pos = surf.scale * q;
            float val= surfSphere_Data(pos).w;
            //val positive is one side, val negative is the other;

            if(val<0.){
                mat=makeMatte(vec3(1.));   //the BACK side: white (the old default look)
            }
            else{
                mat=surf.mat;
            }

            bool side = inside(path.tv, surf);
            setObjectInAir(path.dat, side, normal, mat);
        }
    }

}
