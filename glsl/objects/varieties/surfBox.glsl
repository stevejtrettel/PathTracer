
//----------------------------------------------------------------------------------------------
// ADJUSTABLE VARIETY:
// ALL THAT NEEDS TO BE CHANGED IS THE FUNCTION SURF: THE REST AUTOMATICALLY UPDATES FROM THIS
//----------------------------------------------------------------------------------------------------


vec4 surfBox_Data( vec3 p ){

    //Compute gradient.
    T vx = surfBox_Eqn( T(p.x, 1.), T(p.y, 0.), T(p.z, 0.) );
    T vy = surfBox_Eqn( T(p.x, 0.), T(p.y, 1.), T(p.z, 0.) );
    T vz = surfBox_Eqn( T(p.x, 0.), T(p.y, 0.), T(p.z, 1.) );
    vec3 grad = vec3(vx.y,vy.y,vz.y);

    //the value of the function is automatically computed in each of the above:
    float val = vx.x;

    return vec4(grad,val);
}



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



//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, SurfBox surf ){

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


//overload of distR3 and sdf
float distR3( Vector tv, SurfBox surf ){
    float dist = distR3(tv.pos,surf);
    return dist;
}

float sdf( Vector tv, SurfBox surf ){
    return distR3(tv.pos, surf);
}


//overload of location booleans:
bool at( Vector tv, SurfBox surf){
    float d = distR3( tv.pos, surf );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, SurfBox surf ){
    float d = distR3( tv.pos, surf );
    return (d<0.);
}


Vector normalVec( Vector tv, SurfBox surf ){

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



