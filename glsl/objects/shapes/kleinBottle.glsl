
//------------------------
// The Klein Bottle SDF
//------------------------



struct KleinBottle{
    vec3 center;
    float size;
    float thickness;
    Material mat;
};


float sdKlein(vec3 p, float thickness){

    //from https://www.shadertoy.com/view/4ltSW8

    float d = maxDist;

    p.y += .5;
    p.xy *= rot2(PI/2.);

    vec3  q = p + vec3(1.-cos((1.-p.y)/3.*PI),0,0);
    float y = pow(sin((1.-p.y)/3.*PI/2.),2.);

    // SIDE HANDLE (stretched XZ cylinder)
    float sideHandle_hollow = max(max(abs(length(q.xz)-0.5+0.25*y)-thickness,q.y-1.0),-q.y-2.0);
    //only if we are cutting a hole later
    //float sideHandle_solid  = max(max(length(q.xz)-0.5+0.25*y,q.y-1.0),-q.y-2.0);
    //union with the side handle
    d = min(d,sideHandle_hollow);

    // LOWER BASE: opening (half XZ torus)
    q = p - vec3(0,1,0);
    float lowerBase = max(abs(length(vec2(length(q.xz)-1.0,q.y))-0.5)-thickness,-q.y);
    d = min(d,lowerBase);

    // MID BASE: (stretched XZ torus)
    q = p;
    float midBase = max(max(abs(length(q.xz)-1.5+1.25*y),q.y-1.0),-q.y-2.0)-thickness;
    //newTube = max(newTube, -sideHandle_solid);//cut out a disk for the entry tube
    //union with the base
    d = min(d,midBase);

    // UPPER HANDLE (half XY torus)
    q = p + vec3(1,2,0);
    float upperHandle = abs(length(vec2(length(q.xy)-1.0,q.z))-0.25)-thickness;
    upperHandle = max(upperHandle,q.y);//cut it off at a fixed height
    //union with the upperhandle
    d = min(d,upperHandle);

    return 0.8*d;
}


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, KleinBottle klein ){
    //normalize position
    vec3 pos = p - klein.center;
    pos /= klein.size;
    pos = vec3(-pos.y,pos.z,pos.x);

    if(length(p)>6.){
        return length(p)-5.9;
    }

    return sdKlein(pos,klein.thickness);
}

//overload of location booleans:
bool at( Vector tv,KleinBottle klein){

    float d = distR3( tv.pos, klein );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, KleinBottle klein ){
    float d = distR3( tv.pos, klein );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, KleinBottle klein ){

    //distance to closest point on sphere
    float d=distR3(tv.pos, klein);
    //return the actual distance
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, KleinBottle klein ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, klein);
    float vyyx=distR3( pos + e.yyx*ep, klein);
    float vyxy=distR3( pos + e.yxy*ep, klein);
    float vxxx=distR3( pos + e.xxx*ep, klein);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//overload of setData for a sphere
void setData( inout Path path, KleinBottle klein){

    //if we are at the surface
    if(at(path.tv, klein)){
        //compute the normal
        Vector normal=normalVec(path.tv,klein);
        bool side = inside(path.tv, klein);
        //set the material
        setObjectInAir(path.dat, side, normal, klein.mat);
    }

}

