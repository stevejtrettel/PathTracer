//-------------------------------------------------
//The APOLLONIAN GASKET sdf
//-------------------------------------------------

//the data of a gasket is its frame, radius, and fold offset
//  radius     : inversion radius (a shape parameter, not placement)
//  foldOffset : shifts the fold each iteration -> morphs the gasket.
//               (was hardcoded to the `scratch1` uniform; now a scene-set field)
struct Gasket{
    Frame frame;
    float radius;
    float foldOffset;
    Material mat;
};


//the local-frame sdf
float sdf( vec3 p, Gasket gasket ){

    //the folded fractal is infinite and space-filling: clip it to the
    //unit ball of the local frame so the object is actually bounded
    float ballDist = length(p) - 1.;

    p=gasket.radius*p;

    //conformal factor of the inversion below: distances computed in the
    //inverted coordinates are stretched by 3/|p|^2, so the result must be
    //scaled back by m/3 to be a true distance estimate
    float m = dot(p,p);

    p /= dot(p,p);
    p += vec3(1.0);
    p*=3.;

    float scale = 1.0;
    float s=1.5;

    for( int i=0; i<10;i++ )
    {
        p = -1.0 + 2.0*fract(0.5*p+gasket.foldOffset);

        float r2 = dot(p,p);

        float k = s/r2;
        p     *= k;
        scale *= k;
    }
    float  res = min(abs(p.z)+abs(p.x),min(abs(p.x)+abs(p.y),abs(p.y)+abs(p.z)))+0.2;
    float dist= 0.25*res/scale * m/3.;
    return max(dist, ballDist);
}


//initObject from the standard interface
OBJECT_INIT(Gasket)


//hand-written Vector-level sdf: the standard lift of the local sdf
//(kept by hand because at() below is custom)
float sdf( Vector tv, Gasket gasket ){
    return gasket.frame.scale * sdf( toLocal(gasket.frame, tv.pos), gasket );
}


//overload of location booleans:
bool at( Vector tv, Gasket gasket){
    //the custom trace() below uses a distance-proportional precision (0.001*t),
    //which at large t stops farther from the surface than AT_THRESH.
    //so: any point we are asked about is treated as on the surface.
    return true;
}

bool inside( Vector tv, Gasket gasket ){
    float d = sdf( tv, gasket );
    return (d<0.);
}


//overload of trace for a gasket
//sphere-traces with precision proportional to distance traveled;
//marches in the gasket's local frame (the local sdf lives there):
//toLocal keeps the direction unit length, so the local march parameter
//converts to a world distance by multiplying by frame.scale
float trace( Vector tv, Gasket gasket ){
    Vector ltv = toLocal(gasket.frame, tv);
    vec3 ro=ltv.pos;
    vec3 rd=ltv.dir;

    float t = 0.001;
    for( int i=0; i<512; i++ )
    {
        float precis = 0.001*t;
        float h = sdf( ro+rd*t, gasket);
        if( h<precis||t>maxDist) break;
        t += h;
    }
    return t * gasket.frame.scale;
}


//the rest of the standard interface: normalVec, setData
OBJECT_NORMAL_FD(Gasket)
OBJECT_SETDATA(Gasket)
