//
//
////-------------------------------------------------
//// The LENS sdf
////-------------------------------------------------
//
////the data of a lens is determined by its radius, thickness
////position/orientation by its center, axis
////from these we compute auxilary quantities: sphere rad and 2 centers
//
//struct Lens{
//    float radius;
//    float thickness;
//    vec3 center;
//    vec3 axis;
//    Material mat;
//    float R;
//    Point c1;
//    Point c2;
//};
//
//
//
//void setLens(inout Lens lens, float r,float d, vec3 center, vec3 axis){
//    //compute sphere radius:
//    
//    lens.radius=r;
//    lens.thickness=d;
//    lens.center=center;
//    lens.axis=normalize(axis);
//    
//    //compute auxillary quantities
//    float R=(r*r+d*d)/(2.*d);
//    vec3 c1=center+(R-d)*axis;
//    vec3 c2=center-(R-d)*axis;
//    
//    lens.R=R;
//    lens.c1=Point(c1);
//    lens.c2=Point(c2);
//}
//
//
//
//
//float lensDist(vec3 pos,Lens lens){
//    
//
//    float dist1=sphDist(pos,Sphere(lens.c1,lens.R,lens.mat));
//    float dist2=sphDist(pos,Sphere(lens.c2,lens.R,lens.mat));
//    
//    return max(dist1,dist2);
//}
//
//
//
//Vector lensNormal(Vector tv,Lens lens){
//    
//    Sphere sph1=Sphere(lens.c1,lens.R,lens.mat);
//    Sphere sph2=Sphere(lens.c2,lens.R,lens.mat);
//    
//    float s1=abs(sphDist(tv.pos.coords,sph1));
//    float s2=abs(sphDist(tv.pos.coords,sph2));
//    
//    if(s1<s2){//closer to surface of s1 than s2
//        return sphereNormal(tv,sph1);
//    }
//    return sphereNormal(tv,sph2);
//
//}
//
//
//
//
//
//float lensSDF(Vector tv, Lens lens, inout localData dat){
//    
//    
//    float d= lensDist(tv.pos.coords,lens);
//    
//    //-----------------
//    
//    if(d<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=lensNormal(tv,lens);
//        dat.mat=lens.mat;
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
//
//
//
////-------------------------------------------------
//// The COCKTAIL sdf
////-------------------------------------------------
//
//struct Cocktail{
//vec3 center;
//float radius;
//float height;
//float rounded;
//float base;
//Material mat;
//};
//
//
//
////useful sdf
//float sdRoundedCylinder( vec3 p, float ra, float rb, float h )
//{
//  vec2 d = vec2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
//  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
//}
//
//
//float cocktailDist( vec3 p, Cocktail glass)
//{
//    vec3 q1=p-glass.center+vec3(0,glass.base,0);;
//    vec3 q2=p-glass.center;
//    
//    float outer=sdRoundedCylinder(q1,glass.radius+0.15,glass.rounded,glass.height);
//    
//   float inner=sdRoundedCylinder(q2,glass.radius,glass.rounded,glass.height);
//    
//    
//    float heightAdjust=glass.height+0.66*glass.base;
//    vec3 ballCenter=glass.center-vec3(0.,heightAdjust,0.);
//    float ball=length(p-ballCenter)-glass.base/2.;
//    
//    float dist=smax(outer,-ball,0.2);
//    return max(dist,-inner);
//    
//}
//
//
//
//
////probably a way to do this directly and not sample....
//Vector cocktailNormal(Vector tv, Cocktail glass){
//    vec3 pos=tv.pos.coords;
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*cocktailDist( pos + e.xyy*ep,glass) + 
//					  e.yyx*cocktailDist( pos + e.yyx*ep,glass) + 
//					  e.yxy*cocktailDist( pos + e.yxy*ep,glass) + 
//					  e.xxx*cocktailDist( pos + e.xxx*ep,glass);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//    
//
//
//
//float cocktailSDF(Path path, Cocktail glass, inout localData dat){
//    
//    
//    float d= cocktailDist(path.tv.pos.coords,glass);
//    
//    //-----------------
//    
//    if(d<EPSILON){//set the material
//        dat.isSky=false;
//        dat.normal=cocktailNormal(path.tv,glass);
//        dat.mat=glass.mat;
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
//
//
//
//
//
////-------------------------------------------------
//// The NEGRONI sdf
////-------------------------------------------------
//
//struct Negroni{
//vec3 center;
//float radius;
//float height;
//float thickness;
//float base;
//Material cup;
//Material drink;
//};
//
//
//
//
//float  cupDist( vec3 p, Negroni negroni)
//{
//    
//    Cylinder outside;
//    Cylinder inside;
//
//    outside.center=negroni.center;
//    outside.radius=negroni.radius;
//    outside.height=negroni.height;
//    outside.rounded=0.1;
//
//    inside.center=negroni.center+vec3(0,2.*negroni.base,0);
//    inside.radius=negroni.radius-negroni.thickness;
//    inside.height=negroni.height;
//    inside.rounded=0.;
//
//    float outsideGlass=cylinderDist(p,outside);
//    float insideGlass=cylinderDist(p,inside);
//    
//    return max(outsideGlass,-insideGlass);
//}
//
//
//Vector cupNormal(Vector tv,Negroni negroni){
//    
//    vec3 pos=tv.pos.coords;
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*cupDist( pos + e.xyy*ep,negroni) + 
//					  e.yyx*cupDist( pos + e.yyx*ep,negroni) + 
//					  e.yxy*cupDist( pos + e.yxy*ep,negroni) + 
//					  e.xxx*cupDist( pos + e.xxx*ep,negroni);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//    
//}
//
//
//float drinkDist(vec3 p, Negroni negroni){
//    
//    Cylinder inside;
//    
//    inside.center=negroni.center+vec3(0,2.*negroni.base,0);
//    inside.radius=negroni.radius-negroni.thickness;
//    inside.height=negroni.height;
//    inside.rounded=0.;
//    
//    float fullDrink=cylinderDist(p,inside);
//    
//    //get the top of the drink:
//    float drinkHeight=negroni.center.y;
//    
//    //sdf for the half space determined by drink:
//    float topDist=p.y-drinkHeight;
//    
//    return max(fullDrink,topDist);
//}
//
//
//Vector drinkNormal(Vector tv,Negroni negroni){
//    
//    vec3 pos=tv.pos.coords;
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*drinkDist( pos + e.xyy*ep,negroni) + 
//					  e.yyx*drinkDist( pos + e.yyx*ep,negroni) + 
//					  e.yxy*drinkDist( pos + e.yxy*ep,negroni) + 
//					  e.xxx*drinkDist( pos + e.xxx*ep,negroni);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//    
//}
//
//
//
//
//void setNegroniData(float cup, float drink, Negroni negroni,inout Path path, inout localData dat){
//    
//    
//
//        //for now, only deal with the cup
//    
//    
//    //first, if we are far from the drink
//    if(drink>EPSILON){
//        
//    //if we are inside the cup away from liquid
//    if(cup<0.){
//        dat.mat=negroni.cup;
//        path.inside=true;
//        dat.normal=negate(cupNormal(path.tv,negroni)); 
//        dat.IOR=negroni.cup.IOR/1.;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=negroni.cup.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//        
//    }
//    
//    //if we are outside the cup away from liquid
//    else{
//        dat.mat=negroni.cup;
//        path.inside=false;
//        dat.normal=cupNormal(path.tv,negroni); 
//        dat.IOR=1./negroni.cup.IOR;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=negroni.cup.absorbColor;
//        
//    }
//}
//
//else if(cup>EPSILON){
//    //automatically drink<epsilon here in this case, so this means we must be near the drink and not the cup:
//    
//
//    if(drink<0.){//inside drink
//        dat.mat=negroni.drink;
//        path.inside=true;
//        dat.normal=negate(drinkNormal(path.tv,negroni)); 
//        dat.IOR=negroni.drink.IOR/1.;
//        dat.materialInterface=false; 
//        dat.reflectAbsorb=negroni.drink.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//    }
//    
//    else{//outside drink
//        dat.mat=negroni.drink;
//        path.inside=false;
//        dat.normal=drinkNormal(path.tv,negroni); 
//        dat.IOR=1./negroni.drink.IOR;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=negroni.drink.absorbColor;
//        
//    }
//    
//}
//
//
//else{
//    //drink< epsilon and cup<epsilon: so we are near both
//    
//    if(cup<0.){
//        //inside cup near drink
//        dat.mat=negroni.cup;
//        path.inside=true;
//        dat.normal=negate(cupNormal(path.tv,negroni)); 
//        dat.IOR=negroni.cup.IOR/negroni.drink.IOR;
//        dat.materialInterface=true;
//        dat.reflectAbsorb=negroni.cup.absorbColor;
//        dat.refractAbsorb=negroni.drink.absorbColor;
//        
//    }
//    
//    else{
//        //inside drink near cup
//        dat.mat=negroni.drink;
//        path.inside=true;
//        dat.normal=negate(drinkNormal(path.tv,negroni)); 
//        dat.IOR=negroni.drink.IOR/negroni.cup.IOR;
//        dat.materialInterface=true;
//        dat.reflectAbsorb=negroni.drink.absorbColor;
//        dat.refractAbsorb=negroni.cup.absorbColor;
//    }
//    
//}
//    
//    
////    
////    
////    //near cup away from drink
////  if(abs(cup)<EPSILON &&abs(drink)>2.*EPSILON){
////        dat.isSky=false;
////        dat.normal=cupNormal(path.tv,negroni);
////        dat.mat=negroni.cup;
////        dat.materialInterface=false;
////        //no change to IOR
////      dat.mat.IOR=(cup<0.)?1./dat.mat.IOR:dat.mat.IOR;
////  }
////    
////  //near drink away from cup
//// if(abs(drink)<EPSILON&&abs(cup)>2.*EPSILON){
////        dat.isSky=false;
////        dat.normal=drinkNormal(path.tv,negroni);
////        dat.mat=negroni.drink;
////        dat.materialInterface=false;
////             //no change to IOR
////      dat.mat.IOR=(drink<0.)?1./dat.mat.IOR:dat.mat.IOR;
////    }
////    
////        
////    //if we are inside the cup's glass and near the drink
//// if(cup<0.&& abs(drink)<EPSILON){
////        dat.isSky=false;
////        //the drink's normal is inward pointing at glass
////        dat.normal=negate(cupNormal(path.tv,negroni));
////        dat.mat=negroni.cup;
////        //change in IOR
////        dat.mat.IOR=1.;
////        // negroni.cup.IOR/negroni.drink.IOR;
////        dat.materialInterface=true;
////    }
////    
////        
//////if we are inside the drink near the glass
////if(drink<0.&& abs(cup)<EPSILON){
////        dat.isSky=false;
////        //the cups normal is inward pointing for drink
////        dat.normal=negate(drinkNormal(path.tv,negroni));
////        dat.mat=negroni.drink;
////        //change in IOR
////        dat.mat.IOR=1.;
////        //negroni.drink.IOR/negroni.cup.IOR;
////        dat.materialInterface=true;
////    }
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
//float negroniSDF(inout Path path,Negroni negroni, inout localData dat){
//    
//    float cup=cupDist(path.tv.pos.coords,negroni);
//    float drink=drinkDist(path.tv.pos.coords, negroni);
//    
//    float d=min(abs(cup),abs(drink));
//    //float d=abs(cup);
//    
//    if(d<EPSILON){
//        //this means we are near somehing!
//        setNegroniData(cup,drink,negroni,path,dat);
//    }
//    
//   // return cup;
//    return min(cup,drink);     
//    
//}
//
//
//
//
//
////-------------------------------------------------
//// The CONECUP sdf
////-------------------------------------------------
//
//
//struct ConeCup{
//    float height;
//    float rBase;
//    float rTop;
//    vec3 center;
//    float thickness;
//    Material mat;
//};
//
//
//float coneCupDist(vec3 p, ConeCup cup){
//    
//    
//    vec3 q=p-cup.center;
//    
//    float outside=sdCappedCone(q,cup.height,cup.rTop,cup.rBase);
//    
//    //move up to make base thickness;
//    q+=vec3(0,cup.thickness,0);
//    
//    float inside=sdCappedCone(q,cup.height,cup.rTop,cup.rBase);
//    
//    //give the subtraction of these:
//    return max(outside,-inside)+0.1;
//}
//
//Vector coneCupNormal(Vector tv, ConeCup cup){
//    
//    vec3 pos=tv.pos.coords;
//    //-cup.center;
//   // cup.center=vec3(0.);
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*coneCupDist( pos + e.xyy*ep,cup) + 
//					  e.yyx*coneCupDist( pos + e.yyx*ep,cup) + 
//					  e.yxy*coneCupDist( pos + e.yxy*ep,cup) + 
//					  e.xxx*coneCupDist( pos + e.xxx*ep,cup);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//   
//
//void coneCupData(inout Path path, inout localData dat, float dist,ConeCup cup){
//    
//    //set the material
//    dat.isSky=false;
//    dat.mat=cup.mat;
//
//    
//    if(dist<0.){
//        path.inside=true;
//        //normal is inwward pointing;
//        dat.normal=negate(coneCupNormal(path.tv,cup));
//        //IOR is current/enteing
//        dat.IOR=cup.mat.IOR/1.;
//        
//        dat.reflectAbsorb=cup.mat.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//    }
//    
//
//  else{
//        path.inside=false;
//        //normal is inwward pointing;
//        dat.normal=coneCupNormal(path.tv,cup);
//        //IOR is current/enteing
//        dat.IOR=1./cup.mat.IOR;
//        
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=cup.mat.absorbColor;
//        
//    }
//    
//}
//
//
//
//
//
////------sdf
//float coneCupSDF(inout Path path, ConeCup cup,inout localData dat){
//    
//    //float side=(path.inside)?-1.:1.;
//    
//    //distance to closest point:
//    float dist = coneCupDist(path.tv.pos.coords,cup);
//    
//    if(abs(dist)<EPSILON){//set the material
//        coneCupData(path,dat,dist,cup);
//    }
//
//    return dist;
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
//// The BOTTLE sdf
////-------------------------------------------------
//
//
//struct Bottle{
//    float mainHeight;
//    float mainRadius;
//    float neckHeight;
//    float neckRadius;
//    float thickness;
//    vec3 center;
//    Material mat;
//};
//
//
//float bottleDist(vec3 p, Bottle bottle){
//    
//    
//    vec3 q=p-bottle.center;
//    
//    //main body
//    float body=sdCylinder(q,bottle.mainRadius,bottle.mainHeight,0.5);
//    
//    //neck
//    //first: adjust the height
//    q=q-vec3(0,bottle.mainHeight+bottle.neckHeight,0);
//    
//    float neck=sdCylinder(q,bottle.neckRadius,bottle.neckHeight,0.5);
//    
//    
//    //give the subtraction of these:
//    float theBottle=smin(body, neck,1.);
//    
//    //chop off the top:
//    float top=q.y-bottle.neckHeight;
//    
//    theBottle=max(theBottle,top);
//    
//    return abs(theBottle)-bottle.thickness;
//}
//
//Vector bottleNormal(Vector tv, Bottle bottle){
//    
//    vec3 pos=tv.pos.coords;
//    //-cup.center;
//   // cup.center=vec3(0.);
//    
//    const float ep = 0.0001;
//    vec2 e = vec2(1.0,-1.0)*0.5773;
//    
//    vec3 dir=  e.xyy*bottleDist( pos + e.xyy*ep,bottle) + 
//					  e.yyx*bottleDist( pos + e.yyx*ep,bottle) + 
//					  e.yxy*bottleDist( pos + e.yxy*ep,bottle) + 
//					  e.xxx*bottleDist( pos + e.xxx*ep,bottle);
//    
//    dir=normalize(dir);
//    
//    return Vector(tv.pos,dir);
//}
//   
//
//void bottleData(inout Path path, inout localData dat, float bottleDistance, float capDistance,Bottle bottle){
//    
//    //set the material
//    dat.isSky=false;
//    dat.mat=bottle.mat;
//
//    
//    if(abs(capDistance)<EPSILON){
//    
//    }
//    
//    
//    else if(bottleDistance<0.){
//        path.inside=true;
//        //normal is inwward pointing;
//        dat.normal=negate(bottleNormal(path.tv,bottle));
//        //IOR is current/enteing
//        dat.IOR=bottle.mat.IOR/1.;
//        
//        dat.reflectAbsorb=bottle.mat.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//    }
//    
//
//  else{
//        path.inside=false;
//        //normal is inwward pointing;
//        dat.normal=bottleNormal(path.tv,bottle);
//        //IOR is current/enteing
//        dat.IOR=1./bottle.mat.IOR;
//        
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=bottle.mat.absorbColor;
//        
//    }
//    
//}
//
//
//
//
//
////------sdf
//float bottleSDF(inout Path path,Bottle bottle,inout localData dat){
//    
//    
//    //distance to closest point:
//    float bottleDistance = bottleDist(path.tv.pos.coords,bottle);
//    
//    //distance to cap
//    float capDistance=100.;
//    
//    float dist=min(bottleDistance, capDistance);
//    
//    if(abs(dist)<EPSILON){//set the material
//        bottleData(path,dat,bottleDistance,capDistance,bottle);
//    }
//
//    return dist;
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
//
//
////-------------------------------------------------
//// The FULL BOTTLE SDF
////-------------------------------------------------
//
//
//struct FullBottle{
//    Bottle bottle;
//    Material drink;
//    float fill;
//};
//
//
//
//void fullBottleData(inout Path path, inout localData dat, float bottle, float drink,FullBottle theBottle, Cylinder theDrink){
//    
//    
//    
//        
//    //first, if we are far from the drink
//    if(drink>EPSILON){
//        
//    //if we are inside the cup away from liquid
//    if(bottle<0.){
//        dat.mat=theBottle.bottle.mat;
//        path.inside=true;
//        dat.normal=negate(bottleNormal(path.tv,theBottle.bottle)); 
//        dat.IOR=theBottle.bottle.mat.IOR/1.;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=theBottle.bottle.mat.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//        
//    }
//    
//    //if we are outside the cup away from liquid
//    else{
//        dat.mat=theBottle.bottle.mat;
//        path.inside=false;
//        dat.normal=bottleNormal(path.tv,theBottle.bottle); 
//        dat.IOR=1./theBottle.bottle.mat.IOR;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=theBottle.bottle.mat.absorbColor;
//        
//    }
//}
//
//else if(bottle>EPSILON){
//    //automatically drink<epsilon here in this case, so this means we must be near the drink and not the cup:
//    
//
//    if(drink<0.){//inside drink
//        dat.mat=theBottle.drink;
//        path.inside=true;
//        dat.normal=negate(cylinderNormal(path.tv,theDrink)); 
//        dat.IOR=theBottle.drink.IOR/1.;
//        dat.materialInterface=false; 
//        dat.reflectAbsorb=theBottle.drink.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//    }
//    
//    else{//outside drink
//        dat.mat=theBottle.drink;
//        path.inside=false;
//        dat.normal=cylinderNormal(path.tv,theDrink); 
//        dat.IOR=1./theBottle.drink.IOR;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=theBottle.drink.absorbColor;
//        
//    }
//    
//}
//
//
//else{
//    //drink< epsilon and cup<epsilon: so we are near both
//    
//    if(bottle<0.){
//        //inside cup near drink
//        dat.mat=theBottle.bottle.mat;
//        path.inside=true;
//        dat.normal=negate(bottleNormal(path.tv,theBottle.bottle)); 
//        dat.IOR=theBottle.bottle.mat.IOR/theBottle.drink.IOR;
//        dat.materialInterface=true;
//        dat.reflectAbsorb=theBottle.bottle.mat.absorbColor;
//        dat.refractAbsorb=theBottle.drink.absorbColor;
//        
//    }
//    
//    else{
//        //inside drink near cup
//        dat.mat=theBottle.drink;
//        path.inside=true;
//        dat.normal=negate(cylinderNormal(path.tv,theDrink)); 
//        dat.IOR=theBottle.drink.IOR/theBottle.bottle.mat.IOR;
//        dat.materialInterface=true;
//        dat.reflectAbsorb=theBottle.drink.absorbColor;
//        dat.refractAbsorb=theBottle.bottle.mat.absorbColor;
//    }
//    
//    
//    
//    
//    
//}
//
//}
//
//
////------sdf
//float fullBottleSDF(inout Path path,FullBottle theBottle,inout localData dat){
//    
//    
//    //distance to glass bottle
//    float bottleDistance = bottleDist(path.tv.pos.coords,theBottle.bottle);
//    
//
//        
//        
//    //half-width of the onioning used to make the bottle
//    float w=theBottle.bottle.thickness/2.;
//    //theFill lets us move the drink portion of the cylinder down
//    
//     Cylinder theDrink;
//    theDrink.center=theBottle.bottle.center-vec3(0,theBottle.fill,0);
//    theDrink.radius=theBottle.bottle.mainRadius-w;
//    theDrink.height=theBottle.bottle.mainHeight-theBottle.fill;
//    theDrink.rounded=0.5;
//    theDrink.mat=theBottle.drink;
//    
//    
//    float drinkDistance=cylinderDist(path.tv.pos.coords,theDrink);
//    
//    
//    float dist=min(bottleDistance, drinkDistance);
//    
//    if(abs(dist)<EPSILON){//set the material
//        fullBottleData(path,dat,bottleDistance,drinkDistance,theBottle,theDrink);
//    }
//
//    return dist;
//}
//
