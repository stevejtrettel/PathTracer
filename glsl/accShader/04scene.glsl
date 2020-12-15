













//extra data
float sceneSDF(Vector tv, inout localData dat){
    vec3 color;
    float specularity;
    float roughness;
    float intensity;
    
//    //sphere 0
//    vec3 center=vec3(0,-0.35,-2.);
//    float dist= sphereSDF(tv, center,0.5);
//    
//    
//    if(dist<eps){
//        
//        dat.isSky=false;
//        dat.normal=sphereNormal(tv,center);
//        
//        color=0.5*vec3(0.9,0.9,0.5);
//        specularity=0.2;
//        roughness=0.4;
//        
//        setDielectric(dat.mat, color, specularity, roughness);
//        
//        return dist;
//    }
//    
//    
//        //sphere 1
//    vec3 center1=vec3(-0.6,-0.63,-1.6);
//    float dist1= sphereSDF(tv, center1,0.25);
//    
//    
//    if(dist1<eps){
//        dat.isSky=false;
//        dat.normal=sphereNormal(tv,center1);
//        
//        color=vec3(0.3,0.2,0.6);
//        specularity=0.5;
//        roughness=0.05;
//        
//        setMetal(dat.mat, color, specularity, roughness);
//        
//        return dist1;
//    }
//
//    dist1=min(dist,dist1);
//    
//    
//            //sphere 1
//    vec3 center11=vec3(-0.1,-0.7,-1.3);
//    float dist11= sphereSDF(tv, center11,0.15);
//    
//    
//    if(dist11<eps){
//        dat.isSky=false;
//        dat.normal=sphereNormal(tv,center11);
//        
//        color=0.75*vec3(0.7,0.1,0.2);
//        specularity=0.6;
//        roughness=0.05;
//        
//        setMetal(dat.mat, color, specularity, roughness);
//
//        return dist11;
//    }
//
//    dist1=min(dist1,dist11);
//    
    
    
    vec2 rad=vec2(1,.02);
    float height=.2;
    vec3 center=vec3(0,-0.6,-1.);
    
    float dist1=ringSDF(tv,rad,height,center);
    
     if(dist1<eps){
        dat.isSky=false;
        dat.normal=ringNormal(tv,rad,height,center);
        
        color =vec3(.6,.6,0.2);
        specularity=0.75;
        roughness=0.0;
        
        setMetal(dat.mat, color, specularity, roughness);
        
        return dist1;
    }
    
    
    
//    //the light source
//    vec3 center2=vec3(.8,0.0,-0.5);
//    float dist2=sphereSDF(tv, center2,0.1);
//    
//    if(dist2<eps){
//        dat.isSky=false;
//        dat.normal=sphereNormal(tv,center2);
//        
//        color =vec3(1.,0.9,0.7);
//        intensity=50.;
//        
//        setLight(dat.mat, color,intensity);
//        
//        return dist2;
//    }
//    
    
        //the light source
    vec3 center3=vec3(0,.4,0.2);
    float dist21=sphereSDF(tv, center3,0.1);
    
    if(dist21<eps){
        dat.isSky=false;
        dat.normal=sphereNormal(tv,center3);
        
        color =vec3(1.,0.9,0.7);
        intensity=100.;
        
        setLight(dat.mat, color,intensity);
        
        return dist21;
    }
    
    //dist2=min(dist2,dist21);
   float  dist2=dist21;
    
    //floor
    vec3 pNormal=vec3(0,1,0.1);
        float dist3=planeSDF(tv, pNormal,1.);
    
    if(dist3<eps){
        dat.isSky=false;
        dat.normal=planeNormal(tv,pNormal,1.);
        
        
        color=vec3(1.,0.7,0.7);
        specularity=0.1;
        roughness=0.2;
        
        setDielectric(dat.mat, color, specularity, roughness);

    
        return dist3;
    }
    

    
    
         pNormal=vec3(1,0,1);
        float dist4=planeSDF(tv, pNormal,5.);
    
    if(dist4<eps){
        dat.isSky=false;
        dat.normal=planeNormal(tv,pNormal,5.);
        
        
        
        color=vec3(0.7,0.7,0.8);
        specularity=0.1;
        roughness=0.5;
        
        setDielectric(dat.mat, color, specularity, roughness);
        
        
        return dist4;
    }
    
    
        
         pNormal=vec3(-1,0,1);
        float dist5=planeSDF(tv, pNormal,5.);
    
    if(dist5<eps){
        dat.isSky=false;
        dat.normal=planeNormal(tv,pNormal,5.);
    
                
        color=vec3(0.5,0.9,0.5);
        specularity=0.;
        roughness=0.5;
        
        setDielectric(dat.mat, color, specularity, roughness);
        

        return dist5;
    }
    
   // float dist4=maxDist;
   // float dist5=maxDist;
    
    return min(min(min(dist1,dist2),min(dist3,dist4)),dist5);

}


