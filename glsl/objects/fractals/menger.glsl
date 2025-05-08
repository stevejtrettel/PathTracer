


float maxcomp(in vec3 p) { return max(p.x, max(p.y, p.z)); }


float sdBox(vec3 p, vec3 b)
{
    vec3  di = abs(p) - b;
    float mc = maxcomp(di);
    return min(mc, length(max(di, 0.0)));
}


float sdf_menger(in vec3 p)
{

    if(length(p)>2.){
        return length(p)-1.9;
    }

    float d = sdBox(p, vec3(1.0));

    float s = 1.0;
    for (int m = 0; m < 7; ++m)
    {
        vec3 a = mod(p * s, 2.0) - 1.0;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0 * abs(a));

        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        float c = (min(da, min(db, dc)) - 1.0) / s;

        d = max(d, c);
    }

    return d;
}










//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct MengerSponge{
    vec3 center;
    float size;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, MengerSponge obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdf_menger(pos);
}











//-------------------------------------------------
//STUFF DERIVED FROM THIS
//-------------------------------------------------


//overload of location booleans:
bvec2 relPosition( Vector tv, MengerSponge obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv,MengerSponge obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, MengerSponge obj ){
    float d = distR3( tv.pos, obj );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, MengerSponge obj ){

    //distance to closest point on box
    float d=distR3(tv.pos, obj);
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, MengerSponge obj ){

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
void setData( inout Path path, MengerSponge obj){

    //if we are at the surface
    if(at(path.tv, obj)){
        //compute the normal
        Vector normal=normalVec(path.tv,obj);
        bool side = inside(path.tv, obj);
        //set the material
        setObjectInAir(path.dat, side, normal, obj.mat);
    }

}












