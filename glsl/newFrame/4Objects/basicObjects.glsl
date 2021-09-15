//-------------------------------------------------
// BASIC OBJECTS
// a basic object is built using a single signed distance function
// or some simple computation, and has one material
//-------------------------------------------------








//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Sphere sphere ){
    //normalize position
    vec3 pos = p - sphere.center;

    //distance to closest point on the sphere
    return length(pos) - sphere.radius;
}

//overload of location booleans:
bvec2 relPosition( Vector tv, Sphere sphere){

    float d = distR3( tv.pos, sphere );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv, Sphere sphere){

    float d = distR3( tv.pos, sphere );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Sphere sphere ){
    float d = distR3( tv.pos, sphere );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Sphere sphere ){

    //distance to closest point on sphere
    float d=distR3(tv.pos, sphere);

    //if you are looking away from the sphere, stop
    if(d>0.&&dot(tv.dir,tv.pos)>0.){return maxDist;}

    //otherwise return the actual distance
    return d;
}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Sphere sphere ){
    //position vector rel center
    vec3 dir = tv.pos-sphere.center;
    dir=normalize(dir);

    return Vector(tv.pos,dir);
}

//auxilary function for writing trace()
vec2 intersectRay_Sphere( Vector tv, Sphere sphere ){
    //return all intersections with the sphere along the line:
    vec3 p=tv.pos-sphere.center;
    vec3 v=tv.dir;

    float a=dot(v,v);
    float b=2.*dot(p,v);
    float c=(dot(p,p)-sphere.radius*sphere.radius)/a;

    float disc=b*b-4.*a*c;
    if(disc<0.){
        //intersections do not exist
        return 2.*vec2(maxDist,maxDist);
    }
    //else, return the two intersection points:
        float D=sqrt(abs(disc));
        return vec2(-b-D, -b+D)/(2.*a);

}


//overload of trace for a sphere
float trace( Vector tv, Sphere sphere ){

    vec2 intPt=intersectRay_Sphere(tv, sphere);

    if(intPt.y < 0. || intPt.x > maxDist){
        //the sphere is not in front of us
        return maxDist;
    }
    //otherwise, find the first intersection of the sphere:
    float dist=intPt.x < 0.  ?  intPt.y  :  intPt.x;
    return min(dist,maxDist);
}


//overload of setData for a sphere
void setData( inout Path path, Sphere sphere ){

    //if we are at the surface
    if(at(path.tv, sphere)){
        //compute the normal
        Vector normal=normalVec(path.tv,sphere);
        bool side = inside(path.tv, sphere);
        //set the material
        setObjectInAir(path.dat, side, normal, sphere.mat);
    }

}









float sdRoundBox( vec3 p, vec3 b, float r )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}





//-------------------------------------------------
//The BOX sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Box{
    vec3 center;
    vec3 sides;
    float rounded;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Box box ){
    //normalize position
    vec3 pos = p - box.center;

    vec3 q = abs(pos) - box.sides;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded;
}

//overload of location booleans:
bvec2 relPosition( Vector tv, Box box){

    float d = distR3( tv.pos, box );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

//overload of location booleans:
bool at( Vector tv,Box box){

    float d = distR3( tv.pos, box );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Box box ){
    float d = distR3( tv.pos, box );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Box box ){

    //distance to closest point on sphere
    float d=distR3(tv.pos, box);
    //return the actual distance
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, Box box ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, box);
    float vyyx=distR3( pos + e.yyx*ep, box);
    float vyxy=distR3( pos + e.yxy*ep, box);
    float vxxx=distR3( pos + e.xxx*ep, box);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//overload of setData for a sphere
void setData( inout Path path, Box box){

    //if we are at the surface
    if(at(path.tv, box)){
        //compute the normal
        Vector normal=normalVec(path.tv,box);
        bool side = inside(path.tv, box);
        //set the material
        setObjectInAir(path.dat, side, normal, box.mat);
    }

}























//-------------------------------------------------
//The PLANE sdf
//-------------------------------------------------

//the data of a plane is its normal and a constant:

struct Plane{
    //a plane is given by a position and the unit normal at that point:
    Vector orientation;
    Material mat;
};



//overload of distR3
float distR3( vec3 pos, Plane plane ){

    //get position relative to point on plane
    vec3 relPos = pos - plane.orientation.pos;

    //project onto the normal vector
    return dot( relPos, plane.orientation.dir );

}


//overload of location booleans:
bool at( Vector tv, Plane plane){

    float d = distR3( tv.pos, plane );
    return  (abs(d) < AT_THRESH);

}

bool inside( Vector tv, Plane plane ){
    float d = distR3( tv.pos, plane );
    return (d < 0.);
}



//overload of sdf
float sdf( Vector tv, Plane plane ){

    //if aimed away from plane:
    if(dot(tv.dir,plane.orientation.dir)>0.){return maxDist;}

    //otherwise give distance
    return distR3(tv.pos, plane);
}

//overload of normalVec
Vector normalVec( Vector tv,Plane plane ){
    //the normal is just the plane's normal vector
    return Vector(tv.pos, plane.orientation.dir);
}

//overload of trace
float trace( Vector tv, Plane plane ){

    float denom=dot(tv.dir,plane.orientation.dir);
    if(denom>0.){return maxDist;}

    //otherwise, aimed at plane
    return - distR3( tv.pos, plane) / denom;
}


//overload of setData for a sphere
void setData( inout Path path, Plane plane ){

    //if we are at the surface
    if(at(path.tv, plane)){
        //compute the normal
        Vector normal=normalVec(path.tv, plane);
        bool side = inside(path.tv, plane);
        //set the material
        setObjectInAir(path.dat, side, normal, plane.mat);
    }

}









//-------------------------------------------------
//The TRUNCATED CONE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Cone{
    vec3 center;
    float height;
    float base;
    //this is an extra parameter letting you extend the top
    float flare;
    Material mat;
};



