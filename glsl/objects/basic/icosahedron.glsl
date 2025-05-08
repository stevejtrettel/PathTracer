

#define GDFVector3 normalize(vec3(1, 1, 1 ))
#define GDFVector4 normalize(vec3(-1, 1, 1))
#define GDFVector5 normalize(vec3(1, -1, 1))
#define GDFVector6 normalize(vec3(1, 1, -1))

#define GDFVector7 normalize(vec3(0, 1, PHI+1.))
#define GDFVector8 normalize(vec3(0, -1, PHI+1.))
#define GDFVector9 normalize(vec3(PHI+1., 0, 1))
#define GDFVector10 normalize(vec3(-PHI-1., 0, 1))
#define GDFVector11 normalize(vec3(1, PHI+1., 0))
#define GDFVector12 normalize(vec3(-1, PHI+1., 0))

#define GDFVector13 normalize(vec3(0, PHI, 1))
#define GDFVector14 normalize(vec3(0, -PHI, 1))
#define GDFVector15 normalize(vec3(1, 0, PHI))
#define GDFVector16 normalize(vec3(-1, 0, PHI))
#define GDFVector17 normalize(vec3(PHI, 1, 0))
#define GDFVector18 normalize(vec3(-PHI, 1, 0))

#define fGDFBegin float d = 0.;
#define fGDF(v) d = max(d, abs(dot(p, v)));
#define fGDFEnd return d - r;

float fIcosahedron(vec3 p, float r) {
    fGDFBegin
    fGDF(GDFVector3) fGDF(GDFVector4) fGDF(GDFVector5) fGDF(GDFVector6)
    fGDF(GDFVector7) fGDF(GDFVector8) fGDF(GDFVector9) fGDF(GDFVector10)
    fGDF(GDFVector11) fGDF(GDFVector12)
    fGDFEnd
}

float sdf_icosahedron(vec3 p) {
    const float scale = 0.7;
    p *= 1./scale;
    return fIcosahedron(p, 1.0) * scale;
}







//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Icosahedron{
    vec3 center;
    float size;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Icosahedron obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdf_dodecahedron(pos);
}











//-------------------------------------------------
//STUFF DERIVED FROM THIS
//-------------------------------------------------


//overload of location booleans:
bvec2 relPosition( Vector tv, Icosahedron obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv,Icosahedron obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Icosahedron obj ){
    float d = distR3( tv.pos, obj );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Icosahedron obj ){

    //distance to closest point on box
    float d=distR3(tv.pos, obj);
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, Icosahedron obj ){

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
void setData( inout Path path, Icosahedron obj){

    //if we are at the surface
    if(at(path.tv, obj)){
        //compute the normal
        Vector normal=normalVec(path.tv,obj);
        bool side = inside(path.tv, obj);
        //set the material
        setObjectInAir(path.dat, side, normal, obj.mat);
    }

}












