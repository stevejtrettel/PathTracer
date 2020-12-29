
//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    Point center;
    float radius;
   // Isometry isom;
    Material mat;
};

void setSphere(inout Sphere sphere,Point center, float radius){
    sphere.center=center;
    sphere.radius=radius;
    //sphere.isom=makeTranslation(-center.coords);
}

//----distance or directed sdf

float sphDist(vec3 pos,Sphere sph){
    
    return length(pos-sph.center.coords)-sph.radius;
}

float sphDist(Point pos,Sphere sph){
    return length(pos.coords-sph.center.coords)-sph.radius;
}

float sphDist(Vector tv,Sphere sph){
    
    float d = sphDist(tv.pos,sph);
    
    //if you are looking away from the sphere, stop
    if(d>0.&&dot(tv.dir,tv.pos.coords-sph.center.coords)>0.){return maxDist;}
    
    //otherwise return the actual distance
    return d;
}


//----normal vector
Vector sphereNormal(Vector tv, Sphere sph){
    vec3 dir=tv.pos.coords-sph.center. coords;
    return Vector(tv.pos,normalize(dir));
}



//------sdf
float sphereSDF(Path path, Sphere sph,inout localData dat){
    
    //float side=(path.inside)?-1.:1.;
    
    //distance to closest point:
    float d = sphDist(path.tv,sph);
    
    if(abs(d)<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=sphereNormal(path.tv,sph);
        dat.mat=sph.mat;
    }

    
    return d;
}









//-------------------------------------------------
//The PLANE sdf
//-------------------------------------------------

//the data of a plane is its normal and a constant:

struct Plane{
    vec3 normal;
    float offset;
    Material mat;
};


//normalize the plane's vector before adding it:
void setPlane(inout Plane plane,vec3 normal,float offset){
    normal=normalize(normal);
    plane.normal=normal;
    plane.offset=offset;
}


Vector planeNormal(Vector tv,Plane plane){
    return Vector(tv.pos, plane.normal);
}


float planeSDF(Path path, Plane plane, inout localData dat){
    //does not need to be a unit normal vector
    //D is the constant in ax+by+cz+d=0
    if(dot(path.tv.dir,plane.normal)>0.){return maxDist;}
    
    //otherwise give distance to closest point
    float d=dot(path.tv.pos.coords,plane.normal)+plane.offset;
   
    
    //-----------------
    
    if(abs(d)<EPSILON){
        dat.isSky=false;
        
       // if(d>0.){//hit something: set normal
        dat.normal=planeNormal(path.tv,plane);
       // }
        dat.mat=plane.mat;
        
        
    }

    
    return d;
    
}















//-------------------------------------------------
// The RING sdf
//-------------------------------------------------


//the data of a ring is its center, its radius, its tubeRadius, and the height elongation

struct Ring{
    Isometry isom;
    vec3 center;
    float radius;
    float tubeRad;
    float stretch;
    Material mat;
};


float ringDist(vec3 pos, Ring ring){
    
     //recenter things
    vec3 q = pos-ring.center;
    //choose the direction of elongation
    vec3 H=vec3(0,ring.stretch,0);
    //stretch out the sdf
    vec4 w=vec4(q-clamp(q,-H,H),0.);
    //standard torus SDF
    vec2 Q=vec2(length(w.xz)-ring.radius,w.y);
    float d=length(Q)-ring.tubeRad;

    return d;
}



//probably a way to do this directly and not sample....
//should come back to this
Vector ringNormal(Vector tv, Ring ring){
    
    //translate everything
    vec3 pos=tv.pos.coords-ring.center;
    
    //reset ring's center to zero:
    ring.center=vec3(0.);
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*ringDist( pos + e.xyy*ep,ring ) + 
					  e.yyx*ringDist( pos + e.yyx*ep,ring) + 
					  e.yxy*ringDist( pos + e.yxy*ep,ring) + 
					  e.xxx*ringDist( pos + e.xxx*ep,ring);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
}
    





float ringSDF(Vector tv, Ring ring,inout localData dat){


    float d= ringDist(tv.pos.coords,ring);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=ringNormal(tv,ring);
        dat.mat=ring.mat;
    }
    
    return d;
}




    














//-------------------------------------------------
// The PRISM sdf
//-------------------------------------------------

struct Prism{
vec3 center;
float length;
float width;
Material mat;
};



float prismDist( vec3 p, Prism prism)
{
  vec3 q = abs(p-prism.center);
  return max(q.z-prism.length,max(q.x*0.866025+p.y*0.5,-p.y)-prism.width*0.5);
}




//probably a way to do this directly and not sample....
Vector prismNormal(Vector tv, Prism prism){
    
    //translate everything
    vec3 pos=tv.pos.coords-prism.center;
    
    //reset prism's center to zero:
    prism.center=vec3(0.);
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*prismDist( pos + e.xyy*ep,prism ) + 
					  e.yyx*prismDist( pos + e.yyx*ep,prism) + 
					  e.yxy*prismDist( pos + e.yxy*ep,prism) + 
					  e.xxx*prismDist( pos + e.xxx*ep,prism);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
}
    



