//-------------------------------------------------
//-------------------------------------------------
//==========TEMPLATES 
//===========FOR THESE
//=======TYPES OF FUNCTIONS
//-------------------------------------------------
//-------------------------------------------------



//for a 3d object
float objDistance(vec3 pos){
    //just calculate the distance
    return 3.;
}



//hopefully in most cases will find an analytic formula for the normal vector.  But if not, this is a default version

Vector objGradient(vec3 pos){
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    float vxyy=objDistance( pos + e.xyy*ep);
    float vyyx=objDistance( pos + e.yyx*ep);
    float vyxy=objDistance( pos + e.yxy*ep);
    float vxxx=objDistance( pos + e.xxx*ep);
    
    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
    
    dir=normalize(dir);
    
    return Vector(Point(pos),dir);
    
}



//-------------------------------------------------
//  Rotating 2D Objects
//-------------------------------------------------


float objDistance2D(vec2 p){
    return 3.;
}

vec2 objNormal2D(vec2 p){
    return vec2(1.,0.);
}


float objDistanceRot(vec3 p){
    float r=length(p.xz);
    vec2 v=vec2(r,p.y);
    return objDistance2D(v);
}


vec3 objNormalRot(vec3 p){
    float r=length(p.xz);
    vec2 v=vec2(r,p.y);
    vec2 n=objNormal2D(v);
    
    //get the right directions in 3D to point the vector
    vec3 rVec=normalize(vec3(p.x,0,p.z));
    vec3 hVec=vec3(0,1,0);
    
    return n.x*rVec+n.y*hVec;
}




















//-------------------------------------------------
//-------------------------------------------------
//=====useful 
//====OPERATIONS
//-------------------------------------------------
//-------------------------------------------------


//get the input for a 2d sdf/normal from a 3d point
vec2 opRevolution( in vec3 p, float w )
{
    return vec2( length(p.xz) - w, p.y );
}

vec3 opRevolutionOutputNormal(in vec3 p, float w, vec2 n){
    
    //right now this STRAIGHT UP IGNORES W
    vec3 rVec=normalize(vec3(p.x,0,p.z));
    vec3 hVec=vec3(0,1,0);
    
    return n.x*rVec+n.y*hVec;
}



//smooth min of signed distance functions
float opMinDist(float distA, float distB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float m = 0.25*h*h/k;
    return min(distA,distB)-m;
}


//smooth min of two normal vectors
vec3 opMinVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float n=0.5*h/k;
    float f=(distA<distB)?n:1.-n;
    return normalize(mix(nvecA, nvecB, f));
}



float opMaxDist( float a, float b, float k )
{
    return -opMinDist(-a,-b,k);
}

vec3 opMaxVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    return opMinVec(-distA, nvecA,-distB, nvecB,k);
}


float opOnionDist(float dist, float thickness){
    return abs(dist)-thickness;
}


vec3 opOnionVec(float dist,vec3 nVec){
    return sign(dist)*nVec;
}




vec3 opTwist( vec3 p )
{
   float k =50.0; // or some other amount
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec2 rot=m*p.xz;
    vec3  q = vec3(rot.x,p.y,rot.y);
   return q;
}






//-------------------------------------------------
//-------------------------------------------------
//=====distance to a 
//========SPHERE
//-------------------------------------------------
//-------------------------------------------------


//-------------------------------------------------
//  Basic Functions 
//-------------------------------------------------

float sphereDist(vec3 pos, float radius){
    
    return length(pos)-radius;
}


//the directed distance function: this can be improved with a better sphere locator test
float sphereDist(Vector tv, float radius){
    
    float d = sphereDist(tv.pos.coords, radius);
    
    //if you are looking away from the sphere, stop
    if(d>0.&&dot(tv.dir,tv.pos.coords)>0.){return maxDist;}
    
    //otherwise return the actual distance
    return d;
}


//----normal vector
vec3 sphereGrad(vec3 pos,  float radius){
    return normalize(pos);
}

//----normal vector
vec3 sphereGrad(Vector tv,  float radius){
    return normalize(tv.pos.coords);
}










//-------------------------------------------------
//-------------------------------------------------
//=====distance to a 
//========PLANE
//-------------------------------------------------
//-------------------------------------------------


//-------------------------------------------------
//  Basic Functions 
//-------------------------------------------------


float planeDist(vec3 pos, vec3 normal){
    
    return dot(pos,normal);
}


float planeDist(Vector tv, vec3 normal){
    
     if(dot(tv.dir,normal)>0.){return maxDist;}
    //otherwise, aimed at plane
    return planeDist(tv.pos.coords,normal);
}


