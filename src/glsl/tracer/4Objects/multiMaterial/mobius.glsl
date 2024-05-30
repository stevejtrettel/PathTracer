
//-------------------------------------------------
// The MOBIUS SDF
//-------------------------------------------------

struct Mobius{
    vec3 center;
    float radius;
    float width;
    float thickness;
    float twists;
    bool offset;//is it the regular, or the offset one?
    Material bandMat;
    Material borderMat;
};



// IQ's box routine.
float sBoxS(in vec2 p, in vec2 b, float r){
    vec2 d = abs(p) - b + r;
    return min(max(d.x, d.y), 0.) + length(max(d, 0.)) - r;
}


vec2 sdMobius(vec3 rP, float radius, float width, float thickness, float twists, bool offset){

    // Toroidal strip dimensions.
    vec2 dim = vec2(width, thickness);
    float r = radius; // Toroidal radius.

    // Disc coordinates.
    vec3 q = rP;
    vec2 tc = vec2(length(q.xz) - r, rP.y);

    //num of holes
    float aN = 25.;

    // Disc holes.
    vec3 q2 = rP;
    if(offset){q2.xz *= rot2(3.14159/aN);}
    float a = mod(atan(q2.z, q2.x), 6.2831);
    float na = (floor(a*aN/6.2831) + .5)/aN;

    // Rotate the repeat cells into position and move them out by the radius.
    q2.xz *= rot2(-na*6.2831);
    q2.x -= r;

    q2.xy *= rot2(a*twists/2.); // Twisting the toroidal plane objects.
    // Producing the holes.

    vec2 holeInput = offset ? q2.yz : q2.xz;//choose original or offset
    float hole = sBoxS(holeInput, vec2(1, 1)*r*6.2831/aN/2.*.65, .05); // square holes
    //float hole = length(holeInput) - r*6.2831/aN/2.*.7; // X-axis holes.

    tc *= rot2(a*twists/2.); // Twisting the toroidal plane itself.
    float taperInput = offset ? tc.y : tc.x;//choose original or offset
    float taper = smoothstep(0., 1., abs(taperInput)/dim.x)*.5 + .5; // Holowing out the center.
    vec2 torInput = offset ? dim.yx : dim;
    float tor = sBoxS(tc, torInput*vec2(1, taper), .01); // Creating the central strip.
    tor = smax(tor, -hole, .01); // Boring out the wholes.

    // Outer band coordinates.
    if(offset){tc.y = abs(tc.y) - dim.x - dim.y;}
    else{tc.x = abs(tc.x) - dim.x - dim.y;}
    vec2 bandsInput = offset ? vec2(1.5,1) : vec2(1,1.5);
    float bands = sBoxS(tc, bandsInput*dim.y, .01);
    // Band ridges... Interesting, but not for this example.
    //bands += smoothstep(0., 1., sin(a*aN*6.))*.001;

    return vec2(tor, bands);
}




float distR3Band(vec3 p, Mobius mobius){
    vec3 pos = p-mobius.center;
    pos/=2.;
    vec2 dat = sdMobius(pos, mobius.radius, mobius.width, mobius.thickness, mobius.twists,mobius.offset);
    return dat.x;
}

float distR3Border(vec3 p, Mobius mobius){
    vec3 pos = p-mobius.center;
    pos/=2.;
    vec2 dat = sdMobius(pos, mobius.radius, mobius.width, mobius.thickness, mobius.twists,mobius.offset);
    return dat.y;
}

//overload of sdf
float sdf( Vector tv, Mobius mobius){
    vec3 pos = tv.pos-mobius.center;
    pos/=2.;
    vec2 dat = sdMobius(pos, mobius.radius, mobius.width, mobius.thickness,  mobius.twists,mobius.offset);
    //make the total distance:
    float dist = min( dat.x, dat.y );
    return dist;
}








//overload of location booleans:
bool atBand( Vector tv,Mobius mobius){
    float d = distR3Band( tv.pos, mobius );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool atBorder( Vector tv,Mobius mobius){
    float d = distR3Border( tv.pos, mobius );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool at( Vector tv,Mobius mobius){
    return atBand(tv,mobius)||atBorder(tv,mobius);
}




bool insideBand( Vector tv, Mobius mobius ){
    float d = distR3Band( tv.pos, mobius );
    return (d<0.);
}
bool insideBorder( Vector tv, Mobius mobius ){
    float d = distR3Border( tv.pos, mobius );
    return (d<0.);
}

bool inside( Vector tv, Mobius mobius ){
    return insideBand(tv,mobius)||insideBorder(tv,mobius);
}



Vector normalVecBand( Vector tv, Mobius mobius ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3Band( pos + e.xyy*ep, mobius);
    float vyyx=distR3Band( pos + e.yyx*ep, mobius);
    float vyxy=distR3Band( pos + e.yxy*ep, mobius);
    float vxxx=distR3Band( pos + e.xxx*ep, mobius);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}


Vector normalVecBorder( Vector tv, Mobius mobius ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3Border( pos + e.xyy*ep, mobius);
    float vyyx=distR3Border( pos + e.yyx*ep, mobius);
    float vyxy=distR3Border( pos + e.yxy*ep, mobius);
    float vxxx=distR3Border( pos + e.xxx*ep, mobius);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//overload of setData
void setData( inout Path path, Mobius mobius){

    //if we are at the surface of the band
    if(atBand(path.tv, mobius)){
        //compute the normal
        Vector normal=normalVecBand(path.tv,mobius);
        bool side = insideBand(path.tv, mobius);
        //set the material
        setObjectInAir(path.dat, side, normal, mobius.bandMat);
    }


    //if we are at the surface of the border
    if(atBorder(path.tv, mobius)){
        //compute the normal
        Vector normal=normalVecBorder(path.tv,mobius);
        bool side = insideBorder(path.tv, mobius);
        //set the material
        setObjectInAir(path.dat, side, normal, mobius.borderMat);
    }


    //PROBABLY NEED TO DO A BETTER JOB HERE AND DEAL WITH THE SEPARATE

}