//auxilary function (From IQ) which is the truncated cone:
float sdCappedCone( vec3 p, float h, float r1, float r2 )
{
    vec2 q = vec2( length(p.xz), p.y );
    vec2 k1 = vec2(r2,h);
    vec2 k2 = vec2(r2-r1,2.0*h);
    vec2 ca = vec2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
    vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot(k2,k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot(ca,ca),dot(cb,cb)) );
}


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Cone cone ){
    //normalize position
    vec3 pos = p - cone.center;
    return sdCappedCone(pos,cone.height,cone.base,cone.flare*cone.base);
}


//overload of location booleans:
bool at( Vector tv, Cone cone){

    float d = distR3( tv.pos, cone );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Cone cone ){
    float d = distR3( tv.pos, cone );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Cone cone ){

    //distance to closest point on sphere
   return distR3(tv.pos, cone);

}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Cone cone ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, cone);
    float vyyx=distR3( pos + e.yyx*ep, cone);
    float vyxy=distR3( pos + e.yxy*ep, cone);
    float vxxx=distR3( pos + e.xxx*ep, cone);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

//overload of setData for a sphere
void setData( inout Path path, Cone cone ){

    //if we are at the surface
    if(at(path.tv, cone)){
        //compute the normal
        Vector normal=normalVec(path.tv,cone);
        bool side = inside(path.tv, cone);
        //set the material
        setObjectInAir(path.dat, side, normal, cone.mat);
    }

}











//-------------------------------------------------
//The STANFORD BUNNY sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Bunny{
    vec3 center;
    float scale;
    Material mat;
};