vec3 planeGrad(vec3 pos, vec3 normal){
    return normal;
}









//-------------------------------------------------
//-------------------------------------------------
//=====distance to a 
//========BOX
//-------------------------------------------------
//-------------------------------------------------

float boxDist(vec3 pos,vec3 sides,float rounded){
    
    vec3 q=pos-sides;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - rounded;
}


float boxDist(Vector tv, vec3 sides, float rounded){
    return boxDist(tv.pos.coords, sides, rounded);
}


vec3 boxGrad(vec3 pos, vec3 sides, float rounded){
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    float vxyy=boxDist( pos + e.xyy*ep,sides,rounded);
    float vyyx=boxDist( pos + e.yyx*ep,sides,rounded);
    float vyxy=boxDist( pos + e.yxy*ep,sides, rounded);
    float vxxx=boxDist( pos + e.xxx*ep,sides, rounded);
    
    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
    
    return normalize(dir);
    
}


















//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======CYLINDER
//==from rotating a box
//-------------------------------------------------
//-------------------------------------------------


//from https://www.iquilezles.org/www/articles/distgradfunctions2d/distgradfunctions2d.htm
//get the distnance as .x and the 2d normal as .yz
vec3 sdgBox( in vec2 p, in vec2 b )
{
    vec2 w = abs(p)-b;
    vec2 s = vec2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
    return vec3(   (g>0.0)?l  :g,
                s*((g>0.0)?q/l:((w.x>w.y)?vec2(1,0):vec2(0,1))));
}



float cylinderDist(vec3 pos, float radius, float height, float rounded){
    
    vec2 p=opRevolution(pos,0.);
    //the box we rotate about its central axis has width 2rad and height = 2height.
    vec2 b=vec2(radius-rounded, height);
    
    vec2 w = abs(p)-b;
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
     
    float dist= (g>0.0) ?  l  :g;
    return dist-rounded;
}


vec3 cylinderGrad(vec3 pos, float radius, float height,float rounded){
    
    //roundedness plays no part in the calculation of the cylinder's gradient as it is just an offset.
    
    vec2 p=opRevolution(pos,0.);
    vec2 b=vec2(radius-rounded, height);
    
    //this gives distance and normal information
    vec3 ret=sdgBox(p,b);
    //second two coordinates are the 2d normal
    vec2 n=ret.yz;
    
    vec3 dir=opRevolutionOutputNormal(pos, 0., n);
    return dir;
    //return normalize(dir);
}

//
//
//
//vec3 cylinderGrad(vec3 pos, float radius, float height,float rounded){
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    float vxyy=cylinderDist( pos + e.xyy*ep,radius, height,rounded);
//    float vyyx=cylinderDist( pos + e.yyx*ep,radius, height,rounded);
//    float vyxy=cylinderDist( pos + e.yxy*ep,radius, height,rounded);
//    float vxxx=cylinderDist( pos + e.xxx*ep,radius, height,rounded);
//    
//    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
//    
//    dir=normalize(dir);
//    
//    return dir;
//    
//}







//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======RING
//==from a stretched torus
//-------------------------------------------------
//-------------------------------------------------


float ringDist(vec3 q, float radius, float tubeRad, float stretch){

    //choose the direction of elongation
    vec3 H=vec3(0,stretch,0);
    //stretch out the sdf
    vec4 w=vec4(q-clamp(q,-H,H),0.);
    //standard torus SDF
    vec2 Q=vec2(length(w.xz)-radius,w.y);
    float d=length(Q)-tubeRad;
    return d;
}


////probably a way to do this directly and not sample....
////should come back to this
vec3 ringGrad(vec3 pos, float radius, float tubeRad,float stretch){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    vec3 dir=  e.xyy*ringDist( pos + e.xyy*ep,radius, tubeRad,stretch) +
					  e.yyx*ringDist( pos + e.yyx*ep,radius, tubeRad,stretch) +
					  e.yxy*ringDist( pos + e.yxy*ep,radius, tubeRad,stretch) +
					  e.xxx*ringDist( pos + e.xxx*ep,radius, tubeRad,stretch);

    dir=normalize(dir);

    return dir;
}








//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======PRISM
//==from a extruded triangle
//-------------------------------------------------
//-------------------------------------------------



float prismDist( vec3 p, float length, float width)
{
  return max(p.z-length,max(p.x*0.866025+p.y*0.5,-p.y)-width*0.5);
}

