
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



void setCocktailData(float cup, float drinkSide,float drinkTop, Vector tv,inout localData dat,Cocktail cocktail){
    
    float eps=2.*EPSILON;
    float drink=max(drinkSide,drinkTop);
    //------------------------------------------------
    if(abs(cup)<eps){
        //if we hit the cup (the main option)
        //the normal will be this or its negation
        dat.normal=cocktailGlassNormal(tv,cocktail.glass);
        //whether we are in the drink or not, will use the glass as the interacting material
        dat.mat=cocktail.cup;
        
        //if we hit the cup from inside or outside determines direction of normal
        if(cup>0.){
            //we hit the cup from outside
            //the normal stays the same
            //but did we hit it near the drink?
            if(abs(drink)>eps||drinkTop>0.){
                //we are far from drink
                dat.materialInterface=false;
                dat.IOR=1./cocktail.cup.IOR;
                dat.reflectAbsorb=vec3(0.);
                dat.refractAbsorb=cocktail.cup.absorbColor;
            }
            else{
                //we are inside the drink
                dat.materialInterface=true;
                dat.IOR=cocktail.drink.IOR/cocktail.cup.IOR;
                dat.reflectAbsorb=cocktail.drink.absorbColor;
                dat.refractAbsorb=cocktail.cup.absorbColor;
            }
 
        }
        else{
            //we hit the cup from inside the glass
            //normal gets reversed
            dat.normal=negate(dat.normal);
            //again, did we hit it near the drink?
            if(abs(drink)>eps){
                //we are far from the drink
                dat.materialInterface=false;
                dat.IOR=cocktail.cup.IOR/1.;
                dat.reflectAbsorb=cocktail.cup.absorbColor;
                dat.refractAbsorb=vec3(0.);
            }
            else{
                //we are entering the drink
                dat.materialInterface=true;
                dat.IOR=cocktail.cup.IOR/cocktail.drink.IOR;
                dat.reflectAbsorb=cocktail.cup.absorbColor;
                dat.refractAbsorb=cocktail.drink.absorbColor;
            }
        }
        
    }
    //------------------------------------------------
    
    
    //------------------------------------------------
    else{
        //if we didn't hit the cup, we hit the liquid's surface
        dat.mat=cocktail.drink;
        //upward normal
        dat.normal=Vector(tv.pos,vec3(0,1,0)); 
        dat.materialInterface=false;
        
        //only two options: above or below water line:
        if(drinkTop>0.){
            //above the water line
            dat.IOR=1./cocktail.drink.IOR;
            dat.reflectAbsorb=vec3(0.);
            dat.refractAbsorb=cocktail.drink.absorbColor;
        }
        else{
            //below the water line
            //reverse the normal
            dat.normal=negate(dat.normal);
            dat.IOR=cocktail.drink.IOR/1.;
            dat.reflectAbsorb=cocktail.drink.absorbColor;
            dat.refractAbsorb=vec3(0.);
        }
        
    }
    //------------------------------------------------
}









float cocktailSDF(Vector tv, Cocktail cocktail,inout localData dat){
    
    float drinkSide;
    
    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=cocktailGlassDistance(tv.pos.coords,cocktail.glass,drinkSide);
    
    
    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop=tv.pos.coords.y-cocktail.glass.center.coords.y-cocktail.glass.height/3.;
    
    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);
    
    //make the total distance:
    float dist=min(abs(cup),abs(drink));
        
        
    if(dist<EPSILON){
         setCocktailData(cup,drinkSide,drinkTop,tv,dat,cocktail);
    }
           
    return min(cup,drink);
}









//-------------------------------------------------
// The LIQUOR BOTTLE sdf
//-------------------------------------------------

struct LiquorBottle{
    Bottle glass;
    Material cup;
    Material drink;
    float fill;
};


