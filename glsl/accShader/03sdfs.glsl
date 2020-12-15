
//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};

float sphereSDF(Vector tv, vec3 center, float rad){
    //if you are looking away from the sphere, stop
   if(dot(tv.dir,tv.pos-center)>0.){return maxDist;}
    //else return distance to closest point
    return length(tv.pos-center)-rad;
}

Vector sphereNormal(Vector tv, vec3 center){
    return Vector(tv.pos,normalize(tv.pos-center));
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

float planeSDF(Vector tv, vec3 normal, float D){
    //does not need to be a unit normal vector
    //D is the constant in ax+by+cz+d=0
    if(dot(tv.dir,normal)>0.){return maxDist;}
    
    //otherwise give distance to closest point
   float d=dot(tv.pos,normal)+D;
   d= d/length(normal);
    return d;
}

Vector planeNormal(Vector tv,vec3 normal, float D){
    return Vector(tv.pos, normalize(normal));
}













//-------------------------------------------------
// The RING sdf
//-------------------------------------------------


//the data of a ring is its center, its radius, its tubeRadius, and the height elongation

struct Ring{
    vec3 center;
    float radius;
    float tubeRad;
    float height;
    Material mat;
};

float ringSDF(vec3 pos,vec2 rad,float height,vec3 center){
 
    //recenter things
    vec3 q = pos-center;
    //choose the direction of elongation
    vec3 H=vec3(0,height,0);
    //stretch out the sdf
    vec4 w=vec4(q-clamp(q,-H,H),0.);
    //standard torus SDF
    vec2 Q=vec2(length(w.xz)-rad.x,w.y);
    float d=length(Q)-rad.y;

    return d;

}


float ringSDF(Vector tv, vec2 rad,float height,vec3 center){
    return ringSDF(tv.pos,rad,height,center);
}


//probably a way to do this directly and not sample....
//should come back to this
Vector ringNormal(Vector tv, vec2 rad, float height,vec3 center){
    vec3 pos=tv.pos-center;
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir= normalize( e.xyy*ringSDF( pos + e.xyy*ep,rad,height,vec3(0.) ) + 
					  e.yyx*ringSDF( pos + e.yyx*ep,rad,height ,vec3(0.)) + 
					  e.yxy*ringSDF( pos + e.yxy*ep,rad,height ,vec3(0.)) + 
					  e.xxx*ringSDF( pos + e.xxx*ep,rad,height ,vec3(0.)) );
    
    return Vector(pos,dir);
}
    


    