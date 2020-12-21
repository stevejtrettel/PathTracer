
//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    Point center;
    float radius;
    Material mat;
};







float sphDist(vec3 pos,Sphere sph){

    return fakeDistance(Point(pos),sph.center)-sph.radius;
}


Vector sphereNormal(Vector tv, Sphere sph){
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    //make matrix which translates observer to origin
    Isometry shift=makeInvLeftTranslation(tv.pos);
    
    //shift the sphere by this:
    sph.center=translate(shift,sph.center);
    
    //find the tangent vector
    vec3 dir=  e.xyy*sphDist( ORIGIN.coords+ e.xyy*ep,sph ) + 
					  e.yyx*sphDist( ORIGIN.coords + e.yyx*ep,sph) + 
					  e.yxy*sphDist( ORIGIN.coords + e.yxy*ep,sph) + 
					  e.xxx*sphDist( ORIGIN.coords + e.xxx*ep,sph);
    
    dir=normalize(dir);
    
    //make the output vector: original position + this tangent

    return Vector(tv.pos,dir);
}


float sphereSDF(Vector tv, Sphere sph,inout localData dat){
    
    //distance to closest point:
    float d = sphDist(tv.pos.coords,sph);
    

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

struct EucPlane{
    float height;
    float sign;
    Material mat;
};


float EucPlaneDist(Point p,EucPlane plane){
    return plane.sign*(p.coords.z-plane.height);
}


Vector EucPlaneNormal(Vector tv,EucPlane plane){
    return Vector(tv.pos, plane.sign*vec3(0,0,1));
}





vec3 EucPlaneColor(Vector tv,EucPlane plane,vec3 origColor){
    vec3 color=vec3(0.);

    float x=tv.pos.coords.x;
    float y=tv.pos.coords.y;
    float z=tv.pos.coords.z;
    float h=plane.height;
    
    float c1=fract(5.*exp(-plane.height)*x);
    float c2=fract(5.*y*exp(plane.height));
    
    if(0.3<c1&&c1<0.45&& 0.3<c2&&c2<0.45){
     color=3.*origColor;
    }
    
    else if(0.15<c1&&c1<0.6&& 0.15<c2&&c2<0.6){
     color=2.*origColor;
    }
    else if(c1<0.75&& c2<0.75){
     color=origColor;
    }
    else{
        color=0.5*origColor;
    }
    return color;   
}








float EucPlaneSDF(Vector tv, EucPlane plane, inout localData dat){

    //otherwise give distance to closest point
    float d=EucPlaneDist(tv.pos,plane);
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=EucPlaneNormal(tv,plane);
        dat.mat=plane.mat;
    dat.mat.diffuseColor=EucPlaneColor(tv,plane,plane.mat.diffuseColor);
    }
    
    return d;
    
}













//-------------------------------------------------
//The HYPERBOLIC SHEET sdf
//-------------------------------------------------


struct HypSheet{
    float offset;
    float type;//x or y
    float sign;//pos or neg
    Material mat;
};



float HypSheetDist(Point p,HypSheet sheet){
    float h=(sheet.type==1.)?p.coords.x:p.coords.y;
    return sheet.sign*asinh((h-sheet.offset)*exp(-sheet.type*p.coords.z));
}


Vector HypSheetNormal(Vector tv,HypSheet sheet){
    vec3 dir=(sheet.type==1.)?vec3(1,0,0):vec3(0,1,0);
    return Vector(tv.pos,sheet.sign*dir);
}



vec3 HypSheetColor(Vector tv, HypSheet sheet,vec3 origColor){
    
    vec3 color=vec3(0.);

    float w=(sheet.type==1.)?tv.pos.coords.y:tv.pos.coords.x;
    float h=tv.pos.coords.z;

    
    float c1=fract(w);
    float c2=fract(h);
    
    
    if(0.3<c1&&c1<0.45&& 0.3<c2&&c2<0.45){
     color=3.*origColor;
    }
    
    else if(0.15<c1&&c1<0.6&& 0.15<c2&&c2<0.6){
     color=2.*origColor;
    }
    else if(c1<0.75&& c2<0.75){
     color=origColor;
    }
    else{
        color=0.5*origColor;
    }
    
    return color;
}
    
    
    
    
float HypSheetSDF(Vector tv, HypSheet sheet, inout localData dat){

    //otherwise give distance to closest point
    float d=HypSheetDist(tv.pos,sheet);
    
    if(d<EPSILON){//set the material
        dat.isSky=false;
        dat.normal=HypSheetNormal(tv,sheet);
        dat.mat=sheet.mat;
    dat.mat.diffuseColor=HypSheetColor(tv,sheet,sheet.mat.diffuseColor);
    }
    
    return d;
    
}








