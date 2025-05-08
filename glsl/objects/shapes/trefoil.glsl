


mat3 RotMat(vec3 axis, float angle)
{
    // http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(oc*axis.x*axis.x+c,         oc*axis.x*axis.y-axis.z*s,  oc*axis.z*axis.x+axis.y*s,
    oc*axis.x*axis.y+axis.z*s,  oc*axis.y*axis.y+c,         oc*axis.y*axis.z-axis.x*s,
    oc*axis.z*axis.x-axis.y*s,  oc*axis.y*axis.z+axis.x*s,  oc*axis.z*axis.z+c);
}

float dstFar = 100.;

float trefoil_PrBox2Df (vec2 p, vec2 b)
{
    vec2 d;
    d = abs (p) - b;
    return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

vec2 trefoil_Rot2D (vec2 q, float a)
{
    return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

float trefoil_ObjDf (vec3 p, float r)
{
    vec3 q;
    float dMin, d, a;
    dMin = dstFar;
    q = p;
    a = atan (q.z, q.x);
    q.xz = vec2 (length (q.xz) - r, q.y);
    q.xz = trefoil_Rot2D (q.xz, 1.5 * a);
    q.xz = trefoil_Rot2D (q.xz, - PI * (floor (atan (q.z, q.x) / PI + 0.5)));
    q.x -= 1.;
    //q.y = a - aa;
    d = length (trefoil_PrBox2Df (q.xz, vec2 (0.2))) - 0.05;
    if (d < dMin) { dMin = d; }
    return 0.4 * dMin;
}

float sdf_trefoil(vec3 p)
{
    if(length(p)>2.){
        return length(p)-1.9;
    }

    p *= RotMat(vec3(1.,0.,0.), PI/2.);
    const float scale = 0.18;
    p *= 1. / scale;
    return trefoil_ObjDf(p, 2.5) * scale;
}


//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Trefoil{
    vec3 center;
    float size;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Trefoil obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdf_trefoil(pos);
}











//-------------------------------------------------
//STUFF DERIVED FROM THIS
//-------------------------------------------------


//overload of location booleans:
bvec2 relPosition( Vector tv, Trefoil obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv,Trefoil obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Trefoil obj ){
    float d = distR3( tv.pos, obj );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Trefoil obj ){

    //distance to closest point on box
    float d=distR3(tv.pos, obj);
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, Trefoil obj ){

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
void setData( inout Path path, Trefoil obj){

    //if we are at the surface
    if(at(path.tv, obj)){
        //compute the normal
        Vector normal=normalVec(path.tv,obj);
        bool side = inside(path.tv, obj);
        //set the material
        setObjectInAir(path.dat, side, normal, obj.mat);
    }

}












