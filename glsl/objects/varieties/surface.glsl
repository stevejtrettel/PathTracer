//----------------------------------------------------------------------------------------------
// ADJUSTABLE SURFACE, CUSTOM BOUND: an infinitesimally thin variety
// before including this file, provide TWO functions:
// T surface_Eqn(T x, T y, T z)     //the defining equation, in dual numbers
// float surface_bBox( vec3 pos )   //sdf of the bounding region that clips it
//----------------------------------------------------------------------------------------------

//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(surface_Data, surface_Eqn)

//-------------------------------------------------
// Building a variety that is infinitesimally thin
//-------------------------------------------------

struct ThinSurface{
    Frame frame;
    float scale;
    Material mat;
};


//the point-level sdf (local coordinates)
float sdf( vec3 p, ThinSurface surf ){

    //internal zoom of the defining equation
    vec3 scaledPos = surf.scale * p;

    //get the distance estimate
    vec4 data = surface_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * surf.scale;
    float dist = DE(val, gradLength);

    dist=abs(dist);

    //clip to the bounding region
    float bboxDist = surface_bBox(p);
    dist = max(dist,bboxDist);

    return dist;
}


//local bound: the clip region itself. sdf = max(|surface|, surface_bBox), so
//surface_bBox is a conservative underestimate — the object is contained in it.
float bound( vec3 p, ThinSurface surf ){ return surface_bBox(p); }

//the standard interface: initObject, at, inside, sdf, normalVec (custom bound above)
OBJECT_INIT(ThinSurface)
OBJECT_LOCATORS_B(ThinSurface)
OBJECT_NORMAL_FD(ThinSurface)

//setData for a two sided surface
void setData( inout Path path, ThinSurface surf ){

    //if we are at the surface
    if(at(path.tv, surf)){
        //compute the normal
        Vector normal=normalVec(path.tv,surf);
        Material mat=surf.mat;

        //local position on the surface
        vec3 q = toLocal(surf.frame, path.tv.pos);

        //check if we are on the outside edge:
        //(edge threshold is in LOCAL units: with frame.scale != 1
        // the corresponding world-space band scales by frame.scale)
        bool onEdge = abs(surface_bBox(q))<0.005;

        if(onEdge){
            //average of the front color and the white back
            mat.surf.diffuse=0.5*(mat.surf.diffuse + vec3(1.));
            //set the material
            setObjectInAir(path.dat, false, normal, mat);
        }
        else {

            //what side of the variety are we on?
            vec3 pos = surf.scale * q;
            float val= surface_Data(pos).w;
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
