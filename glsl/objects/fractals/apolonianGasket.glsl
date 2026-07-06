//-------------------------------------------------
//The APOLLONIAN GASKET sdf
//-------------------------------------------------

//the data of a gasket is its center and radius
struct Gasket{
    vec3 center;
    float radius;
    Material mat;
};


//the point-level sdf
//NOTE: the fractal's shape is coupled to the global uniform `extra`
//(the "extra" slider in the UI shifts the fold offset each iteration)
float sdf( vec3 p, Gasket gasket ){

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
    float d = sdf( tv.pos, gasket );
    return (d<0.);
}


//overload of sdf for a gasket
float sdf( Vector tv, Gasket gasket ){

    //distance to closest point on fractal
    return sdf(tv.pos, gasket);

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
        float h = sdf( ro+rd*t, gasket);
        if( h<precis||t>maxDist) break;
        t += h;
    }
    return t;
}


//the rest of the standard interface: normalVec, setData
UNFRAMED_NORMAL_FD(Gasket)
OBJECT_SETDATA(Gasket)
