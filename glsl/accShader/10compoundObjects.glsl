
//-------------------------------------------------
// The COCKTAIL sdf
//-------------------------------------------------

struct Cocktail{
    CocktailGlass glass;
    Material cup;
    Material drink;
    float fill;
};



//we already have a cocktail glass struct
//this includes a function for the glass distance and normal
//but we still need the drink distance and normal








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
