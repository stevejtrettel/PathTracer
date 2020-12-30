
//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    Point center;
    float radius;
    Material mat;
};

//----distance and normal functions

float sphereDistance(Vector tv, Sphere sph){
    tv.pos.coords-=sph.center.coords;
    return sphereDist(tv,sph.radius);
}

Vector sphereNormal(Vector tv, Sphere sph){
    tv.pos.coords-=sph.center.coords;
    vec3 dir=sphereGrad(tv,sph.radius);
    return Vector(tv.pos,dir);
}



//what to do when you hit a sphere:
void sphereData(inout Path path, inout localData dat, float dist, Sphere obj){
    
    //set the material
    dat.isSky=false;
    dat.mat=obj.mat;

    Vector normal=sphereNormal(path.tv,obj);
    
    if(dist<0.){
        path.inside=true;
        //normal is inwward pointing;
        dat.normal=negate(normal);
        //IOR is current/enteing
        dat.IOR=obj.mat.IOR/1.;
        
        dat.reflectAbsorb=obj.mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
    }
    
    else{
        path.inside=false;
        //normal is inwward pointing;
        dat.normal=normal;
        //IOR is current/enteing
        dat.IOR=1./obj.mat.IOR;
        
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=obj.mat.absorbColor;
        
    }
    
}




//------sdf
float sphereSDF(inout Path path, Sphere sph,inout localData dat){
    
    //float side=(path.inside)?-1.:1.;
    
    //distance to closest point:
    float dist = sphereDistance(path.tv,sph);
    
    if(abs(dist)<EPSILON){//set the material
        sphereData(path,dat,dist,sph);
    }

    return dist;
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


float planeDistance(Vector tv, Plane plane){
    return planeDist(tv,plane.normal)+plane.offset;
}


Vector planeNormal(Vector tv,Plane plane){
    vec3 dir=planeGrad(tv.pos.coords,plane.normal);
    return Vector(tv.pos, dir);
}


float planeSDF(Path path, Plane plane, inout localData dat){

    float d=planeDistance(path.tv,plane);
    
    if(abs(d)<EPSILON){
        dat.isSky=false;
    
        dat.normal=planeNormal(path.tv,plane);
        dat.mat=plane.mat;
    }

    return d;
    
}










//-------------------------------------------------
//The CYLINDER sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Cylinder{
    Point center;
    float radius;
    float height;
    float rounded;
    Material mat;
};

//----distance and normal functions

float cylinderDistance(Vector tv, Cylinder cyl){
    
    vec3 pos=tv.pos.coords-cyl.center.coords;
    
    return cylinderDist(pos,cyl.radius,cyl.height, cyl.rounded);
}



Vector cylinderNormal(Vector tv, Cylinder cyl){
    
    vec3 pos=tv.pos.coords-cyl.center.coords;
    
    vec3 dir=cylinderGrad(pos,cyl.radius,cyl.height,cyl.rounded);
    
    return Vector(Point(pos),dir);
}



//what to do when you hit a sphere:
void cylinderData(inout Path path, inout localData dat, float dist,Cylinder obj){
    
    //set the material
    dat.isSky=false;
    dat.mat=obj.mat;
    
    //outward pointing normal vector
    Vector normal=cylinderNormal(path.tv,obj);
    
    if(dist<0.){
        path.inside=true;
        //normal is inwward pointing;
        dat.normal=negate(normal);
        //IOR is current/enteing
        dat.IOR=obj.mat.IOR/1.;
        
        dat.reflectAbsorb=obj.mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
    }
    
    else{
        path.inside=false;
        //normal is inwward pointing;
        dat.normal=normal;
        //IOR is current/enteing
        dat.IOR=1./obj.mat.IOR;
        
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=obj.mat.absorbColor;
        
    }  
}




//------sdf
float cylinderSDF(inout Path path, Cylinder cyl,inout localData dat){
    
    //float side=(path.inside)?-1.:1.;
    
    //distance to closest point:
    float dist = cylinderDistance(path.tv,cyl);
    
    if(abs(dist)<EPSILON){//set the material
        cylinderData(path,dat,dist,cyl);
    }

    return dist;
}








//-------------------------------------------------
//The BOTTLE sdf
//-------------------------------------------------


struct Bottle{
    Point center;
    float baseRadius;
    float baseHeight;  
    float neckRadius;
    float neckHeight;
    float thickness;
    Material mat;
};



//----distance and normal functions

float bottleDistance(vec3 p, Bottle bottle){
    
    vec3 pos=p-bottle.center.coords;
    
    //the base of the bottle
    float base=cylinderDist(pos,bottle.baseRadius, bottle.baseHeight,0.5);
    
    //the neck of the bottle
    //first: adjust the height
    vec3 q=pos-vec3(0,bottle.baseHeight+bottle.neckHeight,0);
    
    float neck=cylinderDist(q,bottle.neckRadius,bottle.neckHeight,0.5);
    
    //give the subtraction of these:
    float theBottle=smin(base, neck,1.);
    
    //now make a thin layer
    theBottle= abs(theBottle)-bottle.thickness;
    
    return theBottle;
}