//auxilary function from shadertoy, sdf to bunny
float sdBunny(vec3 p,float size) {
    p=p/(size);
    p=vec3(p.x,-p.z,p.y);

    //sdf is undefined outside the unit sphere, uncomment to witness the abominations
    if (length(p) > 1.) {
        return length(p)-.8;
    }
    //neural networks can be really compact... when they want to be
    vec4 f00=sin(p.y*vec4(-3.02,1.95,-3.42,-.60)+p.z*vec4(3.08,.85,-2.25,-.24)-p.x*vec4(-.29,1.16,-3.74,2.89)+vec4(-.71,4.50,-3.24,-3.50));

    vec4 f01=sin(p.y*vec4(-.40,-3.61,3.23,-.14)+p.z*vec4(-.36,3.64,-3.91,2.66)-p.x*vec4(2.90,-.54,-2.75,2.71)+vec4(7.02,-5.41,-1.12,-7.41));

    vec4 f02=sin(p.y*vec4(-1.77,-1.28,-4.29,-3.20)+p.z*vec4(-3.49,-2.81,-.64,2.79)-p.x*vec4(3.15,2.14,-3.85,1.83)+vec4(-2.07,4.49,5.33,-2.17));

    vec4 f03=sin(p.y*vec4(-.49,.68,3.05,.42)+p.z*vec4(-2.87,.78,3.78,-3.41)-p.x*vec4(-2.65,.33,.07,-.64)+vec4(-3.24,-5.90,1.14,-4.71));

    vec4 f10=sin(mat4(-.34,.06,-.59,-.76,.10,-.19,-.12,.44,.64,-.02,-.26,.15,-.16,.21,.91,.15)*f00+mat4(.01,.54,-.77,.11,.06,-.14,.43,.51,-.18,.08,.39,.20,.33,-.49,-.10,.19)*f01+mat4(.27,.22,.43,.53,.18,-.17,.23,-.64,-.14,.02,-.10,.16,-.13,-.06,-.04,-.36)*f02+mat4(-.13,.29,-.29,.08,1.13,.02,-.83,.32,-.32,.04,-.31,-.16,.14,-.03,-.20,.39)*f03+
    vec4(.73,-4.28,-1.56,-1.80))/1.0+f00;

    vec4 f11=sin(mat4(-1.11,.55,-.12,-1.00,.16,.15,-.30,.31,-.01,.01,.31,-.42,-.29,.38,-.04,.71)*f00+mat4(.96,-.02,.86,.52,-.14,.60,.44,.43,.02,-.15,-.49,-.05,-.06,-.25,-.03,-.22)*f01+mat4(.52,.44,-.05,-.11,-.56,-.10,-.61,-.40,-.04,.55,.32,-.07,-.02,.28,.26,-.49)*f02+mat4(.02,-.32,.06,-.17,-.59,.00,-.24,.60,-.06,.13,-.21,-.27,-.12,-.14,.58,-.55)*f03+vec4(-2.24,-3.48,-.80,1.41))/1.0+f01;

    vec4 f12=sin(mat4(.44,-.06,-.79,-.46,.05,-.60,.30,.36,.35,.12,.02,.12,.40,-.26,.63,-.21)*f00+mat4(-.48,.43,-.73,-.40,.11,-.01,.71,.05,-.25,.25,-.28,-.20,.32,-.02,-.84,.16)*f01+ mat4(.39,-.07,.90,.36,-.38,-.27,-1.86,-.39,.48,-.20,-.05,.10,-.00,-.21,.29,.63)*f02+mat4(.46,-.32,.06,.09,.72,-.47,.81,.78,.90,.02,-.21,.08,-.16,.22,.32,-.13)*f03+
    vec4(3.38,1.20,.84,1.41))/1.0+f02;

    vec4 f13=sin(mat4(-.41,-.24,-.71,-.25,-.24,-.75,-.09,.02,-.27,-.42,.02,.03,-.01,.51,-.12,-1.24)*f00+mat4(.64,.31,-1.36,.61,-.34,.11,.14,.79,.22,-.16,-.29,-.70,.02,-.37,.49,.39)*f01+mat4(.79,.47,.54,-.47,-1.13,-.35,-1.03,-.22,-.67,-.26,.10,.21,-.07,-.73,-.11,.72)*f02+mat4(.43,-.23,.13,.09,1.38,-.63,1.57,-.20,.39,-.14,.42,.13,-.57,-.08,-.21,.21)*f03+
    vec4(-.34,-3.28,.43,-.52))/1.0+f03;
    f00=sin(mat4(-.72,.23,-.89,.52,.38,.19,-.16,-.88,.26,-.37,.09,.63,.29,-.72,.30,-.95)*f10+mat4(-.22,-.51,-.42,-.73,-.32,.00,-1.03,1.17,-.20,-.03,-.13,-.16,-.41,.09,.36,-.84)*f11+mat4(-.21,.01,.33,.47,.05,.20,-.44,-1.04,.13,.12,-.13,.31,.01,-.34,.41,-.34)*f12+mat4(-.13,-.06,-.39,-.22,.48,.25,.24,-.97,-.34,.14,.42,-.00,-.44,.05,.09,-.95)*f13+
    vec4(.48,.87,-.87,-2.06))/1.4+f10;
    f01=sin(mat4(-.27,.29,-.21,.15,.34,-.23,.85,-.09,-1.15,-.24,-.05,-.25,-.12,-.73,-.17,-.37)*f10+mat4(-1.11,.35,-.93,-.06,-.79,-.03,-.46,-.37,.60,-.37,-.14,.45,-.03,-.21,.02,.59)*f11+mat4(-.92,-.17,-.58,-.18,.58,.60,.83,-1.04,-.80,-.16,.23,-.11,.08,.16,.76,.61)*f12+mat4(.29,.45,.30,.39,-.91,.66,-.35,-.35,.21,.16,-.54,-.63,1.10,-.38,.20,.15)*f13+
    vec4(-1.72,-.14,1.92,2.08))/1.4+f11;
    f02=sin(mat4(1.00,.66,1.30,-.51,.88,.25,-.67,.03,-.68,-.08,-.12,-.14,.46,1.15,.38,-.10)*f10+mat4(.51,-.57,.41,-.09,.68,-.50,-.04,-1.01,.20,.44,-.60,.46,-.09,-.37,-1.30,.04)*f11+mat4(.14,.29,-.45,-.06,-.65,.33,-.37,-.95,.71,-.07,1.00,-.60,-1.68,-.20,-.00,-.70)*f12+mat4(-.31,.69,.56,.13,.95,.36,.56,.59,-.63,.52,-.30,.17,1.23,.72,.95,.75)*f13+
    vec4(-.90,-3.26,-.44,-3.11))/1.4+f12;
    f03=sin(mat4(.51,-.98,-.28,.16,-.22,-.17,-1.03,.22,.70,-.15,.12,.43,.78,.67,-.85,-.25)*f10+mat4(.81,.60,-.89,.61,-1.03,-.33,.60,-.11,-.06,.01,-.02,-.44,.73,.69,1.02,.62)*f11+mat4(-.10,.52,.80,-.65,.40,-.75,.47,1.56,.03,.05,.08,.31,-.03,.22,-1.63,.07)*f12+mat4(-.18,-.07,-1.22,.48,-.01,.56,.07,.15,.24,.25,-.09,-.54,.23,-.08,.20,.36)*f13+
    vec4(-1.11,-4.28,1.02,-.23))/1.4+f13;

    float res =dot(f00,vec4(.09,.12,-.07,-.03))+dot(f01,vec4(-.04,.07,-.08,.05))+dot(f02,vec4(-.01,.06,-.02,.07))+dot(f03,vec4(-.05,.07,.03,.04))-0.16;

    return 0.6*size*res;
}


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Bunny bunny ){
    //normalize position
    vec3 pos = p - bunny.center;
    return sdBunny(pos,bunny.scale);
}


