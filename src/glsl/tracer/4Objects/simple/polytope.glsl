


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








//-------------------------------------------------
//The Hyperbolic Dodecahedron sdf
//-------------------------------------------------

//the data of a hyperbolic dodecahedron is:
// 1) a hyperbolic radius from center to face midpoint (these are d and r)
// this is converted into a distance in the ball model, and then the 12 spheres
// describing its faces are computed
//RIGHT NOW JUST GIVING D AND R DIRECTLY: NEED TO CHANGE THIS!

struct HypDod{
    float d;
    float r;
    Material mat;
};

HypDod buildHypDod(){
    HypDod dod;
    float Phi = (1.+sqrt(5.))/2.;
    float c = 2./Phi;

    dod.r = sqrt(c);
    dod.d = sqrt(c+1.);

    return dod;
}

//signed distance in R3 coordinates
float distR3( vec3 pos, HypDod dod ){

    //start with the distance to the unit sphere
    float dist = length(pos)-1.;

    //for each sphere, find the SDF for the outside
    //then, intersect them.
    float r = dod.r;
    float d = dod.d;

    //these are the unit directions
    vec3 v1 = normalize(vec3(0.,1.,1.618));
    vec3 v2 = normalize(vec3(1.618,0.,1.));
    vec3 v3 = normalize(vec3(1.,1.618,0.));
    vec3 v4 = normalize(vec3(0.,-1.,1.618));
    vec3 v5 = normalize(vec3(1.618,0.,-1.));
    vec3 v6 = normalize(vec3(-1.,1.618,0.));
    //and their negatives
    vec3 v7 = normalize(-vec3(0.,1.,1.618));
    vec3 v8 = normalize(-vec3(1.618,0.,1.));
    vec3 v9 = normalize(-vec3(1.,1.618,0.));
    vec3 v10 = normalize(-vec3(0.,-1.,1.618));
    vec3 v11 = normalize(-vec3(1.618,0.,-1.));
    vec3 v12 = normalize(-vec3(-1.,1.618,0.));

    float dist1 = length(pos - dod.d*v1)-dod.r;
    dist = max(dist, -dist1);

    float dist2 = length(pos - dod.d*v2)-dod.r;
    dist = max(dist, -dist2);

    float dist3 = length(pos - dod.d*v3)-dod.r;
    dist = max(dist, -dist3);

    float dist4 = length(pos - dod.d*v4)-dod.r;
    dist = max(dist, -dist4);

    float dist5 = length(pos - dod.d*v5)-dod.r;
    dist = max(dist, -dist5);

    float dist6 = length(pos - dod.d*v6)-dod.r;
    dist = max(dist, -dist6);

    float dist7 = length(pos - dod.d*v7)-dod.r;
    dist = max(dist, -dist7);

    float dist8 = length(pos - dod.d*v8)-dod.r;
    dist = max(dist, -dist8);

    float dist9 = length(pos - dod.d*v9)-dod.r;
    dist = max(dist, -dist9);

    float dist10 = length(pos - dod.d*v10)-dod.r;
    dist = max(dist, -dist10);

    float dist11 = length(pos - dod.d*v11)-dod.r;
    dist = max(dist, -dist11);

    float dist12 = length(pos - dod.d*v12)-dod.r;
    dist = max(dist, -dist12);

    return dist;
}


//location booleans
bool at( Vector tv, HypDod dod){
    float d = distR3( tv.pos, dod );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}


bool inside( Vector tv, HypDod dod ){
    float d = distR3( tv.pos, dod );
    return (d<0.);
}

//overload of sdf for a polytope
float sdf( Vector tv, HypDod dod ){
    return distR3(tv.pos, dod);
}

////overload of normalVec for a sphere
Vector normalVec( Vector tv, HypDod dod ){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    vec3 pos = tv.pos;

    float vxyy=distR3( pos + e.xyy*ep, dod);
    float vyyx=distR3( pos + e.yyx*ep, dod);
    float vyxy=distR3( pos + e.yxy*ep, dod);
    float vxxx=distR3( pos + e.xxx*ep, dod);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);
}


//overload of setData for a torus
void setData( inout Path path, HypDod dod ){

    //if we are at the surface
    if(at(path.tv, dod)){
        //compute the normal
        Vector normal=normalVec(path.tv, dod);
        bool side = inside(path.tv, dod);
        //set the material
        setObjectInAir(path.dat, side, normal, dod.mat);
    }
}
