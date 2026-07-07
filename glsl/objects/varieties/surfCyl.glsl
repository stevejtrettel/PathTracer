
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY:
// ALL THAT NEEDS TO BE CHANGED IS THE FUNCTION SURF: THE REST AUTOMATICALLY UPDATES FROM THIS
//----------------------------------------------------------------------------------------------------


//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(surfCyl_Data, surfCyl_Eqn)



//-------------------------------------------------
// Building a variey that is infinitesimally thin
// -------------------------

struct SurfCyl{
    Frame frame;
    vec2 cyl;
    float scale;
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
float sdf( vec3 p, SurfCyl surf ){

    //internal zoom of the defining equation
    vec3 scaledPos = surf.scale * p;

    //get the distance estimate
    vec4 data = surfCyl_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * surf.scale;
    float dist = DE(val, gradLength);

    dist=abs(dist);

    //bounding cylinder
    float bboxDist = bCyl(p,surf.cyl);
    dist = max(dist,bboxDist);

    return dist;
}


//local bounding radius: the surface is hard-clipped to this cylinder (rad,height)
float bound( SurfCyl surf ){ return length(surf.cyl); }

//the standard interface: initObject, at, inside, sdf, normalVec
OBJECT_INIT(SurfCyl)
OBJECT_LOCATORS_B(SurfCyl)
OBJECT_NORMAL_FD(SurfCyl)

//setData for a two sided surface
void setData( inout Path path, SurfCyl surf ){

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
        bool onEdge = abs(bCyl(q,surf.cyl))<0.005;

        if(onEdge){
            //average of the two side colors
            mat.diffuseColor=0.5*(mat.diffuseColor + mat.diffuseColorBack);
            //set the material
            setObjectInAir(path.dat, false, normal, mat);
        }
        else {

            //what side of the variety are we on?
            vec3 pos = surf.scale * q;
            float val= surfCyl_Data(pos).w;
            //val positive is one side, val negative is the other;

            if(val<0.){
                mat.diffuseColor=surf.mat.diffuseColorBack;
            }
            else{
                mat.diffuseColor=surf.mat.diffuseColor;
            }

            bool side = inside(path.tv, surf);
            setObjectInAir(path.dat, side, normal, mat);
        }
    }

}



