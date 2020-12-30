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
//=====distance to a 
//========CYLINDER
//-------------------------------------------------
//-------------------------------------------------

//float cylinderDistance(vec3 pos, float radius, float height, float rounded){
//    
//    vec2 d = vec2( length(pos.xz)-2.0*radius+rounded, abs(pos.y) - height );
//  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rounded;
//    
//}


//float cylinderDistance(Vector tv, float radius, float height, float rounded){
//    return cylinderDistance(tv.pos.coords, radius, height, rounded);
//}



//
//
//
//
//
//Vector cylinderNormal(vec3 pos, float radius, float height,float rounded){
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    float vxyy=cylinderDistance( pos + e.xyy*ep,radius, height,rounded);
//    float vyyx=cylinderDistance( pos + e.yyx*ep,radius, height,rounded);
//    float vyxy=cylinderDistance( pos + e.yxy*ep,radius, height,rounded);
//    float vxxx=cylinderDistance( pos + e.xxx*ep,radius, height,rounded);
//    
//    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
//    
//    dir=normalize(dir);
//    
//    return Vector(Point(pos),dir);
//    
//}


//Vector cylinderNormal(Vector tv, float radius, float height, float rounded){
//    vec3 pos=tv.pos.coords;
//    return cylinderNormal(pos,radius, height, rounded);
//}
//
//
//







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
    vec2 b=vec2(2.*radius, height);
    
    vec2 w = abs(p)-b;
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
     
    float dist= (g>0.0) ?  l  :g;
    return dist;
}



vec3 cylinderGrad(vec3 pos, float radius, float height, float rounded){
    
    vec2 p=opRevolution(pos,0.);
    vec2 b=vec2(2.*radius, height);
    
    //this gives distance and normal information
    vec3 ret=sdgBox(p,b);
    //second two coordinates are the 2d normal
    vec2 n=ret.yz;
    
    vec3 dir=opRevolutionOutputNormal(pos, 0., n);
    
    return normalize(dir);
}

