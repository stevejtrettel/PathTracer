//-------------------------------------------------
//The APOLLONIAN GASKET sdf
//-------------------------------------------------

//the data of a gasket is its center and radius
struct Gasket{
    vec3 center;
    float radius;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
//NOTE: the fractal's shape is coupled to the global uniform `extra`
//(the "extra" slider in the UI shifts the fold offset each iteration)
float distR3( vec3 p, Gasket gasket ){

    p-=gasket.center;
    p=gasket.radius*p;

    p /= dot(p,p);
    p += vec3(1.0);
    p*=3.;

    float scale = 1.0;
    float s=1.5;

    for( int i=0; i<10;i++ )
    {
        p = -1.0 + 2.0*fract(0.5*p+extra);

        float r2 = dot(p,p);

        float k = s/r2;
        p     *= k;
        scale *= k;
    }
    float  res = min(abs(p.z)+abs(p.x),min(abs(p.x)+abs(p.y),abs(p.y)+abs(p.z)))+0.2;
    float dist= 0.25*res/scale;
    return dist;
}


//overload of location booleans:
bool at( Vector tv, Gasket gasket){
    //the custom trace() below uses a distance-proportional precision (0.001*t),
    //which at large t stops farther from the surface than AT_THRESH.
    //so: any point we are asked about is treated as on the surface.
    return true;
}

bool inside( Vector tv, Gasket gasket ){
    float d = distR3( tv.pos, gasket );
    return (d<0.);
}


//overload of sdf for a gasket
float sdf( Vector tv, Gasket gasket ){

    //distance to closest point on fractal
    return distR3(tv.pos, gasket);

}

//overload of normalVec for a gasket
Vector normalVec( Vector tv, Gasket gasket ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, gasket);
    float vyyx=distR3( pos + e.yyx*ep, gasket);
    float vyxy=distR3( pos + e.yxy*ep, gasket);
    float vxxx=distR3( pos + e.xxx*ep, gasket);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}


//overload of trace for a gasket
//sphere-traces with precision proportional to distance traveled
float trace( Vector tv, Gasket gasket ){
    vec3 ro=tv.pos;
    vec3 rd=tv.dir;

    float t = 0.001;
    for( int i=0; i<512; i++ )
    {
        float precis = 0.001*t;
        float h = distR3( ro+rd*t, gasket);
        if( h<precis||t>maxDist) break;
        t += h;
    }
    return t;
}


//overload of setData for a gasket
void setData( inout Path path, Gasket gasket){

    //if we are at the surface
    if(at(path.tv, gasket)){
        //compute the normal
        Vector normal=normalVec(path.tv,gasket);
        bool side = inside(path.tv, gasket);
        //set the material
        setObjectInAir(path.dat, side, normal, gasket.mat);
    }
}
