
//-------------------------------------------------
//The Hyperbolic Coxeter Cube sdf
//-------------------------------------------------

//the data of a hyperbolic coxeter cube is:
// 1) a dihedral angle (number of cubes fiting around a vertex)
// 2) a size of sphere to delete from the center
// this is converted into a distance in the ball model, for the center of spheres and then the radius of the 6 spheres
// describing its faces are computed
//RIGHT NOW JUST GIVING D AND R DIRECTLY: NEED TO CHANGE THIS!

struct HypCoxCube{
    float d;
    float r;
    bool centerSphere;
    float rCent;
    Material mat;
};

HypCoxCube buildCoxCube(float dihedral ){
    HypCoxCube cube;

    //half the dihedral angle theta
    float theta2 = 3.14159/(dihedral);
    //I THINK IT SHOULD BE THIS?!
    //float theta2 = 3.14159/dihedral;

    float denom = 2.*sin(theta2)*sin(theta2);
    cube.d = 1./sqrt(1.-1./denom);
    cube.r = sqrt(cube.d*cube.d - 1.);

    cube.centerSphere=false;

    return cube;
}

HypCoxCube buildCoxCube( float dihedral, float rCent){
    HypCoxCube cube;

    //half the dihedral angle theta
    float theta2 = 3.14159/dihedral;

    float denom = 2.*sin(theta2)*sin(theta2);
    cube.d = 1./sqrt(1.-1./denom);
    cube.r = sqrt(cube.d*cube.d -1.);

    cube.centerSphere=true;
    cube.rCent = rCent;

    return cube;
}


//signed distance in R3 coordinates
float distR3( vec3 pos, HypCoxCube cube ){

    //start with the distance to the unit sphere
    float dist = length(pos)-1.;

    //for each sphere, find the SDF for the outside
    //then, intersect them.
    float r = cube.r;
    float d = cube.d;

    //these are the unit directions
    vec3 v1 = vec3(1,0,0);
    vec3 v2 = vec3(0,1,0);
    vec3 v3 = vec3(0,0,1);
    vec3 v4 = vec3(-1,0,0);
    vec3 v5 = vec3(0,-1,0);
    vec3 v6 = vec3(0,0,-1);


    float dist1 = length(pos - cube.d*v1)-cube.r;
    dist = max(dist, -dist1);

    float dist2 = length(pos - cube.d*v2)-cube.r;
    dist = max(dist, -dist2);

    float dist3 = length(pos - cube.d*v3)-cube.r;
    dist = max(dist, -dist3);

    float dist4 = length(pos - cube.d*v4)-cube.r;
    dist = max(dist, -dist4);

    float dist5 = length(pos - cube.d*v5)-cube.r;
    dist = max(dist, -dist5);

    float dist6 = length(pos - cube.d*v6)-cube.r;
    dist = max(dist, -dist6);

    //cut out the inside sphere
    if(cube.centerSphere){
        dist = max(dist, cube.rCent-length(pos));
    }

    return dist;
}


//location booleans
bool at( Vector tv, HypCoxCube cube){
    float d = distR3( tv.pos, cube );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}


bool inside( Vector tv, HypCoxCube cube ){
    float d = distR3( tv.pos, cube );
    return (d<0.);
}

//overload of sdf for a polytope
float sdf( Vector tv, HypCoxCube cube ){
    return distR3(tv.pos, cube);
}

////overload of normalVec for a sphere
Vector normalVec( Vector tv, HypCoxCube cube ){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    vec3 pos = tv.pos;

    float vxyy=distR3( pos + e.xyy*ep, cube);
    float vyyx=distR3( pos + e.yyx*ep, cube);
    float vyxy=distR3( pos + e.yxy*ep, cube);
    float vxxx=distR3( pos + e.xxx*ep, cube);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);
}


//overload of setData for a torus
void setData( inout Path path, HypCoxCube cube ){

    //if we are at the surface
    if(at(path.tv, cube)){
        //compute the normal
        Vector normal=normalVec(path.tv, cube);
        bool side = inside(path.tv, cube);
        //set the material
        setObjectInAir(path.dat, side, normal, cube.mat);
    }
}




