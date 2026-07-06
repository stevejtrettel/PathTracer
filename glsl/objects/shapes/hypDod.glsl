

//-------------------------------------------------
//The Hyperbolic Dodecahedron sdf
//-------------------------------------------------

//the data of a hyperbolic dodecahedron is:
// 1) a hyperbolic radius from center to face midpoint (these are d and r)
// 2) a size of sphere to delete from the center
// this is converted into a distance in the ball model, and then the 12 spheres
// describing its faces are computed
//RIGHT NOW JUST GIVING D AND R DIRECTLY: NEED TO CHANGE THIS!

struct HypDod{
    Frame frame;
    float d;
    float r;
    bool centerSphere;
    float rCent;
    Material mat;
};

HypDod buildHypDod(){
    HypDod dod;
    float Phi = (1.+sqrt(5.))/2.;
    float c = 2./Phi;

    dod.frame = IDENTITY_FRAME;
    dod.r = sqrt(c);
    dod.d = sqrt(c+1.);
    dod.centerSphere=false;

    return dod;
}

HypDod buildHypDod( float rCent){
    HypDod dod;
    float Phi = (1.+sqrt(5.))/2.;
    float c = 2./Phi;

    dod.frame = IDENTITY_FRAME;
    dod.r = sqrt(c);
    dod.d = sqrt(c+1.);
    dod.centerSphere=true;
    dod.rCent = rCent;

    return dod;
}


//the local-frame sdf
float sdf( vec3 pos, HypDod dod ){

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

    //cut out the inside sphere
    if(dod.centerSphere){
        dist = smax(dist, dod.rCent-length(pos),0.1);
    }

    return dist;
}


//the standard interface: initObject, at, inside, sdf, normalVec, setData
OBJECT_API(HypDod)
