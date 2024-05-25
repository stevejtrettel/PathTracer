


//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY:
// ALL THAT NEEDS TO BE CHANGED IS THE FUNCTION SURF: THE REST AUTOMATICALLY UPDATES FROM THIS
//----------------------------------------------------------------------------------------------------

T surf(T x, T y, T z){
    return sexticStereo(z,y,x);
}

vec4 surf_Data( vec3 p ){

    //Compute gradient.
    T vx = surf( T(p.x, 1.), T(p.y, 0.), T(p.z, 0.) );
    T vy = surf( T(p.x, 0.), T(p.y, 1.), T(p.z, 0.) );
    T vz = surf( T(p.x, 0.), T(p.y, 0.), T(p.z, 1.) );
    vec3 grad = vec3(vx.y,vy.y,vz.y);

    //the value of the function is automatically computed in each of the above:
    float val = vx.x;

    return vec4(grad,val);
}


//-------------------------------------------------
// my stuff: building the sextic in our world
// -------------------------

struct Variety{
    vec3 center;
    float size;
    float inside;
    float outside;
    float boundingSphere;
    float smoothing;
    Material mat;
};


float checkerBox( vec3 p, vec3 b )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Variety surf ){

    //normalize position
    vec3 pos = p - surf.center;
    float rad = length(pos);
    pos *= surf.size;

    //get the distance estimate
    vec4 data = surf_Data(pos);
    float val = data.w;
    float gradLength = length(data.xyz)*surf.size;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    dist=abs(dist+surf.inside)-surf.inside-surf.outside;



    //vec3 q = abs(pos) - vec3(20,8,20);
    //float bboxDist = length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);

    //float bboxDist = abs(pos.y)-1.;

    float bboxDist = rad-surf.boundingSphere;

    //adjust for the bounding box
    dist = smax(dist,bboxDist,surf.smoothing);



    //if we are inside the variety now, we compute the checkerboard pattern:
//    float checkerdist;
//        vec3 modpos=20.*pos;
//        checkerdist = sin(modpos.x)*sin(modpos.y)*sin(modpos.z)-0.7;
//        return max(dist,checkerdist);


    return dist+0.001;
}



float distR3( Vector tv, Variety surf ){

    float dist = distR3(tv.pos,surf);

//    //normalize position
//    vec3 pos = tv.pos - surf.center;
//    float rad = length(pos);
//    pos *= surf.size;
//
//    //get the distance estimate
//    vec4 data = surf_Data(pos);
//    float val = data.w;
//    float gradLength = length(data.xyz)/surf.size;
//    float dist = DE(val, gradLength);
//
//    //adjust to account for thickness of surface
//    dist=abs(dist+surf.inside)-surf.inside-surf.outside;
//    //adjust for the bounding box
//    dist = smax(dist,rad-surf.boundingSphere,surf.smoothing);

    return dist;
}

//overload of location booleans:
bool at( Vector tv, Variety surf){
    float d = distR3( tv.pos, surf );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Variety surf ){
    float d = distR3( tv.pos, surf );
    return (d<0.);
}

//overload of sdf for a sphere
float sdf( Vector tv, Variety surf ){
    //distance to closest point on sphere
    return distR3(tv.pos, surf);
}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Variety surf ){

    vec3 pos =tv.pos;
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;//this normalization makes exyy etc all unit vectors;

    float vxyy=distR3( pos + e.xyy*ep, surf);
    float vyyx=distR3( pos + e.yyx*ep, surf);
    float vyxy=distR3( pos + e.yxy*ep, surf);
    float vxxx=distR3( pos + e.xxx*ep, surf);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

////setData for a two sided surface
//void setData( inout Path path, Variety surf ){
//
//    //if we are at the surface
//    if(at(path.tv, surf)){
//        //compute the normal
//        Vector normal=normalVec(path.tv,surf);
//        Material mat=surf.mat;
//
//        //check if we are on the outside edge:
//        float rad = length(path.tv.pos-surf.center);
//        bool onEdge = (abs(rad-surf.boundingSphere)<0.005);
//
//        if(onEdge){
//            mat.diffuseColor=vec3(0.0);
//            //set the material
//            setObjectInAir(path.dat, false, normal, mat);
//        }
//        else {
//
//            //what side of the variety are we on?
//            vec3 pos = path.tv.pos - surf.center;
//            pos *= surf.size;
//            float val= surf_Data(pos).w;
//            //val positive is one side, val negative is the other;
//
//            if(val<0.){
//                mat.diffuseColor=surf.mat.diffuseColorBack;
//            }
//            else{
//                mat.diffuseColor=surf.mat.diffuseColor;
//            }
//
//            bool side = inside(path.tv, surf);
//            setObjectInAir(path.dat, side, normal, mat);
//        }
//    }
//
//}



//setData for a single sided, volume material
void setData( inout Path path, Variety surf ){

    //if we are at the surface
    if(at(path.tv, surf)){

        //compute the normal
        Vector normal=normalVec(path.tv,surf);
        Material mat=surf.mat;

        bool side = inside(path.tv, surf);
        setObjectInAir(path.dat, side, normal, mat);
        }
}























