
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


void setCocktailData(float cup, float drink, Vector tv,inout localData dat,Cocktail cocktail){
    

    //first, if we are far from the drink
    if(drink>EPSILON){
        
    //if we are inside the cup away from liquid
    if(cup<0.){
        dat.mat=cocktail.cup;
    
        dat.normal=negate(cocktailGlassNormal(tv,cocktail.glass)); 
        dat.IOR=cocktail.cup.IOR/1.;
        dat.materialInterface=false;
        dat.reflectAbsorb=cocktail.cup.absorbColor;
        dat.refractAbsorb=vec3(0.);
        
    }
    
    //if we are outside the cup away from liquid
    else{
        dat.mat=cocktail.cup;
        dat.normal=cocktailGlassNormal(tv,cocktail.glass); 
        dat.IOR=1./cocktail.cup.IOR;
        dat.materialInterface=false;
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=cocktail.cup.absorbColor;
        
    }
}

else if(cup>EPSILON){
    //automatically drink<epsilon here in this case, so this means we must be near the drink and not the cup:
    

    if(drink<0.){//inside drink
        dat.mat=cocktail.drink;
        dat.normal=Vector(tv.pos,vec3(0,-1,0)); 
        dat.IOR=cocktail.drink.IOR/1.;
        dat.materialInterface=false; 
        dat.reflectAbsorb=cocktail.drink.absorbColor;
        dat.refractAbsorb=vec3(0.);
    }
    
    else{//outside drink
        dat.mat=cocktail.drink;
        dat.normal=Vector(tv.pos,vec3(0,1,0)); 
        dat.IOR=1./cocktail.drink.IOR;
        dat.materialInterface=false;
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=cocktail.drink.absorbColor;
        
    }
    
}


else{
    //drink< epsilon and cup<epsilon: so we are near both
    
    if(cup<0.){
        //inside cup near drink
        dat.mat=cocktail.cup;
        dat.normal=negate(cocktailGlassNormal(tv,cocktail.glass)); 
        dat.IOR=cocktail.cup.IOR/cocktail.drink.IOR;
        dat.materialInterface=true;
        dat.reflectAbsorb=cocktail.cup.absorbColor;
        dat.refractAbsorb=cocktail.drink.absorbColor;
        
    }
    
    else{
        //inside drink near cup
        dat.mat=cocktail.drink;
        dat.normal=cocktailGlassNormal(tv,cocktail.glass); 
        dat.IOR=cocktail.drink.IOR/cocktail.cup.IOR;
        dat.materialInterface=true;
        dat.reflectAbsorb=cocktail.drink.absorbColor;
        dat.refractAbsorb=cocktail.cup.absorbColor;
    }
    
}

}






float cocktailSDF(Vector tv, Cocktail cocktail,inout localData dat){
    
    float insideDist;
    
    //sets the distance to the glass part of the cup, and a boolean to say if you are inside of it
    float cup=cocktailGlassDistance(tv.pos.coords,cocktail.glass,insideDist);
    
    
    //distance to the top of the drink
    //right now direcly in the center of the cup
    float drinkTop=tv.pos.coords.y-cocktail.glass.center.coords.y-cocktail.glass.height/3.;
    
    //distance to drink is intersection of inside dist and this top
    float drink=max(insideDist,drinkTop);
    
    //make the total distance:
    float dist=min(abs(cup),abs(drink));
        
        
    if(dist<EPSILON){
         setCocktailData(cup,drink,tv,dat,cocktail);
    }
           
    return min(cup,drink);
}