float bottleDistance(Vector tv, Bottle bottle){
    return bottleDistance(tv.pos.coords,bottle);
}


Vector bottleNormal(Vector tv, Bottle bottle){
    
    vec3 pos=tv.pos.coords-bottle.center.coords;
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    float vxyy=bottleDistance( pos + e.xyy*ep,bottle);
    float vyyx=bottleDistance( pos + e.yyx*ep,bottle);
    float vyxy=bottleDistance( pos + e.yxy*ep,bottle);
    float vxxx=bottleDistance( pos + e.xxx*ep,bottle);
    
    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
    
}



//what to do when you hit a bottle:
void bottleData(inout Path path, inout localData dat, float dist,Bottle obj){
    
    //set the material
    dat.isSky=false;
    dat.mat=obj.mat;
    
    //outward pointing normal vector
    Vector normal=bottleNormal(path.tv,obj);
    
    if(dist<0.){
        path.inside=true;
        //normal is inwward pointing;
        dat.normal=negate(normal);
        //IOR is current/enteing
        dat.IOR=obj.mat.IOR/1.;
        
        dat.reflectAbsorb=obj.mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
    }
    
    else{
        path.inside=false;
        //normal is inwward pointing;
        dat.normal=normal;
        //IOR is current/enteing
        dat.IOR=1./obj.mat.IOR;
        
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=obj.mat.absorbColor;
        
    }  
}




//------sdf
float bottleSDF(inout Path path, Bottle bottle,inout localData dat){

    float dist = bottleDistance(path.tv,bottle);
    
    if(abs(dist)<EPSILON){//set the material
        bottleData(path,dat,dist,bottle);
    }

    return dist;
}