void setLiquorBottleData(float cup, float drinkSide,float drinkTop, Vector tv,inout localData dat,LiquorBottle gin){
    
    float eps=2.*EPSILON;
    float drink=max(drinkSide,drinkTop);
    //------------------------------------------------
    if(abs(cup)<eps){
        //if we hit the cup (the main option)
        //the normal will be this or its negation
        dat.normal=bottleNormal(tv,gin.glass);
        //whether we are in the drink or not, will use the glass as the interacting material
        dat.mat=gin.cup;
        
        //if we hit the cup from inside or outside determines direction of normal
        if(cup>0.){
            //we hit the cup from outside
            //the normal stays the same
            //but did we hit it near the drink?
            if(abs(drink)>eps||drinkTop>0.){
                //we are far from drink
                dat.materialInterface=false;
                dat.IOR=1./gin.cup.IOR;
                dat.reflectAbsorb=vec3(0.);
                dat.refractAbsorb=gin.cup.absorbColor;
            }
            else{
                //we are inside the drink
                dat.materialInterface=true;
                dat.IOR=gin.drink.IOR/gin.cup.IOR;
                dat.reflectAbsorb=gin.drink.absorbColor;
                dat.refractAbsorb=gin.cup.absorbColor;
            }
 
        }
        else{
            //we hit the cup from inside the glass
            //normal gets reversed
            dat.normal=negate(dat.normal);
            //again, did we hit it near the drink?
            if(abs(drink)>eps){
                //we are far from the drink
                dat.materialInterface=false;
                dat.IOR=gin.cup.IOR/1.;
                dat.reflectAbsorb=gin.cup.absorbColor;
                dat.refractAbsorb=vec3(0.);
            }
            else{
                //we are entering the drink
                dat.materialInterface=true;
                dat.IOR=gin.cup.IOR/gin.drink.IOR;
                dat.reflectAbsorb=gin.cup.absorbColor;
                dat.refractAbsorb=gin.drink.absorbColor;
            }
        }
        
    }
    //------------------------------------------------
    
    
    //------------------------------------------------
    else{
        //if we didn't hit the cup, we hit the liquid's surface
        dat.mat=gin.drink;
        //upward normal
        dat.normal=Vector(tv.pos,vec3(0,1,0)); 
        dat.materialInterface=false;
        
        //only two options: above or below water line:
        if(drinkTop>0.){
            //above the water line
            dat.IOR=1./gin.drink.IOR;
            dat.reflectAbsorb=vec3(0.);
            dat.refractAbsorb=gin.drink.absorbColor;
        }
        else{
            //below the water line
            //reverse the normal
            dat.normal=negate(dat.normal);
            dat.IOR=gin.drink.IOR/1.;
            dat.reflectAbsorb=gin.drink.absorbColor;
            dat.refractAbsorb=vec3(0.);
        }
        
    }
    //------------------------------------------------
}










float liquorBottleSDF(Vector tv, LiquorBottle gin,inout localData dat){
    
    float drinkSide;
    
    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=bottleDistance(tv.pos.coords,gin.glass,drinkSide);
    
    
    //distance to the top of the drink
    //right now no fill=exactly bottom of the glass
    
    float drinkTop=tv.pos.coords.y-gin.glass.center.coords.y;
    
    drinkTop-=gin.glass.baseHeight*gin.fill;
    
    //distance to drink is intersection of inside dist and this top
    float drink=max(drinkSide,drinkTop);
    
    //make the total distance:
    float dist=min(abs(cup),abs(drink));
        
        
    if(dist<EPSILON){
         setLiquorBottleData(cup,drinkSide,drinkTop,tv,dat,gin);
    }
           
    return min(cup,drink);
}











//
//
//
//
//
//void setCocktailData(float cup, float drinkSide,float drinkTop, Vector tv,inout localData dat,Cocktail cocktail){
//    
//    float eps=2.*EPSILON;
//    
//    //divide things up by drinkTop: if this is positive we are above the water line
//    
//    if(drinkTop>0.){
//        //we hit either (1) the glass cup above the water line, or (2) the drink's top surface from above
//        
//        if(abs(cup)<eps){
//            //the only object we could have hit is the glass cup.  But there are two options: did we hit from the inside or outside of the glass?
//            dat.mat=cocktail.cup;
//            dat.normal=cocktailGlassNormal(tv,cocktail.glass);
//            dat.materialInterface=false;
//        
//            if(cup>0.){
//            //hit the glass from the outside
//            //leave normal outward, set IOR ratio, and colors
//            dat.IOR=1./cocktail.cup.IOR;
//            dat.reflectAbsorb=vec3(0.);
//            dat.refractAbsorb=cocktail.cup.absorbColor;
//            }
//            else{
//            //hit the glass from the inside
//            //reverse the normal, set IOR ratio, and colors
//            dat.normal=negate(dat.normal); 
//            dat.IOR=cocktail.cup.IOR/1.;
//                dat.reflectAbsorb=cocktail.cup.absorbColor;
//            dat.refractAbsorb=vec3(0.);
//            }
//        }
//        
//        else{
//            //we are far from the cup
//            //we must have hit the surface of the drink, bearing downwards from above:
//            dat.mat=cocktail.drink;
//            dat.normal=Vector(tv.pos,vec3(0,1,0)); 
//            dat.IOR=1./cocktail.drink.IOR;
//            dat.materialInterface=false;
//            dat.reflectAbsorb=vec3(0.);
//            dat.refractAbsorb=cocktail.drink.absorbColor;
//            
//        }
//    }
//    
//    
//    else{
//        //if drinkTop<0 we are below the water line
//        //there are a couple options: either we hit the cup or we do not again
//        //if we do not hit the cup, we hit the water line from below.
//
//        if(abs(cup)<eps){
//            //otherwise we hit the cup
//            dat.mat=cocktail.cup;
//            dat.normal=cocktailGlassNormal(tv,cocktail.glass);
//            
//            
//            //here there are some subtleties left, as we hit it below the water line
//            //we could have hit it from the outside, or from a surface it shares with the drink.
//            if(abs(drinkSide)>eps){
//                //we hit it away from the drink,
//                //still have to worry about inside or outside of the cup: (MAKES THIS A BAD APPROACH)\
//                dat.materialInterface=false;
//        
//                if(cup>0.){
//                //hit the glass from the outside
//                //leave normal outward
//                dat.IOR=1./cocktail.cup.IOR;
//                dat.reflectAbsorb=vec3(0.);
//                dat.refractAbsorb=cocktail.cup.absorbColor;
//                }
//                else{
//                //hit the glass from the inside
//                //reverse the normal
//                dat.normal=negate(dat.normal); 
//                dat.IOR=cocktail.cup.IOR/1.;
//                dat.reflectAbsorb=cocktail.cup.absorbColor;
//                dat.refractAbsorb=vec3(0.);
//                }
//            }
//            
//            else{
//                //we hit it near the drink
//                dat.materialInterface=true;
//                //are we inside our outside of the cup when we do this?
//                if(cup<0.){
//                //inside cup near drink
//                dat.mat=cocktail.cup;
//                //reverse the normal
//                dat.normal=negate(dat.normal); 
//                dat.IOR=cocktail.cup.IOR/cocktail.drink.IOR;
//                dat.reflectAbsorb=cocktail.cup.absorbColor;
//                dat.refractAbsorb=cocktail.drink.absorbColor;
//        
//                }
//    
//                else{
//                //inside drink near cup
//                dat.mat=cocktail.drink;
//                //leave outward normal
//                dat.IOR=cocktail.drink.IOR/cocktail.cup.IOR;
//                dat.reflectAbsorb=cocktail.drink.absorbColor;
//                dat.refractAbsorb=cocktail.cup.absorbColor;
//                }
//  
//            }
//        }
//        
//        else{
//            //we hit the liquid's surface from below
//            dat.mat=cocktail.drink;
//            dat.normal=Vector(tv.pos,vec3(0,-1,0)); 
//            dat.IOR=cocktail.drink.IOR/1.;
//            dat.materialInterface=false; 
//            dat.reflectAbsorb=cocktail.drink.absorbColor;
//            dat.refractAbsorb=vec3(0.);
//        }
//    }
//}
//
//
//






