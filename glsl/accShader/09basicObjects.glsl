
//-------------------------------------------------
//COMMON STUFF
//-------------------------------------------------



//if you hit an object which is not part of a compound, one side is the object (material) and the other side is air
//set your local data appropriately
void setObjectInAir(inout localData dat, float dist, Vector normal, Material mat){
    
    //set the material
    dat.isSky=false;
    dat.mat=mat;

     if(dist<0.){
        //normal is inwward pointing;
        dat.normal=negate(normal);
        //IOR is current/enteing
        dat.IOR=mat.IOR/1.;
        
        dat.reflectAbsorb=mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
    }
    
    else{
        //normal is outward pointing;
        dat.normal=normal;
        //IOR is current/enteing
        dat.IOR=1./mat.IOR;
        
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=mat.absorbColor;
        
    }
    
}

























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


//------sdf
float sphereSDF(Vector tv, Sphere sph,inout localData dat){
    
    //distance to closest point:
    float dist = sphereDistance(tv,sph);
    
    if(abs(dist)<EPSILON){
        
        //compute the normal
        Vector normal=sphereNormal(tv,sph);
        
        //set the material
        setObjectInAir(dat,dist,normal,sph.mat);
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


float planeSDF(Vector tv, Plane plane, inout localData dat){

    float dist=planeDistance(tv,plane);
    
    if(abs(dist)<EPSILON){
        
        //compute the normal
        Vector normal=planeNormal(tv,plane);
        
        //set the material
        setObjectInAir(dat,dist,normal,plane.mat);
    }
    
    return dist;
    
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



//------sdf
float cylinderSDF(Vector tv, Cylinder cyl,inout localData dat){
    
    //distance to closest point:
    float dist = cylinderDistance(tv,cyl);
    
    if(abs(dist)<EPSILON){
        
        //compute the normal
        Vector normal=cylinderNormal(tv,cyl);
        
        //set the material
        setObjectInAir(dat,dist,normal,cyl.mat);
    }

    return dist;
}



//
////------sdf
//float twistySDF(Vector tv, Cylinder cyl,inout localData dat){
//    
//    //distance to closest point:
//    float dist = twistyDist(tv,cyl);
//    
//    if(abs(dist)<EPSILON){
//        
//        //compute the normal
//        vec3 dir=twistyNormal(tv,cyl);
//        
//        //set the material
//        setObjectInAir(dat,dist,normal,cyl.mat);
//    }
//
//    return dist;
//}
//
//









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
    float rounded;
    float smoothJoin;
    float bump;
    Material mat;
};



//----distance and normal functions

float bottleDistance(vec3 p, Bottle bottle,out float insideBottle ){
    
    vec3 pos=p-bottle.center.coords;
    
    //the base of the bottle
    float base=cylinderDist(pos,bottle.baseRadius, bottle.baseHeight,bottle.rounded);
    
    //the neck of the bottle
    //first: adjust the height
    vec3 q=pos-vec3(0,bottle.baseHeight+bottle.neckHeight,0);
    
    float neck=cylinderDist(q,bottle.neckRadius,bottle.neckHeight,bottle.rounded);
    
    //give the subtraction of these:
    float theBottle=opMinDist(base, neck,bottle.smoothJoin);
    
    if(bottle.bump!=0.){
        vec3 r=pos+vec3(0,bottle.baseHeight,0.);
        float bump=length(r)-0.25;
        theBottle=opMaxDist(theBottle,-bump,1.);
    }
    
    insideBottle=theBottle+bottle.thickness;

    //make the shell
    theBottle=opOnionDist(theBottle,bottle.thickness);
    
    //chop off the top:
    float top=q.y-bottle.neckHeight/3.;
    
    theBottle=opMaxDist(theBottle,top,bottle.thickness);
    
    return theBottle;

}

float bottleDistance(vec3 pos, Bottle bottle){
    return bottleDistance(pos,bottle,trashFloat);
}


//
//
//Vector bottleNormal(Vector tv, Bottle bottle){
//    
//    //if this ever becomes more expensive than four calls of the sdf: stop!
//    
//    vec3 pos=tv.pos.coords-bottle.center.coords;
//    
//    //the base of the bottle
//    float base=cylinderDist(pos,bottle.baseRadius, bottle.baseHeight,bottle.rounded);
//    
//    vec3 baseVec=cylinderGrad(pos,bottle.baseRadius, bottle.baseHeight,bottle.rounded);
//    
//    //the neck of the bottle
//    //first: adjust the height
//    vec3 q=pos-vec3(0,bottle.baseHeight+bottle.neckHeight,0);
//    
//    float neck=cylinderDist(q,bottle.neckRadius,bottle.neckHeight,bottle.rounded);
//    
//    vec3 neckVec=cylinderGrad(q,bottle.neckRadius,bottle.neckHeight,bottle.rounded);
//    
//    float dist=opMinDist(base,neck,bottle.smoothJoin);
//    
//    vec3 dir=opMinVec(base,baseVec,neck,neckVec,bottle.smoothJoin);
//    
//        
//    if(bottle.bump!=0.){
//        vec3 r=pos+vec3(0,bottle.baseHeight,0.);
//        float bump=length(r)-0.25;
//        dir=opMaxVec(dist,dir,-bump,-r,1.);
//    }
//    
//    
//    //hollow out the shell
//    dir=opOnionVec(dist,dir);
//    
//    //chop off the top:
//    float top=q.y-bottle.neckHeight/3.;
//    
//    dir=opMaxVec(dist,dir,top,vec3(0,1,0),bottle.smoothJoin);
//    
//    return Vector(tv.pos,normalize(dir));
//    
//}

//the default option: 4 calls of SDF
Vector bottleNormal(Vector tv, Bottle bottle){
    
    vec3 pos=tv.pos.coords;
    
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




//------sdf
float bottleSDF(Vector tv, Bottle bottle,inout localData dat){

    float dist = bottleDistance(tv.pos.coords,bottle);
    
    
    if(abs(dist)<EPSILON){
        
        //compute the normal
        Vector normal=bottleNormal(tv,bottle);
        
        //set the material
        setObjectInAir(dat,dist,normal,bottle.mat);
    }


    return dist;
}







//-------------------------------------------------
//The COCKTAIL GLASS sdf
//-------------------------------------------------


//the distance function here will be used again in future functions, where knowing "inside" will be helpful.
//thus the first distance function has an inout telling you if you are inside the glass

struct CocktailGlass{
   Point center;
    float radius;
    float height;
    float thickness;
    float base;
    Material mat;
};


float cocktailGlassDistance(vec3 p, CocktailGlass glass,inout float insideDist){
    
    vec3 pos=p-glass.center.coords;
    
    float outside=cylinderDist(pos,glass.radius,glass.height,0.1);
    
    //the height is the "half height" of the glass....
    vec3 q=pos-vec3(0,2.*glass.base,0);

    float inside=cylinderDist(q,glass.radius-glass.thickness,glass.height,0.05);
    
    //insideTheGlass=(inside<0.)?true:false;
    
    //the glass
    float dist= max(outside,-inside);
    
    //now subtract ball from bottom
    q=pos+vec3(0,glass.height-1.75*glass.base/2.5,0.);
    float ball=length(q)-2.*glass.base/2.5;
    
    insideDist=inside;
    return smax(dist,-ball,0.2);
}


//overload not worrying about if we are inside the glass
float cocktailGlassDistance(vec3 p, CocktailGlass glass){
    return cocktailGlassDistance(p,glass,trashFloat);
}


float cocktailGlassDistance(Vector tv,CocktailGlass glass){
    return cocktailGlassDistance(tv.pos.coords,glass);
}


//
////NEED TO FIX
//Vector cocktailGlassNormal(Vector tv, CocktailGlass glass){
//    
//     vec3 pos=tv.pos.coords-glass.center.coords;
//    
//    float outside=cylinderDist(pos,glass.radius,glass.height,0.2);
//    
//    vec3 q=pos-glass.base;
//    
//    float inside=cylinderDist(q,glass.radius-glass.thickness,glass.height,0.2);
//    
//    vec3 normal;
//    if(outside>-inside){
//        //give normal vector for outside
//        normal=cylinderGrad(pos,glass.radius,glass.height,0.2);
//    }
//    else{
//        //give normal vector for -inside
//        normal=-cylinderGrad(q,glass.radius-glass.thickness,glass.height,0.2);
//    }
//
//    return Vector(tv.pos,normal);
//}


Vector cocktailGlassNormal(Vector tv, CocktailGlass glass){
    
    vec3 pos=tv.pos.coords;
    
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    
    float vxyy=cocktailGlassDistance( pos + e.xyy*ep,glass);
    float vyyx=cocktailGlassDistance( pos + e.yyx*ep,glass);
    float vyxy=cocktailGlassDistance( pos + e.yxy*ep,glass);
    float vxxx=cocktailGlassDistance( pos + e.xxx*ep,glass);
    
    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;
    
    dir=normalize(dir);
    
    return Vector(tv.pos,dir);
    
}





//------sdf
float cocktailGlassSDF(Vector tv, CocktailGlass glass,inout localData dat){

    float dist = cocktailGlassDistance(tv,glass);
    
    
    if(abs(dist)<EPSILON){
        
        //compute the normal
        Vector normal=cocktailGlassNormal(tv,glass);
        
        //set the material
        setObjectInAir(dat,dist,normal,glass.mat);
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

struct Ring{
    Isometry isom;
    Point center;
    float radius;
    float tubeRad;
    float stretch;
    Material mat;
};

//----distance and normal functions

float ringDistance(Vector tv, Ring ring){
    tv.pos.coords-=ring.center.coords;
    return ringDist(tv.pos.coords,ring.radius,ring.tubeRad,ring.stretch);
}

Vector ringNormal(Vector tv, Ring ring){
    tv.pos.coords-=ring.center.coords;
    vec3 dir=ringGrad(tv.pos.coords,ring.radius,ring.tubeRad,ring.stretch);
    return Vector(tv.pos,dir);
}


//------sdf
float ringSDF(Vector tv, Ring ring,inout localData dat){

    //distance to closest point:
    float dist = ringDistance(tv,ring);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=ringNormal(tv,ring);

        //set the material
        setObjectInAir(dat,dist,normal,ring.mat);
    }

    return dist;
}







////-------------------------------------------------
//// The PRISM sdf
////-------------------------------------------------
//
//
////the data of a prism with eqilateral triangle cross section is given by its center, its length and width
struct Prism{
    Isometry isom;
    Point center;
    float length;
    float width;
    Material mat;
};

//----distance and normal functions

float prismDistance(Vector tv, Prism prism){
    tv.pos.coords-=prism.center.coords;
    return prismDist(tv.pos.coords,prism.length,prism.width);
}

Vector prismNormal(Vector tv, Prism prism){
    tv.pos.coords-=prism.center.coords;
    vec3 dir=prismGrad(tv.pos.coords,prism.length, prism.width);
    return Vector(tv.pos,dir);
}


//------sdf
float prismSDF(Vector tv, Prism prism,inout localData dat){

    //distance to closest point:
    float dist = prismDistance(tv,prism);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=prismNormal(tv,prism);

        //set the material
        setObjectInAir(dat,dist,normal,prism.mat);
    }

    return dist;
}










////-------------------------------------------------
//// The OCTAHEDRON sdf
////-------------------------------------------------
//
//
////the data of a prism with eqilateral triangle cross section is given by its center, its length and width
struct Octahedron{
    Isometry isom;
    Point center;
    float side;
    Material mat;
};

//----distance and normal functions

float octahedronDistance(Vector tv, Octahedron oct){
    tv.pos.coords-=oct.center.coords;
    return octahedronDist(tv.pos.coords,oct.side);
}

Vector octahedronNormal(Vector tv, Octahedron oct){
    tv.pos.coords-=oct.center.coords;
    vec3 dir=octahedronGrad(tv.pos.coords,oct.side);
    return Vector(tv.pos,dir);
}


//------sdf
float octahedronSDF(Vector tv, Octahedron oct,inout localData dat){

    //distance to closest point:
    float dist = octahedronDistance(tv,oct);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=octahedronNormal(tv,oct);

        //set the material
        setObjectInAir(dat,dist,normal,oct.mat);
    }

    return dist;
}





////-------------------------------------------------
//// The LENS sdf
////-------------------------------------------------
//
//
struct Lens{
    Isometry isom;
    float radius;
    float thickness;
    Point center;
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
    lens.center.coords=center;
    lens.axis=normalize(axis);

    //compute auxillary quantities
    float R=(r*r+d*d)/(2.*d);
    vec3 c1=center+(R-d)*axis;
    vec3 c2=center-(R-d)*axis;

    lens.R=R;
    lens.c1=Point(c1);
    lens.c2=Point(c2);
}




//----distance and normal functions

float lensDistance(Vector tv, Lens lens){
    tv.pos.coords-=lens.center.coords;
    return lensDist(tv.pos.coords,lens.c1.coords,lens.c2.coords,lens.R);
}

Vector lensNormal(Vector tv, Lens lens){
    tv.pos.coords-=lens.center.coords;
    vec3 dir=lensGrad(tv.pos.coords,lens.c1.coords,lens.c2.coords,lens.R);
    return Vector(tv.pos,dir);
}


//------sdf
float lensSDF(Vector tv, Lens lens,inout localData dat){

    //distance to closest point:
    float dist = lensDistance(tv,lens);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=lensNormal(tv,lens);

        //set the material
        setObjectInAir(dat,dist,normal,lens.mat);
    }

    return dist;
}




//-------------------------------------------------
//The STANFORD BUNNY sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Bunny{
    Point center;
    float size;
    Material mat;
};

//----distance and normal functions

float bunnyDistance(Vector tv, Bunny bunny){
    tv.pos.coords-=bunny.center.coords;
    return bunnyDist(tv.pos.coords,bunny.size);
}

Vector bunnyNormal(Vector tv, Bunny bunny){
    tv.pos.coords-=bunny.center.coords;
    vec3 dir=bunnyGrad(tv.pos.coords,bunny.size);
    return Vector(tv.pos,dir);
}


//------sdf
float bunnySDF(Vector tv, Bunny bunny,inout localData dat){

    //distance to closest point:
    float dist = bunnyDistance(tv,bunny);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=bunnyNormal(tv,bunny);

        //set the material
        setObjectInAir(dat,dist,normal,bunny.mat);
    }

    return dist;
}



















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
