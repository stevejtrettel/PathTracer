

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
    vec3 q1=p-glass.center+vec3(0,glass.base,0);;
    vec3 q2=p-glass.center;
    
    float outer=sdRoundedCylinder(q1,glass.radius+0.15,glass.rounded,glass.height);
    
   float inner=sdRoundedCylinder(q2,glass.radius,glass.rounded,glass.height);
    
    
    float heightAdjust=glass.height+0.66*glass.base;
    vec3 ballCenter=glass.center-vec3(0.,heightAdjust,0.);
    float ball=length(p-ballCenter)-glass.base/2.;
    
    float dist=smax(outer,-ball,0.2);
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

