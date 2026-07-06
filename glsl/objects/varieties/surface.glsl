
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY:
//
//----------------------------------------------------------------------------------------------------


//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(surface_Data, surface_Eqn)



//-------------------------------------------------
// Building a variey that is infinitesimally thin
// -------------------------

struct Surface{
    vec3 center;
    float scale;
    Material mat;
};


//the point-level sdf
float sdf( vec3 p, Surface surf ){

    //normalize position
    vec3 pos = p - surf.center;
    vec3 scaledPos = surf.scale * pos;

    //get the distance estimate
    vec4 data = surface_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * surf.scale;
    float dist = DE(val, gradLength);

    dist=abs(dist);

    //bounding sphere
    float bboxDist = surface_bBox(pos);
    dist = max(dist,bboxDist);

    // return dist;
    return dist;
}


//the standard interface: at, inside, sdf, normalVec
OBJECT_LOCATORS(Surface)
OBJECT_NORMAL_FD(Surface)

//setData for a two sided surface
void setData( inout Path path, Surface surf ){

    //if we are at the surface
    if(at(path.tv, surf)){
        //compute the normal
        Vector normal=normalVec(path.tv,surf);
        Material mat=surf.mat;

        //check if we are on the outside edge:
        vec3 pos = path.tv.pos-surf.center;
        bool onEdge = abs(surface_bBox(pos))<0.005;

        if(onEdge){
            //average of the two side colors
            mat.diffuseColor=0.5*(mat.diffuseColor + mat.diffuseColorBack);
            //set the material
            setObjectInAir(path.dat, false, normal, mat);
        }
        else {

            //what side of the variety are we on?
            vec3 pos = path.tv.pos - surf.center;
            pos *= surf.scale;
            float val= surface_Data(pos).w;
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



