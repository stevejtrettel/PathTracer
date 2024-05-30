



//-------------------------------------------------
//The APOLLONIAN GASKET sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Gasket{
    vec3 center;
    float radius;
    Material mat;
};


//auxillary function for calculating this
float apollonian(vec3 p)
{
    float K=0.4;
    float scale = 1.0;
    vec4 orb = vec4(1000.0);

    for( int i=0; i < 15;  i++ )
    {
        p = -1.0 + 2.0*fract(0.5*p+0.5);
        float r2 = dot(p,p);
        orb = min( orb, vec4(abs(p),r2) );
        float k = (1.0 + K)/r2;
        p *= k;
        scale *= k;
    }

    //this adds in balls insteaad
    //float res = abs(p.y);
    //
    float  res = min(abs(p.z)+abs(p.x),
    min(abs(p.x)+abs(p.y),
    abs(p.y)+abs(p.z)));

    return 0.25/scale*res;
}

float sqrt3=sqrt(3.);
vec3 triangles(vec3 p){
    float zm = 1.;
    p.x = p.x-sqrt3*(p.y+.5)/3.;
    p = vec3(mod(p.x+sqrt3/2.,sqrt3)-sqrt3/2., mod(p.y+.5,1.5)-.5 , mod(p.z+.5*zm,zm)-.5*zm);
    p = vec3(p.x/sqrt3, (p.y+.5)*2./3. -.5 , p.z);
    p = p.y>-p.x ? vec3(-p.y,-p.x , p.z) : p;
    p = vec3(p.x*sqrt3, (p.y+.5)*3./2.-.5 , p.z);
    return vec3(p.x+sqrt3*(p.y+.5)/3., p.y , p.z);
}


vec4 orb;
//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Gasket gasket ){

    p-=gasket.center;
    p=gasket.radius*p;

    p /= dot(p,p);
    p += vec3(1.0);
    p*=3.;


    //
    //        float scale = 1.;
    //        float s = 1./3.;
    //        for( int i=0; i<20;i++ )
    //        {
    //            p = triangles(p);
    //            float r2= dot(p,p);
    //            float k = s/r2;
    //            p = p * k;
    //            scale=scale*k;
    //        }
    //        return .3*length(p)/scale -.001/sqrt(scale);


    //********************************************************************************
    //

    float scale = 1.0;
    float s=1.5;
    orb = vec4(1000.0);

    for( int i=0; i<10;i++ )
    {
        p = -1.0 + 2.0*fract(0.5*p+extra);

        float r2 = dot(p,p);

        orb = min( orb, vec4(abs(p),r2) );

        float k = s/r2;
        p     *= k;
        scale *= k;
    }
    float  res = min(abs(p.z)+abs(p.x),min(abs(p.x)+abs(p.y),abs(p.y)+abs(p.z)))+0.2;
    //float res=abs(p.y);
    float dist= 0.25*res/scale;
    return dist;

    //********************************************************************************


    //        float scale = 6.0;
    //        vec3 q=p;
    //        p /= scale;
    //        float s = 1.0;
    //    //    if (doInversion) {
    //            s = dot(p,p);
    //            p /= s;
    //            p += vec3(1.0);
    //    //    }
    //        //if (doTranslate) p.y += 0.1*iTime;
    //        float d0=apollonian(p)*scale;
    //        float d = d0;
    //        return d*s;
}






