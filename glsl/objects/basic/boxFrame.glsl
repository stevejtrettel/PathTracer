

float sdBoxFrame( vec3 p, vec3 b, float e )
{
    p = abs(p  )-b;
    vec3 q = abs(p+e)-e;

    return min(min(
    length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
    length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
    length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}







//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct BoxFrame{
    vec3 center;
    vec3 sides;
    float edge;
    float size;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, BoxFrame obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdBoxFrame(pos,obj.sides,obj.edge);
}











//-------------------------------------------------
//STUFF DERIVED FROM THIS
//-------------------------------------------------


//overload of location booleans:
bvec2 relPosition( Vector tv, BoxFrame obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv,BoxFrame obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, BoxFrame obj ){
    float d = distR3( tv.pos, obj );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, BoxFrame obj ){

    //distance to closest point on box
    float d=distR3(tv.pos, obj);
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, BoxFrame obj ){

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
void setData( inout Path path, BoxFrame obj){

    //if we are at the surface
    if(at(path.tv, obj)){
        //compute the normal
        Vector normal=normalVec(path.tv,obj);
        bool side = inside(path.tv, obj);
        //set the material
        setObjectInAir(path.dat, side, normal, obj.mat);
    }

}












