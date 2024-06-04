
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY:
// ALL THAT NEEDS TO BE CHANGED IS THE FUNCTION SURF: THE REST AUTOMATICALLY UPDATES FROM THIS
//----------------------------------------------------------------------------------------------------

T varEqn(T x, T z, T y){
    return togliatti(x,z,y);
    //return enneper(z,x,-y);
    //return mobiusStripVariety(z,-x,-y);
}


vec4 var_Data( vec3 p ){

    //Compute gradient.
    T vx = varEqn( T(p.x, 1.), T(p.y, 0.), T(p.z, 0.) );
    T vy = varEqn( T(p.x, 0.), T(p.y, 1.), T(p.z, 0.) );
    T vz = varEqn( T(p.x, 0.), T(p.y, 0.), T(p.z, 1.) );
    vec3 grad = vec3(vx.y,vy.y,vz.y);

    //the value of the function is automatically computed in each of the above:
    float val = vx.x;

    return vec4(grad,val);
}



//----------------------------------------------------------------------------------------------------
// Can also choose the bounding box
//----------------------------------------------------------------------------------------------------











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
float distR3( vec3 p, Variety var ){

    //normalize position
    vec3 pos = p - var.center;
    float rad = length(pos);
    vec3 scaledPos = var.size*pos;

    //get the distance estimate
    vec4 data = var_Data(scaledPos);
    float val = data.w;
    float gradLength = length(data.xyz)*var.size;
    float dist = DE(val, gradLength);

    //adjust to account for thickness of surface
    dist=abs(dist+var.inside)-var.inside-var.outside;


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
    //        dist = smax(dist,sphDist,var.smoothing);
    //




    // //bounding sphere
    float bboxDist = rad-var.boundingSphere;

    // //bounding cylinder
    //    float bboxDist = length(pos.xy)-var.boundingSphere;
    //    bboxDist = max(bboxDist, abs(pos.z)-4.5);

    //bounding box
    //vec3 q = abs(pos) - vec3(var.boundingSphere);
    //float bboxDist =  length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);

    //adjust for the bounding box
    dist = smax(dist,bboxDist,var.smoothing);


    return dist+0.001;
}



float distR3( Vector tv, Variety var ){

    float dist = distR3(tv.pos,var);

    //    //normalize position
    //    vec3 pos = tv.pos - var.center;
    //    float rad = length(pos);
    //    pos *= var.size;
    //
    //    //get the distance estimate
    //    vec4 data = var_Data(pos);
    //    float val = data.w;
    //    float gradLength = length(data.xyz)/var.size;
    //    float dist = DE(val, gradLength);
    //
    //    //adjust to account for thickness of surface
    //    dist=abs(dist+var.inside)-var.inside-var.outside;
    //    //adjust for the bounding box
    //    dist = smax(dist,rad-var.boundingSphere,var.smoothing);

    return dist;
}

//overload of location booleans:
bool at( Vector tv, Variety var){
    float d = distR3( tv.pos, var );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Variety var ){
    float d = distR3( tv.pos, var );
    return (d<0.);
}

//overload of sdf for a sphere
float sdf( Vector tv, Variety var ){
    //distance to closest point on sphere
    return distR3(tv.pos, var);
}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Variety var ){

    vec3 pos =tv.pos;
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;//this normalization makes exyy etc all unit vectors;

    float vxyy=distR3( pos + e.xyy*ep, var);
    float vyyx=distR3( pos + e.yyx*ep, var);
    float vyxy=distR3( pos + e.yxy*ep, var);
    float vxxx=distR3( pos + e.xxx*ep, var);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//setData for a single sided, volume material
void setData( inout Path path, Variety var ){

    //if we are at the surface
    if(at(path.tv, var)){

        //compute the normal
        Vector normal = normalVec(path.tv,var);
        Material mat = var.mat;

        bool side = inside(path.tv, var);
        setObjectInAir(path.dat, side, normal, mat);
    }
}

