//-------------------
// ONE ALTERNATIVE GASKET
//-------------------
//
//float sqrt3 =1.73205080757;
//vec3 triangles(vec3 p){
//    float zm = 1.;
//    p.x = p.x-sqrt3*(p.y+.5)/3.;
//    p = vec3(mod(p.x+sqrt3/2.,sqrt3)-sqrt3/2., mod(p.y+.5,1.5)-.5 , mod(p.z+.5*zm,zm)-.5*zm);
//    p = vec3(p.x/sqrt3, (p.y+.5)*2./3. -.5 , p.z);
//    p = p.y>-p.x ? vec3(-p.y,-p.x , p.z) : p;
//    p = vec3(p.x*sqrt3, (p.y+.5)*3./2.-.5 , p.z);
//    return vec3(p.x+sqrt3*(p.y+.5)/3., p.y , p.z);
//}
//float distR3(vec3 p, Gasket gasket){
//
//    p-=gasket.center;
//    p=gasket.radius*p;
//
//    p /= dot(p,p);
//    p += vec3(1.0);
//    p*=5.;
//
//    float scale = 1.;
//    float s = 1./3.;
//    for( int i=0; i<10;i++ )
//    {
//        p = triangles(p);
//        float r2= dot(p,p);
//        float k = s/r2;
//        p = p * k;
//        scale=scale*k;
//    }
//    return .3*length(p)/scale		-.001/sqrt(scale);
//}



//-------------------
// ANOTHER ALTERNATIVE GASKET: SIMPLE!
//-------------------
//float distR3( vec3 p, Gasket gasket )
//{
//
//    p-=gasket.center;
//    p=gasket.radius*p;
//
//    p /= dot(p,p);
//    p += vec3(1.0);
//    p*=5.;
//
//
//    float s = 1.1;
//    float scale = 1.0;
//
//    for( int i=0; i<8;i++ )
//    {
//        p = -1.0 + 2.0*fract(0.5*p+0.5);
//
//        float r2 = dot(p,p);
//
//        float k = s/r2;
//        p     *= k;
//        scale *= k;
//    }
//
//    return 0.25*abs(p.y)/scale;
//}


//overload of location booleans:
bool at( Vector tv, Gasket gasket){
    return true;
    float d = distR3( tv.pos, gasket );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Gasket gasket ){
    //return false;
    float d = distR3( tv.pos, gasket );
    return (d<0.);
}




//overload of sdf for a gasket
float sdf( Vector tv, Gasket gasket ){

    //distance to closest point on fractal
    return distR3(tv.pos, gasket);

}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Gasket gasket ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, gasket);
    float vyyx=distR3( pos + e.yyx*ep, gasket);
    float vyxy=distR3( pos + e.yxy*ep, gasket);
    float vxxx=distR3( pos + e.xxx*ep, gasket);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}


//overload of trace for a gasket
float trace( Vector tv, Gasket gasket ){
    vec3 ro=tv.pos;
    vec3 rd=tv.dir;

    //
    //        float pixelRadius= 1.0/(iResolution.y * 2.0);
    //        float t = 0.002;
    //        float h = 5.;
    //        for( int i=0; i<512; i++ )
    //        {
    //            if(h<t*pixelRadius || t>maxDist){break;}
    //            h =distR3( ro+rd*t, gasket );
    //            t += h;
    //        }
    //        if(h>t*pixelRadius){t=maxDist*2.;}
    //        return t;
    //


    //**************************************************************


    float t = 0.001;
    for( int i=0; i<512; i++ )
    {
        float precis = 0.001*t;
        // float precis = 0.001;
        float h = distR3( ro+rd*t, gasket);
        if( h<precis||t>maxDist) break;
        t += h;
    }
    return t;
    //**************************************************************
    //    vec3 ro=tv.pos;
    //    vec3 rd=tv.dir;
    //    float pixel_size = 1.0/(iResolution.y * 2.0);
    //    float t = 1.0;
    //
    //    for( int i=0; i<2048; i++ )
    //    {
    //        float c = distR3(ro + rd*t,gasket);
    //        if( c<0.5*pixel_size*t ) break;
    //        t += c;
    //        if( t>100.0 ) return maxDist;
    //    }
    //    return t;

}



//overload of setData for a sphere
void setData( inout Path path, Gasket gasket){

    //if we are at the surface
    if(at(path.tv, gasket)){
        //compute the normal
        Vector normal=normalVec(path.tv,gasket);
        bool side = inside(path.tv, gasket);
        //set the material
        setObjectInAir(path.dat, side, normal, gasket.mat);
    }
}







