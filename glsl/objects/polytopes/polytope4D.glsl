
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

//converts a spherical distance on the unit 3-sphere (given by its cosine ca and sine sa)
//into the corresponding Euclidean distance seen from a point at radius r under the stereographic projection
float DD(float ca, float sa, float r){
    return r-(2.*r*ca-(1.-r*r)*sa)/((1.-r*r)*ca+2.*r*sa+1.+r*r);
}

float dist2Vertex(vec4 z, float r,Polytope4D data){
    float ca=dot(z,data.pVec);
    float sa=0.5*length(data.pVec-z)*length(data.pVec+z);
    return DD(ca,sa,r)-data.vertexRad;
}

float dist2Segment(vec4 z, vec4 n, float r,Polytope4D data){
    //pmin is the orthogonal projection of z onto the plane defined by p and n
    //then pmin is projected onto the unit sphere
    float zn=dot(z,n),zp=dot(z,data.pVec),np=dot(n,data.pVec);
    float alpha=zp-zn*np, beta=zn-zp*np;
    vec4 pmin=normalize(alpha*data.pVec+min(0.,beta)*n);
    //ca and sa are the cosine and sine of the angle between z and pmin. This is the spherical distance.
    float ca=dot(z,pmin), sa=0.5*length(pmin-z)*length(pmin+z);
    return DD(ca,sa,r)-data.edgeRad;
}

//it is possible to compute the distance to a face just as for segments: pmin will be the orthogonal projection
// of z onto the 3-plane defined by p and two n's (na and nb, na and nc, na and nd, nb and nd... and so on).
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
    float r=length(pos);
    vec4 z4=vec4(2.*pos,1.-r*r)*1./(1.+r*r);//Inverse stereographic projection of pos: z4 lies onto the unit 3-sphere centered at 0.
    z4.xyw=data.rot*z4.xyw;
    z4=fold(z4,data);//fold it

    return min(dist2Vertex(z4,r,data),dist2Segments(z4, r,data));
}






//-------------------------------------------------
//The POLYTOPE sdf
//-------------------------------------------------


//the local-frame sdf (size is a shape parameter, kept as before)
float sdf( vec3 p, Polytope4D obj ){
    vec3 pos = p / obj.size;
    return sdf_polytope(pos,obj);
}

//local bounding sphere: the stereographically-projected polytope lies within
//radius 2.4 in the scaled frame = 2.4*size in local coords.
float bound( vec3 p, Polytope4D obj ){ return length(p) - 2.4*obj.size; }


//distance function that returns BOTH vertex and edge distance!
//takes LOCAL coordinates, like the point-level sdf
vec2 sdf_VE(vec3 p, Polytope4D obj){
    vec3 pos = p / obj.size;

    //do the R4 calculation
    float r=length(pos);
    vec4 z4=vec4(2.*pos,1.-r*r)*1./(1.+r*r);//Inverse stereographic projection of pos: z4 lies onto the unit 3-sphere centered at 0.
    z4.xyw=obj.rot*z4.xyw;
    z4=fold(z4,obj);//fold it

    //get the distances to each
    float dV = dist2Vertex(z4,r,obj);
    float dE = dist2Segments(z4, r,obj);

    return vec2(dV,dE);
}




//at, inside, the Vector-level sdf, and normalVec from the standard interface
//(no OBJECT_INIT: the type has edgeMat/vertexMat instead of a single mat field)
OBJECT_LOCATORS_B(Polytope4D)
OBJECT_NORMAL_FD(Polytope4D)


//custom setData: the material depends on whether we hit a vertex or an edge
void setData( inout Path path, Polytope4D obj){

    //if we are at the surface
    if(at(path.tv, obj)){
        //compute the normal
        Vector normal=normalVec(path.tv,obj);
        bool side = inside(path.tv, obj);

        //set the material: this depends on if we hit the vertex or edge!
        //(sdf_VE takes local coordinates)
        vec2 dVec = sdf_VE(toLocal(obj.frame, path.tv.pos),obj);

        if(abs(dVec.x)<abs(dVec.y)){
            //vertex dist smaller than edge dist
            setObjectInAir(path.dat, side, normal, obj.vertexMat);
        }
        else{
            //edge dist smaller than vertexDist
            setObjectInAir(path.dat, side, normal, obj.edgeMat);
        }


    }

}
