
#include makePolytopes.glsl

//making the distance function


vec4 fold(vec4 pos, Polytope4D data) {

    for(int i=0;i<15;i++){
        if(i>data.iterates) break;//only run the number we need for this polytope
        pos.xy=abs(pos.xy);
        float t=-2.*min(0.,dot(pos,data.nc));
        pos+=t*data.nc;
        t=-2.*min(0.,dot(pos,data.nd));
        pos+=t*data.nd;
    }
    return pos;
}

float DD(float ca, float sa, float r){
    return r-(2.*r*ca-(1.-r*r)*sa)/((1.-r*r)*ca+2.*r*sa+1.+r*r);
}

float dist2Vertex(vec4 z, float r,Polytope4D data){
    float ca=dot(z,data.pVec);
    float sa=0.5*length(data.pVec-z)*length(data.pVec+z);//sqrt(1.-ca*ca);//
    return DD(ca,sa,r)-data.vertexRad;
}

float dist2Segment(vec4 z, vec4 n, float r,Polytope4D data){
    //pmin is the orthogonal projection of z onto the plane defined by p and n
    //then pmin is projected onto the unit sphere
    float zn=dot(z,n),zp=dot(z,data.pVec),np=dot(n,data.pVec);
    float alpha=zp-zn*np, beta=zn-zp*np;
    vec4 pmin=normalize(alpha*data.pVec+min(0.,beta)*n);
    //ca and sa are the cosine and sine of the angle between z and pmin. This is the spherical distance.
    float ca=dot(z,pmin), sa=0.5*length(pmin-z)*length(pmin+z);//sqrt(1.-ca*ca);//
    return DD(ca,sa,r)-data.segmentRad;
}

//it is possible to compute the distance to a face just as for segments: pmin will be the orthogonal projection
// of z onto the 3-plane defined by p and two n's (na and nb, na and nc, na and and, nb and nd... and so on).
//that involves solving a system of 3 linear equations.
//it's not implemented here because it is better with transparency

float dist2Segments(vec4 z, float r,Polytope4D data){
    float da=dist2Segment(z, vec4(1.,0.,0.,0.), r,data);
    float db=dist2Segment(z, vec4(0.,1.,0.,0.), r,data);
    float dc=dist2Segment(z, data.nc, r,data);
    float dd=dist2Segment(z, data.nd, r,data);

    return min(min(da,db),min(dc,dd));
}

float sdf_polytope(vec3 pos,Polytope4D data) {
    //return length(pos)-1.;
    float r=length(pos);
    vec4 z4=vec4(2.*pos,1.-r*r)*1./(1.+r*r);//Inverse stereographic projection of pos: z4 lies onto the unit 3-sphere centered at 0.
    z4.xyw=data.rot*z4.xyw;
    z4=fold(z4,data);//fold it

    return min(dist2Vertex(z4,r,data),dist2Segments(z4, r,data));
}






//-------------------------------------------------
//The OBJECT sdf
//-------------------------------------------------


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Polytope4D obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdf_polytope(pos,obj);
}




//-------------------------------------------------
//STUFF DERIVED FROM THIS
//-------------------------------------------------


//overload of location booleans:
bool at( Vector tv,Polytope4D obj){

    float d = distR3( tv.pos, obj );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Polytope4D obj ){
    float d = distR3( tv.pos, obj );
    return (d<0.);
}




//overload of sdf for a sphere
float sdf( Vector tv, Polytope4D obj ){

    //distance to closest point on box
    float d=distR3(tv.pos, obj);
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, Polytope4D obj ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, obj);
    float vyyx=distR3( pos + e.yyx*ep, obj);
    float vyxy=distR3( pos + e.yxy*ep, obj);
    float vxxx=distR3( pos + e.xxx*ep, obj);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//overload of setData for a sphere
void setData( inout Path path, Polytope4D obj){

    //if we are at the surface
    if(at(path.tv, obj)){
        //compute the normal
        Vector normal=normalVec(path.tv,obj);
        bool side = inside(path.tv, obj);
        //set the material
        setObjectInAir(path.dat, side, normal, obj.mat);
    }

}

















