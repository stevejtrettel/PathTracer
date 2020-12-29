

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
    Point c1;
    Point c2;
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
    lens.c1=Point(c1);
    lens.c2=Point(c2);
}




float lensDist(vec3 pos,Lens lens){
    

    float dist1=sphDist(pos,Sphere(lens.c1,lens.R,lens.mat));
    float dist2=sphDist(pos,Sphere(lens.c2,lens.R,lens.mat));
    
    return max(dist1,dist2);
}



Vector lensNormal(Vector tv,Lens lens){
    
    Sphere sph1=Sphere(lens.c1,lens.R,lens.mat);
    Sphere sph2=Sphere(lens.c2,lens.R,lens.mat);
    
    float s1=abs(sphDist(tv.pos.coords,sph1));
    float s2=abs(sphDist(tv.pos.coords,sph2));
    
    if(s1<s2){//closer to surface of s1 than s2
        return sphereNormal(tv,sph1);
    }
    return sphereNormal(tv,sph2);

}





float lensSDF(Vector tv, Lens lens, inout localData dat){
    
    
    float d= lensDist(tv.pos.coords,lens);
    
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
    vec3 pos=tv.pos.coords;
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*cocktailDist( pos + e.xyy*ep,glass) + 
					  e.yyx*cocktailDist( pos + e.yyx*ep,glass) + 
					  e.yxy*cocktailDist( pos + e.yxy*ep,glass) + 
					  e.xxx*cocktailDist( pos + e.xxx*ep,glass);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
}
    



float cocktailSDF(Path path, Cocktail glass, inout localData dat){
    
    
    float d= cocktailDist(path.tv.pos.coords,glass);
    
    //-----------------
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=cocktailNormal(path.tv,glass);
        dat.mat=glass.mat;
    }
    
    return d;
    
}




















//-------------------------------------------------
// The NEGRONI sdf
//-------------------------------------------------

struct Negroni{
vec3 center;
float radius;
float height;
float thickness;
float base;
Material cup;
Material drink;
};




float  cupDist( vec3 p, Negroni negroni)
{
    
    Cylinder outside;
    Cylinder inside;

    outside.center=negroni.center;
    outside.radius=negroni.radius;
    outside.height=negroni.height;
    outside.rounded=0.1;

    inside.center=negroni.center+vec3(0,negroni.base,0);
    inside.radius=negroni.radius-negroni.thickness;
    inside.height=negroni.height;
    outside.rounded=0.1;

    float outsideGlass=cylinderDist(p,outside);
    float insideGlass=cylinderDist(p,inside);
    
    return max(outsideGlass,-insideGlass);
}


Vector cupNormal(Vector tv,Negroni negroni){
    
    vec3 pos=tv.pos.coords;
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*cupDist( pos + e.xyy*ep,negroni) + 
					  e.yyx*cupDist( pos + e.yyx*ep,negroni) + 
					  e.yxy*cupDist( pos + e.yxy*ep,negroni) + 
					  e.xxx*cupDist( pos + e.xxx*ep,negroni);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
    
}


float drinkDist(vec3 p, Negroni negroni){
    
    Cylinder inside;
    
    inside.center=negroni.center+vec3(0,negroni.base,0);
    inside.radius=negroni.radius-negroni.thickness;
    inside.height=negroni.height;
    inside.rounded=0.3;
    
    float fullDrink=cylinderDist(p,inside);
    
    //get the top of the drink:
    float drinkHeight=negroni.center.y;
    
    //sdf for the half space determined by drink:
    float topDist=p.y-drinkHeight;
    
    return max(fullDrink,topDist);
}


Vector drinkNormal(Vector tv,Negroni negroni){
    
    vec3 pos=tv.pos.coords;
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    vec3 dir=  e.xyy*drinkDist( pos + e.xyy*ep,negroni) + 
					  e.yyx*drinkDist( pos + e.yyx*ep,negroni) + 
					  e.yxy*drinkDist( pos + e.yxy*ep,negroni) + 
					  e.xxx*drinkDist( pos + e.xxx*ep,negroni);
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
    
}


float negroniSDF(Path path,Negroni negroni, inout localData dat){
    
    float cup=cupDist(path.tv.pos.coords,negroni);
    float drink=drinkDist(path.tv.pos.coords, negroni);
    
    //cup away from drink
    if(abs(cup)<EPSILON &&abs(drink)>EPSILON){
        dat.isSky=false;
        dat.normal=cupNormal(path.tv,negroni);
        dat.mat=negroni.cup;
        //no change to IOR
    }
    
    //drink away from cup
    if(abs(drink)<EPSILON&&abs(cup)>EPSILON){
        dat.isSky=false;
        dat.normal=drinkNormal(path.tv,negroni);
        dat.mat=negroni.drink;
        //no change to IOR
    }
    
    //if we are inside the glass and near the drink
    else if(cup<0.&& abs(drink)<5.*EPSILON){
                dat.isSky=false;
        dat.normal=cupNormal(path.tv,negroni);
        dat.mat=negroni.cup;
        //change in IOR
        dat.mat.IOR=negroni.cup.IOR/negroni.drink.IOR;
    }
    
    //if we are inside the drink near the glass
    else if(drink<0.&& abs(cup)<5.*EPSILON){
        dat.isSky=false;
        dat.normal=drinkNormal(path.tv,negroni);
        dat.mat=negroni.drink;
        //change in IOR
        dat.mat.IOR=negroni.drink.IOR/negroni.cup.IOR;
    }
    
    
//    
//     if(cup<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=cupNormal(path.tv,negroni);
//        dat.mat=negroni.cup;
//    }
//    
//    if(drink<EPSILON){
//         dat.isSky=false;
//        dat.normal=drinkNormal(path.tv,negroni);
//        dat.mat=negroni.drink;
//    }

    return min(cup,drink);
         
}