////probably a way to do this directly and not sample....
vec3 prismGrad(vec3 pos, float length, float width){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    vec3 dir=  e.xyy*prismDist( pos + e.xyy*ep,length, width ) +
					  e.yyx*prismDist( pos + e.yyx*ep,length, width) +
					  e.yxy*prismDist( pos + e.yxy*ep,length, width) +
					  e.xxx*prismDist( pos + e.xxx*ep,length,width);

    dir=normalize(dir);

    return dir;
}











//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======OCTAHEDRON
//-------------------------------------------------
//-------------------------------------------------



float octahedronDist( vec3 p, float side)
{
     p = abs(p);
     float dist= (p.x+p.y+p.z-side)*0.57735027;
    return dist;
}




////probably a way to do this directly and not sample....
vec3 octahedronGrad(vec3 pos, float side){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    vec3 dir=  e.xyy*octahedronDist( pos + e.xyy*ep,side ) +
    e.yyx*octahedronDist( pos + e.yyx*ep,side) +
    e.yxy*octahedronDist( pos + e.yxy*ep,side) +
    e.xxx*octahedronDist( pos + e.xxx*ep,side);

    dir=normalize(dir);

    return dir;
}



//vec3 octahedronGrad(vec3 p, float side){
//
//    //take the (1,1,1) vector with appropriate signs given the starting octant
//    vec3 dir=vec3(sign(p.x),sign(p.y),sign(p.z));
//    dir=normalize(dir);
//    return dir;
//}







//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======LENS
//==from intersection of two spheres
//-------------------------------------------------
//-------------------------------------------------


float lensDist(vec3 pos, vec3 c1, vec3 c2, float R){

    float dist1=sphereDist(pos,sphereDist(pos-c1,R));
    float dist2=sphereDist(pos,sphereDist(pos-c2,R));

    return max(dist1,dist2);
}


vec3 lensGrad(vec3 pos, vec3 c1, vec3 c2, float R){

        float s1=abs(sphereDist(pos-c1,R));
        float s2=abs(sphereDist(pos-c2,R));

        if(s1<s2){//closer to surface of s1 than s2
            return sphereGrad(pos-c1,R);
        }
        return sphereGrad(pos-c2,R);
}




//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======STANFORD BUNNY
//-------------------------------------------------
//-------------------------------------------------
//

float bunnyDist(vec3 p,float size) {
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

    return size*res;
}



vec3 bunnyGrad(vec3 pos, float size){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=bunnyDist( pos + e.xyy*ep,size);
    float vyyx=bunnyDist( pos + e.yyx*ep,size);
    float vyxy=bunnyDist( pos + e.yxy*ep,size);
    float vxxx=bunnyDist( pos + e.xxx*ep,size);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    return normalize(dir);

}
















//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======TORUS (should probably be done before ring)
//-------------------------------------------------
//-------------------------------------------------
//


float Torus(float x, float y, float z, float R, float r)
{
    return sqrt(sq(sqrt(sq(x)+sq(z))-R)+sq(y))-r;
}

float Torus(vec3 p, float R, float r)
{
    return sqrt(sq(sqrt(sq(p.x)+sq(p.z))-R)+sq(p.y))-r;
}











//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======TWISTY CYLINDER
//-------------------------------------------------
//-------------------------------------------------
//
//
//
//float twistyDist(vec3 pos, float radius, float height, float rounded){
//    
//  //  vec3 p=pos-vec3(1,0,0);
//    const float k = 7.0; // or some other amount
//    float c = cos(k*pos.y);
//    float s = sin(k*pos.y);
//    float x=c*pos.x-s*pos.z;
//    float z=s*pos.x+c*pos.z;
//    //mat2  m = mat2(c,-s,s,c);
//    //vec2 rot=m*p.xz;
//    
//    vec3 p = vec3(x,pos.y,z);
//    
//    float le=1.5;
//    float r1=0.4;
//    float r2=0.1;
// 
//  vec3 q = vec3( p.x, max(abs(p.y)-le,0.0), p.z );
//  return length(vec2(length(q.xy)-r1,q.z)) - r2;
//
//    
//   // return cylinderDist(q,radius,height,0.);
//}
//
//
//vec3 twistyGrad(vec3 pos, float radius, float height,float rounded){
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    float vxyy=twistyDist( pos + e.xyy*ep,radius, height,rounded);
//    float vyyx=twistyDist( pos + e.yyx*ep,radius, height,rounded);
//    float vyxy=twistyDist( pos + e.yxy*ep,radius, height,rounded);
//    float vxxx=twistyDist( pos + e.xxx*ep,radius, height,rounded);
//    
//    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
//    
//    dir=normalize(dir);
//    
//    return dir;
//    
//}