float prismSDF(Vector tv, Prism prism, inout localData dat){
    
    
    float d= prismDist(tv.pos.coords,prism);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=prismNormal(tv,prism);
        dat.mat=prism.mat;
    }
    
    return d;
    
}














//-------------------------------------------------
// The OCTAHEDRON sdf
//-------------------------------------------------

struct Octahedron{
vec3 center;
float side;
Material mat;
};




float octahedronDist( vec3 p, Octahedron oct)
{
 p = abs(p-oct.center);
 float dist= (p.x+p.y+p.z-oct.side)*0.57735027;
    return dist;
}




//probably a way to do this directly and not sample....
Vector octahedronNormal(Vector tv, Octahedron oct){
    
    //translate everything
    vec3 pos=tv.pos.coords-oct.center;
    
    //reset prism's center to zero:
    oct.center=vec3(0.);
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*octahedronDist( pos + e.xyy*ep,oct) + 
					  e.yyx*octahedronDist( pos + e.yyx*ep,oct) + 
					  e.yxy*octahedronDist( pos + e.yxy*ep,oct) + 
					  e.xxx*octahedronDist( pos + e.xxx*ep,oct);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
}
    



float octahedronSDF(Path path, Octahedron oct, inout localData dat){
    
    
    float d= octahedronDist(path.tv.pos.coords,oct);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=octahedronNormal(path.tv,oct);
        dat.mat=oct.mat;
    }
    
    return d;
    
}













//-------------------------------------------------
// The BOX sdf
//-------------------------------------------------

struct Box{
vec3 center;
vec3 sides;
float rounded;
Material mat;
};


float boxDist( vec3 p, Box box)
{
  vec3 q = abs(p-box.center) - box.sides;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded;
}



//probably a way to do this directly and not sample....
Vector boxNormal(Vector tv, Box box){
    
    //translate everything
    vec3 pos=tv.pos.coords-box.center;
    
    //reset prism's center to zero:
    box.center=vec3(0.);
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*boxDist( pos + e.xyy*ep,box) + 
					  e.yyx*boxDist( pos + e.yyx*ep,box) + 
					  e.yxy*boxDist( pos + e.yxy*ep,box) + 
					  e.xxx*boxDist( pos + e.xxx*ep,box);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
}
    



float boxSDF(Vector tv, Box box, inout localData dat){
    
    
    float d= boxDist(tv.pos.coords,box);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=boxNormal(tv,box);
        dat.mat=box.mat;
    }
    
    return d;
    
}














//-------------------------------------------------
// The PERMUTOHEDRON sdf
//-------------------------------------------------

struct Permutohedron{
vec3 center;
float side;
Material mat;
};


float permutohedronDist( vec3 p, Permutohedron perm)
{
 
Octahedron oct;
oct.center=perm.center;
oct.side=perm.side;
    
Box box;
box.center=perm.center;
box.sides=0.66*vec3(perm.side,perm.side,perm.side);
    
//octahedron distance:
float octDist=octahedronDist(p,oct);
float cubeDist=boxDist(p,box);
    
return max(octDist,cubeDist);
}



//probably a way to do this directly and not sample....
Vector permutohedronNormal(Vector tv, Permutohedron perm){
    
    //translate everything
    vec3 pos=tv.pos.coords-perm.center;
    
    //reset prism's center to zero:
    perm.center=vec3(0.);
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*permutohedronDist( pos + e.xyy*ep,perm) + 
					  e.yyx*permutohedronDist( pos + e.yyx*ep,perm) + 
					  e.yxy*permutohedronDist( pos + e.yxy*ep,perm) + 
					  e.xxx*permutohedronDist( pos + e.xxx*ep,perm);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
}
    



float permutohedronSDF(Vector tv, Permutohedron perm, inout localData dat){
    
    
    float d= permutohedronDist(tv.pos.coords,perm);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=permutohedronNormal(tv,perm);
        dat.mat=perm.mat;
    }
    
    return d;
    
}










//-------------------------------------------------
// The ROUNDED CYLINDER sdf
//-------------------------------------------------

struct Cylinder{
    vec3 center;
    float radius;
    float height;
    float rounded;
    Material mat;
    Isometry isom;
};



float cylinderDist( vec3 p, Cylinder cyl )
{
    p=p-cyl.center;
  vec2 d = vec2( length(p.xz)-2.0*cyl.radius+cyl.rounded, abs(p.y) - cyl.height );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - cyl.rounded;
}





//probably a way to do this directly and not sample....
Vector cylinderNormal(Vector tv, Cylinder cyl){
    vec3 pos=tv.pos.coords;
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*cylinderDist( pos + e.xyy*ep,cyl) + 
					  e.yyx*cylinderDist( pos + e.yyx*ep,cyl) + 
					  e.yxy*cylinderDist( pos + e.yxy*ep,cyl) + 
					  e.xxx*cylinderDist( pos + e.xxx*ep,cyl);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
}
    



float cylinderSDF(Vector tv, Cylinder cyl, inout localData dat){
    
    
    float d= cylinderDist(tv.pos.coords,cyl);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=cylinderNormal(tv,cyl);
        dat.mat=cyl.mat;
    }
    
    return d;
    
}





