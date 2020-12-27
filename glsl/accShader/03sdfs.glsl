
//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};



float sphDist(vec3 pos,Sphere sph){
    return length(pos-sph.center)-sph.radius;
}


Vector sphereNormal(Vector tv, Sphere sph){
    return Vector(tv.pos,normalize(tv.pos-sph.center));
}




float sphereSDF(Vector tv, Sphere sph,inout localData dat){
    
    //distance to closest point:
    float d = sphDist(tv.pos,sph);
    
    //if you are looking away from the sphere, stop
    if(d>0.&&dot(tv.dir,tv.pos-sph.center)>0.){return maxDist;}
    
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=sphereNormal(tv,sph);
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


float planeSDF(Vector tv, Plane plane, inout localData dat){
    //does not need to be a unit normal vector
    //D is the constant in ax+by+cz+d=0
    if(dot(tv.dir,plane.normal)>0.){return maxDist;}
    
    //otherwise give distance to closest point
    float d=dot(tv.pos,plane.normal)+plane.offset;
   
    
        //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=planeNormal(tv,plane);
        dat.mat=plane.mat;
    }
    
    return d;
    
}















//-------------------------------------------------
// The RING sdf
//-------------------------------------------------


//the data of a ring is its center, its radius, its tubeRadius, and the height elongation

struct Ring{
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
    vec3 pos=tv.pos-ring.center;
    
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


    float d= ringDist(tv.pos,ring);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=ringNormal(tv,ring);
        dat.mat=ring.mat;
    }
    
    return d;
}




    





//-------------------------------------------------
// The LENS sdf
//-------------------------------------------------

//the data of a lens is determined by its radius, thickness
//position/orientation by its center, axis
//from these we compute auxilary quantities: sphere rad and 2 centers

struct Lens{
    float radius;
    float thickness;
    vec3 center;
    vec3 axis;
    Material mat;
    float R;
    vec3 c1;
    vec3 c2;
};



void setLens(inout Lens lens, float r,float d, vec3 center, vec3 axis){
    //compute sphere radius:
    
    lens.radius=r;
    lens.thickness=d;
    lens.center=center;
    lens.axis=normalize(axis);
    
    //compute auxillary quantities
    float R=(r*r+d*d)/(2.*d);
    vec3 c1=center+(R-d)*axis;
    vec3 c2=center-(R-d)*axis;
    
    lens.R=R;
    lens.c1=c1;
    lens.c2=c2;
}




float lensDist(vec3 pos,Lens lens){
    

    float dist1=sphDist(pos,Sphere(lens.c1,lens.R,lens.mat));
    float dist2=sphDist(pos,Sphere(lens.c2,lens.R,lens.mat));
    
    return max(dist1,dist2);
}



Vector lensNormal(Vector tv,Lens lens){
    
    Sphere sph1=Sphere(lens.c1,lens.R,lens.mat);
    Sphere sph2=Sphere(lens.c2,lens.R,lens.mat);
    
    float s1=abs(sphDist(tv.pos,sph1));
    float s2=abs(sphDist(tv.pos,sph2));
    
    if(s1<s2){//closer to surface of s1 than s2
        return sphereNormal(tv,sph1);
    }
    return sphereNormal(tv,sph2);

}





float lensSDF(Vector tv, Lens lens, inout localData dat){
    
    
    float d= lensDist(tv.pos,lens);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=lensNormal(tv,lens);
        dat.mat=lens.mat;
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
    vec3 pos=tv.pos-prism.center;
    
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
    
    
    float d= prismDist(tv.pos,prism);
    
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
  return (p.x+p.y+p.z-oct.side)*0.57735027;
}




//probably a way to do this directly and not sample....
Vector octahedronNormal(Vector tv, Octahedron oct){
    
    //translate everything
    vec3 pos=tv.pos-oct.center;
    
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
    



float octahedronSDF(Vector tv, Octahedron oct, inout localData dat){
    
    
    float d= octahedronDist(tv.pos,oct);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=octahedronNormal(tv,oct);
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
    vec3 pos=tv.pos-box.center;
    
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
    
    
    float d= boxDist(tv.pos,box);
    
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
    vec3 pos=tv.pos-perm.center;
    
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
    
    
    float d= permutohedronDist(tv.pos,perm);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=permutohedronNormal(tv,perm);
        dat.mat=perm.mat;
    }
    
    return d;
    
}


















//-------------------------------------------------
// The COCKTAIL sdf
//-------------------------------------------------

struct Cocktail{
vec3 center;
float radius;
float height;
float rounded;
float base;
Material mat;
};



//useful sdf
float sdRoundedCylinder( vec3 p, float ra, float rb, float h )
{
  vec2 d = vec2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
}


float cocktailDist( vec3 p, Cocktail glass)
{
    vec3 q1=p-glass.center;
    vec3 q2=q1-vec3(0,glass.base,0);
    
    float outer=sdRoundedCylinder(q1,glass.radius,glass.rounded,glass.height);
    
   float inner=sdRoundedCylinder(q2,glass.radius-0.15,glass.rounded,glass.height);
    
    vec3 ballCenter=glass.center-vec3(0.,glass.height-glass.base/3.,0.);
    float ball=length(p-ballCenter)-glass.base/2.;
    
    float dist=smax(outer,-ball,0.1);
    return max(dist,-inner);
    
}




//probably a way to do this directly and not sample....
Vector cocktailNormal(Vector tv, Cocktail glass){
    vec3 pos=tv.pos;
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*cocktailDist( pos + e.xyy*ep,glass) + 
					  e.yyx*cocktailDist( pos + e.yyx*ep,glass) + 
					  e.yxy*cocktailDist( pos + e.yxy*ep,glass) + 
					  e.xxx*cocktailDist( pos + e.xxx*ep,glass);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
}
    



float cocktailSDF(Vector tv, Cocktail glass, inout localData dat){
    
    
    float d= cocktailDist(tv.pos,glass);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=cocktailNormal(tv,glass);
        dat.mat=glass.mat;
    }
    
    return d;
    
}

