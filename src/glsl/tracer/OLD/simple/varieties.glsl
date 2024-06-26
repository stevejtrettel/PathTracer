


//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY:
// ALL THAT NEEDS TO BE CHANGED IS THE FUNCTION SURF: THE REST AUTOMATICALLY UPDATES FROM THIS
//----------------------------------------------------------------------------------------------------

T surf(T x, T z, T y){
    return kleinBottleVariety(y,x,z);
    //return enneper(z,x,-y);
    //return mobiusStripVariety(z,-x,-y);
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
// Building a variety that is thick
// ------------------------------------------------

struct Variety{
    vec3 center;
    float size;
    float inside;
    float outside;
    float boundingSphere;
    float smoothing;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Variety surf ){

    //normalize position
    vec3 pos = p - surf.center;
    float rad = length(pos);
    vec3 scaledPos = surf.size*pos;

    //get the distance estimate
    vec4 data = surf_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz)*surf.size;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    dist=abs(dist+surf.inside)-surf.inside-surf.outside;


//    //    stuff for slicing into bits:
//        float sliceThickness=0.1;//6.29/70.;
//        float sliceGap = 0.3;//6.29/35.;
//        float height = pos.y+2.;
//        //atan(pos.z,pos.x)+3.14;
//        //pos.z+3.68;
//    //    float height2 = pos.x+3.68;
//    //    float height3 = pos.y+3.68;
//        float sphDist = abs(height)-sliceThickness;
//        for(int i=0; i<45; i++){
//            height -= sliceGap;
//    //        height2 -= sliceGap;
//    //        height3 -= sliceGap;
//            sphDist = min(sphDist, abs(height)-sliceThickness);
//    //        sphDist = min(sphDist, abs(height2)-sliceThickness);
//    //        sphDist = min(sphDist, abs(height3)-sliceThickness);
//        }
//        //cut with slices
//        dist = smax(dist,sphDist,surf.smoothing);
//




    // //bounding sphere
    //float bboxDist = rad-surf.boundingSphere;

    // //bounding cylinder
    //    float bboxDist = length(pos.xy)-surf.boundingSphere;
    //    bboxDist = max(bboxDist, abs(pos.z)-4.5);

    //bounding box
    vec3 q = abs(pos) - vec3(surf.boundingSphere);
    float bboxDist =  length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);

    //adjust for the bounding box
    dist = smax(dist,bboxDist,surf.smoothing);


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



























//-------------------------------------------------
// Building a variey that is infinitesimally thin
// -------------------------

struct ThinVariety{
    vec3 center;
    float size;
    float boundingSphere;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, ThinVariety surf ){

    //normalize position
    vec3 pos = p - surf.center;
    float rad = length(pos);
    vec3 scaledPos = surf.size*pos;

    //get the distance estimate
    vec4 data = surf_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz)*surf.size;
    float dist = DE(val, gradLength);

    dist=abs(dist);



    //---A Bounding Box---------------

    // //bounding sphere
    float bboxDist = rad-surf.boundingSphere;

    // //bounding cylinder
    //    float bboxDist = length(pos.xy)-surf.boundingSphere;
    //    bboxDist = max(bboxDist, abs(pos.z)-4.5);

    //adjust for the bounding box
    dist = max(dist,bboxDist);


    // return dist;
    return dist+0.001;
}


//overload of distR3 and sdf
float distR3( Vector tv, ThinVariety surf ){
    float dist = distR3(tv.pos,surf);
    return dist;
}

float sdf( Vector tv, ThinVariety surf ){
    return distR3(tv.pos, surf);
}


//overload of location booleans:
bool at( Vector tv, ThinVariety surf){
    float d = distR3( tv.pos, surf );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, ThinVariety surf ){
    float d = distR3( tv.pos, surf );
    return (d<0.);
}


Vector normalVec( Vector tv, ThinVariety surf ){

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

//setData for a two sided surface
void setData( inout Path path, ThinVariety surf ){

    //if we are at the surface
    if(at(path.tv, surf)){
        //compute the normal
        Vector normal=normalVec(path.tv,surf);
        Material mat=surf.mat;

        //check if we are on the outside edge:
        float rad = length(path.tv.pos-surf.center);
        bool onEdge = (abs(rad-surf.boundingSphere)<0.005);

        if(onEdge){
            mat.diffuseColor=vec3(0.0);
            //set the material
            setObjectInAir(path.dat, false, normal, mat);
        }
        else {

            //what side of the variety are we on?
            vec3 pos = path.tv.pos - surf.center;
            pos *= surf.size;
            float val= surf_Data(pos).w;
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



