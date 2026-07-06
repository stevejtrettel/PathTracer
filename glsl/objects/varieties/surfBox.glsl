
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY:
// ALL THAT NEEDS TO BE CHANGED IS THE FUNCTION SURF: THE REST AUTOMATICALLY UPDATES FROM THIS
//----------------------------------------------------------------------------------------------------


//gradient (xyz) and value (w) of the defining equation
VARIETY_DATA(surfBox_Data, surfBox_Eqn)



//-------------------------------------------------
// Building a variey that is infinitesimally thin
// -------------------------

struct SurfBox{
    vec3 center;
    vec3 box;
    float scale;
    Material mat;
};


//dist to bounding box
float bBox(vec3 pos, vec3 box){
    vec3 q = abs(pos) -box;
    float bboxDist =  length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
    return bboxDist;
}



//the point-level sdf
float sdf( vec3 p, SurfBox surf ){

    //normalize position
    vec3 pos = p - surf.center;
    vec3 scaledPos = surf.scale * pos;

    //get the distance estimate
    vec4 data = surfBox_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz) * surf.scale;
    float dist = DE(val, gradLength);

    dist=abs(dist);

    //bounding sphere
    float bboxDist = bBox(pos,surf.box);
    dist = max(dist,bboxDist);

    return dist;
}


//the standard interface: at, inside, sdf, normalVec
OBJECT_LOCATORS(SurfBox)
OBJECT_NORMAL_FD(SurfBox)

//setData for a two sided surface
void setData( inout Path path, SurfBox surf ){

    //if we are at the surface
    if(at(path.tv, surf)){
        //compute the normal
        Vector normal=normalVec(path.tv,surf);
        Material mat=surf.mat;

        //check if we are on the outside edge:
        vec3 pos = path.tv.pos-surf.center;
        bool onEdge = abs(bBox(pos,surf.box))<0.005;

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
            float val= surfBox_Data(pos).w;
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



