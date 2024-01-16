


//-------------------------------------------------
//The POLYTOPE sdf
//-------------------------------------------------

//the data of a polytope is:
// 1) a list of half spaces
// a half space ax+by+cz < d is encoded by a vec4 (a,b,c,d)

struct Polytope{
    vec4[8] hs;
    vec4 hs1;
    vec4 hs2;
    vec4 hs3;
    vec4 hs4;
    vec4 hs5;
    vec4 hs6;
    vec4 hs7;
    vec4 hs8;

    Material mat;
};

//the distance of pos to the half space ax+by+cz+d<0;
float sdHalfSpace(vec3 pos, vec4 halfSpace){
    vec3 normal = halfSpace.xyz;
    float num = dot(normal,pos)-halfSpace.w;
    float denom = length(normal);
    return num/denom;
}


//signed distance in R3 coordinates
float distR3( vec3 pos, Polytope poly ){
    float dist=-1000.;
    dist = max(dist, sdHalfSpace(pos, poly.hs1));
    dist = max(dist, sdHalfSpace(pos, poly.hs2));
    dist = max(dist, sdHalfSpace(pos, poly.hs3));
    dist = max(dist, sdHalfSpace(pos, poly.hs4));
    dist = max(dist, sdHalfSpace(pos, poly.hs5));
    dist = max(dist, sdHalfSpace(pos, poly.hs6));
    dist = max(dist, sdHalfSpace(pos, poly.hs7));
    dist = max(dist, sdHalfSpace(pos, poly.hs8));
    return dist;
}


//location booleans
bool at( Vector tv, Polytope poly){
    float d = distR3( tv.pos, poly );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}
bool inside( Vector tv, Polytope poly ){
    float d = distR3( tv.pos, poly );
    return (d<0.);
}


//overload of sdf for a polytope
float sdf( Vector tv, Polytope poly ){
    return distR3(tv.pos, poly);
}

////overload of normalVec for a torus
//Vector normalVec( Vector tv, Polytope poly ){
//
//    float dist = 1000.;
//    int index = 0;
//    float newDist;
//    //iterate through the half spaces:
//    for(int i=0; i<poly.numFaces; i++){
//        newDist = sdHalfSpace(tv.pos, poly.halfSpaces[i]);
//        if(newDist<dist){
//            index = i;
//        }
//        dist = min(dist, newDist);
//    }
//    //now we have the right index:
//    vec3 dir = poly.halfSpaces[index].xyz;
//    return Vector(tv.pos,dir);
//}

////overload of normalVec for a sphere
Vector normalVec( Vector tv, Polytope poly ){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    vec3 pos = tv.pos;

    float vxyy=distR3( pos + e.xyy*ep, poly);
    float vyyx=distR3( pos + e.yyx*ep, poly);
    float vyxy=distR3( pos + e.yxy*ep, poly);
    float vxxx=distR3( pos + e.xxx*ep, poly);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);
}


//overload of setData for a torus
void setData( inout Path path, Polytope poly ){

    //if we are at the surface
    if(at(path.tv, poly)){
        //compute the normal
        Vector normal=normalVec(path.tv, poly);
        bool side = inside(path.tv, poly);
        //set the material
        setObjectInAir(path.dat, side, normal, poly.mat);
    }
}