//overload of location booleans:
bool at( Vector tv, Bunny bunny){

    float d = distR3( tv.pos, bunny );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Bunny bunny ){
    float d = distR3( tv.pos, bunny );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Bunny bunny ){

    //distance to closest point on sphere
    return distR3(tv.pos, bunny);

}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Bunny bunny ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, bunny);
    float vyyx=distR3( pos + e.yyx*ep, bunny);
    float vyxy=distR3( pos + e.yxy*ep, bunny);
    float vxxx=distR3( pos + e.xxx*ep, bunny);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

//overload of setData for a sphere
void setData( inout Path path, Bunny bunny ){

    //if we are at the surface
    if(at(path.tv, bunny)){
        //compute the normal
        Vector normal=normalVec(path.tv,bunny);
        bool side = inside(path.tv, bunny);
        //set the material
        setObjectInAir(path.dat, side, normal, bunny.mat);
    }

}





//-------------------------------------------------
//The APOLLONIAN GASKET sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Gasket{
    vec3 center;
    float radius;
    Material mat;
};


//auxillary function for calculating this
float apollonian(vec3 p)
{
    float K=0.4;
    float scale = 1.0;
    vec4 orb = vec4(1000.0);

    for( int i=0; i < 10;  i++ )
    {
        p = -1.0 + 2.0*fract(0.5*p+0.5);
        float r2 = dot(p,p);
        orb = min( orb, vec4(abs(p),r2) );
        float k = (1.0 + K)/r2;
        p *= k;
        scale *= k;
    }

    //this adds in balls insteaad
     float res = abs(p.y);
//
//    float  res = min(abs(p.z)+abs(p.x),
//    min(abs(p.x)+abs(p.y),
//    abs(p.y)+abs(p.z)));

    return 0.25/scale*res;
}



//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Gasket gasket ){

    p-=gasket.center;
    p=gasket.radius*p;

    float scale = 6.0;
    vec3 q=p;
    p /= scale;
    float s = 1.0;
//    if (doInversion) {
        s = dot(p,p);
        p /= s;
        p += vec3(1.0);
//    }
    //if (doTranslate) p.y += 0.1*iTime;
    float d0=apollonian(p)*scale;
    float d = d0;
    return d*s;
}



//overload of location booleans:
bool at( Vector tv, Gasket gasket){

    float d = distR3( tv.pos, gasket );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Gasket gasket ){
    return false;
    float d = distR3( tv.pos, gasket );
    return (d<0.);
}




//overload of sdf for a gasket
float sdf( Vector tv, Gasket gasket ){

    //distance to closest point on fractal
    return distR3(tv.pos, gasket);

}

//overload of normalVec for a sphere
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
float trace( Vector tv, Gasket gasket ){

    vec3 ro=tv.pos;
    vec3 rd=tv.dir;
    float pixel_size = 1.0/(iResolution.y * 2.0);
    float t = 1.0;

    for( int i=0; i<2048; i++ )
    {
        float c = distR3(ro + rd*t,gasket);
        if( c<0.5*pixel_size*t ) break;
        t += c;
        if( t>100.0 ) return maxDist;
    }
    return t;

}



//overload of setData for a sphere
void setData( inout Path path, Gasket gasket){

    //if we are at the surface
    //if(at(path.tv, gasket)){
        //compute the normal
        Vector normal=normalVec(path.tv,gasket);
        bool side = inside(path.tv, gasket);
        //set the material
        setObjectInAir(path.dat, side, normal, gasket.mat);
   // }

}