//
//
//
//
////-------------------------------------------------
//// The RING sdf
////-------------------------------------------------
//
//
////the data of a ring is its center, its radius, its tubeRadius, and the height elongation
//
//struct Ring{
//    Isometry isom;
//    vec3 center;
//    float radius;
//    float tubeRad;
//    float stretch;
//    Material mat;
//};
//
//
//float ringDist(vec3 pos, Ring ring){
//    
//     //recenter things
//    vec3 q = pos-ring.center;
//    //choose the direction of elongation
//    vec3 H=vec3(0,ring.stretch,0);
//    //stretch out the sdf
//    vec4 w=vec4(q-clamp(q,-H,H),0.);
//    //standard torus SDF
//    vec2 Q=vec2(length(w.xz)-ring.radius,w.y);
//    float d=length(Q)-ring.tubeRad;
//
//    return d;
//}
//
//
//
////probably a way to do this directly and not sample....
////should come back to this
//Vector ringNormal(Vector tv, Ring ring){
//    
//    //translate everything
//    vec3 pos=tv.pos.coords-ring.center;
//    
//    //reset ring's center to zero:
//    ring.center=vec3(0.);
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*ringDist( pos + e.xyy*ep,ring ) + 
//					  e.yyx*ringDist( pos + e.yyx*ep,ring) + 
//					  e.yxy*ringDist( pos + e.yxy*ep,ring) + 
//					  e.xxx*ringDist( pos + e.xxx*ep,ring);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//    
//
//
//
//
//
//float ringSDF(Vector tv, Ring ring,inout localData dat){
//
//
//    float d= ringDist(tv.pos.coords,ring);
//    
//    //-----------------
//    
//    if(d<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=ringNormal(tv,ring);
//        dat.mat=ring.mat;
//    }
//    
//    return d;
//}
//
//
//
//
//    
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////-------------------------------------------------
//// The PRISM sdf
////-------------------------------------------------
//
//struct Prism{
//vec3 center;
//float length;
//float width;
//Material mat;
//};
//
//
//
//float prismDist( vec3 p, Prism prism)
//{
//  vec3 q = abs(p-prism.center);
//  return max(q.z-prism.length,max(q.x*0.866025+p.y*0.5,-p.y)-prism.width*0.5);
//}
//
//
//
//
////probably a way to do this directly and not sample....
//Vector prismNormal(Vector tv, Prism prism){
//    
//    //translate everything
//    vec3 pos=tv.pos.coords-prism.center;
//    
//    //reset prism's center to zero:
//    prism.center=vec3(0.);
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*prismDist( pos + e.xyy*ep,prism ) + 
//					  e.yyx*prismDist( pos + e.yyx*ep,prism) + 
//					  e.yxy*prismDist( pos + e.yxy*ep,prism) + 
//					  e.xxx*prismDist( pos + e.xxx*ep,prism);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//    
//
//
//
//float prismSDF(Vector tv, Prism prism, inout localData dat){
//    
//    
//    float d= prismDist(tv.pos.coords,prism);
//    
//    //-----------------
//    
//    if(d<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=prismNormal(tv,prism);
//        dat.mat=prism.mat;
//    }
//    
//    return d;
//    
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////-------------------------------------------------
//// The OCTAHEDRON sdf
////-------------------------------------------------
//
//struct Octahedron{
//vec3 center;
//float side;
//Material mat;
//};
//
//
//
//
//float octahedronDist( vec3 p, Octahedron oct)
//{
// p = abs(p-oct.center);
// float dist= (p.x+p.y+p.z-oct.side)*0.57735027;
//    return dist;
//}
//
//
//
//
////probably a way to do this directly and not sample....
//Vector octahedronNormal(Vector tv, Octahedron oct){
//    
//    //translate everything
//    vec3 pos=tv.pos.coords-oct.center;
//    
//    //reset prism's center to zero:
//    oct.center=vec3(0.);
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*octahedronDist( pos + e.xyy*ep,oct) + 
//					  e.yyx*octahedronDist( pos + e.yyx*ep,oct) + 
//					  e.yxy*octahedronDist( pos + e.yxy*ep,oct) + 
//					  e.xxx*octahedronDist( pos + e.xxx*ep,oct);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//    
//
//
//
//float octahedronSDF(Path path, Octahedron oct, inout localData dat){
//    
//    
//    float d= octahedronDist(path.tv.pos.coords,oct);
//    
//    //-----------------
//    
//    if(d<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=octahedronNormal(path.tv,oct);
//        dat.mat=oct.mat;
//    }
//    
//    return d;
//    
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
////-------------------------------------------------
//// The BOX sdf
////-------------------------------------------------
//
//struct Box{
//vec3 center;
//vec3 sides;
//float rounded;
//Material mat;
//};
//
//
//float boxDist( vec3 p, Box box)
//{
//  vec3 q = abs(p-box.center) - box.sides;
//  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded;
//}
//
//
//
////probably a way to do this directly and not sample....
//Vector boxNormal(Vector tv, Box box){
//    
//    //translate everything
//    vec3 pos=tv.pos.coords-box.center;
//    
//    //reset prism's center to zero:
//    box.center=vec3(0.);
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*boxDist( pos + e.xyy*ep,box) + 
//					  e.yyx*boxDist( pos + e.yyx*ep,box) + 
//					  e.yxy*boxDist( pos + e.yxy*ep,box) + 
//					  e.xxx*boxDist( pos + e.xxx*ep,box);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//    
//
//
//
//float boxSDF(Vector tv, Box box, inout localData dat){
//    
//    
//    float d= boxDist(tv.pos.coords,box);
//    
//    //-----------------
//    
//    if(d<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=boxNormal(tv,box);
//        dat.mat=box.mat;
//    }
//    
//    return d;
//    
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////-------------------------------------------------
//// The PERMUTOHEDRON sdf
////-------------------------------------------------
//
//struct Permutohedron{
//vec3 center;
//float side;
//Material mat;
//};
//
//
//float permutohedronDist( vec3 p, Permutohedron perm)
//{
// 
//Octahedron oct;
//oct.center=perm.center;
//oct.side=perm.side;
//    
//Box box;
//box.center=perm.center;
//box.sides=0.66*vec3(perm.side,perm.side,perm.side);
//    
////octahedron distance:
//float octDist=octahedronDist(p,oct);
//float cubeDist=boxDist(p,box);
//    
//return max(octDist,cubeDist);
//}
//
//
//
////probably a way to do this directly and not sample....
//Vector permutohedronNormal(Vector tv, Permutohedron perm){
//    
//    //translate everything
//    vec3 pos=tv.pos.coords-perm.center;
//    
//    //reset prism's center to zero:
//    perm.center=vec3(0.);
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*permutohedronDist( pos + e.xyy*ep,perm) + 
//					  e.yyx*permutohedronDist( pos + e.yyx*ep,perm) + 
//					  e.yxy*permutohedronDist( pos + e.yxy*ep,perm) + 
//					  e.xxx*permutohedronDist( pos + e.xxx*ep,perm);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//    
//
//
//
//float permutohedronSDF(Vector tv, Permutohedron perm, inout localData dat){
//    
//    
//    float d= permutohedronDist(tv.pos.coords,perm);
//    
//    //-----------------
//    
//    if(d<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=permutohedronNormal(tv,perm);
//        dat.mat=perm.mat;
//    }
//    
//    return d;
//    
//}
//
//
//
//
//
//
//
//
//
//
////-------------------------------------------------
//// The ROUNDED CYLINDER sdf
////-------------------------------------------------
//
//struct Cylinder{
//    vec3 center;
//    float radius;
//    float height;
//    float rounded;
//    Material mat;
//    Isometry isom;
//};
//
//float sdCylinder( vec3 p, float radius, float height, float rounded)
//{
//  vec2 d = vec2( length(p.xz)-2.0*radius+rounded, abs(p.y) - height );
//  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rounded;
//}
//
//
//float cylinderDist( vec3 p, Cylinder cyl )
//{
//    
//   return  cylinderDistance(p,cyl.radius,cyl.height,cyl.rounded);
////    
////    p=p-cyl.center;
////  vec2 d = vec2( length(p.xz)-2.0*cyl.radius+cyl.rounded, abs(p.y) - cyl.height );
////  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - cyl.rounded;
//}
//
//
//
//
//
////probably a way to do this directly and not sample....
//Vector cylinderNormal(Vector tv, Cylinder cyl){
//    //vec3 pos=tv.pos.coords;
//    
//    return cylinderNormal(tv,cyl.radius,cyl.height,cyl.rounded);
//    
////    const float ep = 0.0001;
////    vec2 e = vec2(1.0,-1.0)*0.5773;
////    
////    vec3 dir=  e.xyy*cylinderDist( pos + e.xyy*ep,cyl) + 
////					  e.yyx*cylinderDist( pos + e.yyx*ep,cyl) + 
////					  e.yxy*cylinderDist( pos + e.yxy*ep,cyl) + 
////					  e.xxx*cylinderDist( pos + e.xxx*ep,cyl);
////    
////    dir=normalize(dir);
////    
////    return Vector(tv.pos,dir);
//}
//    
//
//
//
//float cylinderSDF(Vector tv, Cylinder cyl, inout localData dat){
//    
//    
//    float d= cylinderDistance(tv.pos.coords,cyl.radius,cyl.height,cyl.rounded);
//    
//    //-----------------
//    
//    if(d<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=cylinderNormal(tv,cyl.radius,cyl.height,cyl.rounded);
//        dat.mat=cyl.mat;
//    }
//    
//    return d;
//    
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////-------------------------------------------------
//// The CAPPED CONE
////-------------------------------------------------
//float dot2(vec2 p){
//    return dot(p,p);
//}
//
////the thing to use in other implementations:
//
//float sdCappedCone( vec3 p, float h, float r1, float r2 )
//{
//  vec2 q = vec2( length(p.xz), p.y );
//  vec2 k1 = vec2(r2,h);
//  vec2 k2 = vec2(r2-r1,2.0*h);
//  vec2 ca = vec2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
//  vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
//  float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
//  return s*sqrt( min(dot2(ca),dot2(cb)) );
//}
//
//
//struct CappedCone{
//    float height;
//    float rBase;
//    float rTop;
//    vec3 center;
//    Material mat;
//    
//};
//
//
//float cappedConeDist(vec3 p, CappedCone cone){
//    
//    vec3 q=p-cone.center;
//    
//    return sdCappedCone(q,cone.height,cone.rTop,cone.rBase);
//    
//}
//
//
//
//Vector cappedConeNormal(Vector tv, CappedCone cone){
//    
//    vec3 pos=tv.pos.coords-cone.center;
//    cone.center=vec3(0.);
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*cappedConeDist( pos + e.xyy*ep,cone) + 
//					  e.yyx*cappedConeDist( pos + e.yyx*ep,cone) + 
//					  e.yxy*cappedConeDist( pos + e.yxy*ep,cone) + 
//					  e.xxx*cappedConeDist( pos + e.xxx*ep,cone);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//   
//
//
//void cappedConeData(inout Path path, inout localData dat, float dist,CappedCone cone){
//    
//    //set the material
//    dat.isSky=false;
//    dat.mat=cone.mat;
//
//    
//    if(dist<0.){
//        path.inside=true;
//        //normal is inwward pointing;
//        dat.normal=negate(cappedConeNormal(path.tv,cone));
//        //IOR is current/enteing
//        dat.IOR=cone.mat.IOR/1.;
//        
//        dat.reflectAbsorb=cone.mat.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//    }
//    
//    else{
//        path.inside=false;
//        //normal is inwward pointing;
//        dat.normal=cappedConeNormal(path.tv,cone);
//        //IOR is current/enteing
//        dat.IOR=1./cone.mat.IOR;
//        
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=cone.mat.absorbColor;
//        
//    }
//    
//    
//    
//}
//
//
////------sdf
//float cappedConeSDF(inout Path path, CappedCone cone,inout localData dat){
//    
//    //float side=(path.inside)?-1.:1.;
//    
//    //distance to closest point:
//    float dist = cappedConeDist(path.tv.pos.coords,cone);
//    
//    if(abs(dist)<EPSILON){//set the material
//        cappedConeData(path,dat,dist,cone);
//    }
//
//    return dist;
//}
//
//
