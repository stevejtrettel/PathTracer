
//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};



float sphDist(Vector tv,Sphere sph){
    return length(tv.pos-sph.center)-sph.radius;
}


Vector sphereNormal(Vector tv, Sphere sph){
    return Vector(tv.pos,normalize(tv.pos-sph.center));
}




float sphereSDF(Vector tv, Sphere sph,inout localData dat){
    
    //if you are looking away from the sphere, stop
   if(dot(tv.dir,tv.pos-sph.center)>0.){return maxDist;}
    
    //else return distance to closest point
    float d = sphDist(tv,sph);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=sphereNormal(tv,sph);
        dat.mat=sph.mat;
        //dat.hit=true;
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



Vector planeNormal(Vector tv,Plane plane){
    return Vector(tv.pos, normalize(plane.normal));
}


float planeSDF(Vector tv, Plane plane, inout localData dat){
    //does not need to be a unit normal vector
    //D is the constant in ax+by+cz+d=0
    if(dot(tv.dir,plane.normal)>0.){return maxDist;}
    
    //otherwise give distance to closest point
    float d=dot(tv.pos,plane.normal)+plane.offset;
    d= d/length(plane.normal);
    
        //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=planeNormal(tv,plane);
        dat.mat=plane.mat;
       // dat.hit=true;
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




    