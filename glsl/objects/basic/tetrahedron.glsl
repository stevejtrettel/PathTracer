

float sdf_tetrahedron(vec3 p) {
    p *= 0.5;
    return max(
    // Vertical bound
    abs(p.y) - 0.5,

    // Horizontal bound
    max(abs(p.x) * 0.866025 + p.z * 0.5, -p.z) - 0.25 * abs(0.5 - p.y)
    ) * 2.0;
}











//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Tetrahedron{
    vec3 center;
    float size;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Tetrahedron obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdf_tetrahedron(pos);
}











//-------------------------------------------------
//STUFF DERIVED FROM THIS
//-------------------------------------------------


//overload of location booleans:
bvec2 relPosition( Vector tv, Tetrahedron obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv,Tetrahedron obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Tetrahedron obj ){
    float d = distR3( tv.pos, obj );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Tetrahedron obj ){

    //distance to closest point on box
    float d=distR3(tv.pos, obj);
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, Tetrahedron obj ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, obj);
    float vyyx=distR3( pos + e.yyx*ep, obj);
    float vyxy=distR3( pos + e.yxy*ep, obj);
    float vxxx=distR3( pos + e.xxx*ep, obj);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//overload of setData for a sphere
void setData( inout Path path, Tetrahedron obj){

    //if we are at the surface
    if(at(path.tv, obj)){
        //compute the normal
        Vector normal=normalVec(path.tv,obj);
        bool side = inside(path.tv, obj);
        //set the material
        setObjectInAir(path.dat, side, normal, obj.mat);
    }

}