//
//void setCocktailData(float cup, float drinkSide,float drinkTop, Vector tv,inout localData dat,Cocktail cocktail){
//    
//    //distance to drink is intersection of inside dist and this top
//    float drink=max(drinkSide,drinkTop);
//
//    //first, if we are far from the drink
//    if(drink>EPSILON){
//        
//    //if we are inside the cup away from liquid
//    if(cup<0.){
//        dat.mat=cocktail.cup;
//    
//        dat.normal=negate(cocktailGlassNormal(tv,cocktail.glass)); 
//        dat.IOR=cocktail.cup.IOR/1.;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=cocktail.cup.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//        
//    }
//    
//    //if we are outside the cup away from liquid
//    else{
//        dat.mat=cocktail.cup;
//        dat.normal=cocktailGlassNormal(tv,cocktail.glass); 
//        dat.IOR=1./cocktail.cup.IOR;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=cocktail.cup.absorbColor;
//        
//    }
//}
//
//    
//    
//    
//    
//    
//else if(cup>EPSILON){
//    //automatically drink<epsilon here in this case, so this means we must be near the drink and not the cup:
//    
//
//    if(drink<0.){//inside drink
//        dat.mat=cocktail.drink;
//        dat.normal=Vector(tv.pos,vec3(0,-1,0)); 
//        dat.IOR=cocktail.drink.IOR/1.;
//        dat.materialInterface=false; 
//        dat.reflectAbsorb=cocktail.drink.absorbColor;
//        dat.refractAbsorb=vec3(0.);
//    }
//    
//    else{//outside drink
//        dat.mat=cocktail.drink;
//        dat.normal=Vector(tv.pos,vec3(0,1,0)); 
//        dat.IOR=1./cocktail.drink.IOR;
//        dat.materialInterface=false;
//        dat.reflectAbsorb=vec3(0.);
//        dat.refractAbsorb=cocktail.drink.absorbColor;
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
//        dat.mat=cocktail.cup;
//        dat.normal=negate(cocktailGlassNormal(tv,cocktail.glass)); 
//        dat.IOR=cocktail.cup.IOR/cocktail.drink.IOR;
//        dat.materialInterface=true;
//        dat.reflectAbsorb=cocktail.cup.absorbColor;
//        dat.refractAbsorb=cocktail.drink.absorbColor;
//        
//    }
//    
//    else{
//        //inside drink near cup
//        dat.mat=cocktail.drink;
//        dat.normal=cocktailGlassNormal(tv,cocktail.glass); 
//        dat.IOR=cocktail.drink.IOR/cocktail.cup.IOR;
//        dat.materialInterface=true;
//        dat.reflectAbsorb=cocktail.drink.absorbColor;
//        dat.refractAbsorb=cocktail.cup.absorbColor;
//    }
//    
//}
//
//}




