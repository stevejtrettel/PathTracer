

struct Polytope4D{

//these will all be set by 'make hypercube' or 'make24' etc
    vec4 nc;
    vec4 nd;
    vec4 pVec;
    int iterates;

//these are set per shape (but have default values in the make functions)
    float vertexRad;
    float segmentRad;
    mat3 rot;
    vec3 center;
    float size;
    Material mat;
};



//GENERAL CREATION FUNCTION

void setPolytope4D(int Type, vec4 coords, inout Polytope4D poly ){
    //type is 3,4,5
    //coords is UVWT determining edge/vertex placement in fundamental domain

    float cospin=cos(PI/float(Type));
    float isinpin=1./sin(PI/float(Type));
    float scospin=sqrt(2./3.-cospin*cospin);
    float issinpin=1./sqrt(3.-4.*cospin*cospin);

    //set nc and nd
    poly.nc=0.5*vec4(0,-1,sqrt(3.),0.);
    poly.nd=vec4(-cospin,-0.5,-0.5/sqrt(3.),scospin);

    //set pVec
    vec4 pabc,pbdc,pcda,pdba;
    pabc=vec4(0.,0.,0.,1.);
    pbdc=0.5*sqrt(3.)*vec4(scospin,0.,0.,cospin);
    pcda=isinpin*vec4(0.,0.5*sqrt(3.)*scospin,0.5*scospin,1./sqrt(3.));
    pdba=issinpin*vec4(0.,0.,2.*scospin,1./sqrt(3.));

    poly.pVec=normalize(coords.x*pabc+coords.y*pbdc+coords.z*pcda+coords.w*pdba);


    //set iterates
    switch(Type) {
        case 3:
        poly.iterates = 3;
        break;
        case 4:
        poly.iterates = 8;
        break;
        case 5:
        poly.iterates = 15;
        break;
        default:
        poly.iterates = 10;
    }

    //set default values of per-shape quantities

    poly.vertexRad = 0.05048;
    poly.segmentRad = 0.05476;

    poly.center = vec3(0);
    poly.size = 1.;
    poly.rot = mat3(1,0,0,0,1,0,0,0,1);

    poly.mat = makeDielectric(vec3(0.5,0.5,0.5),0.5,0.2);

}


Polytope4D makePolytope4D(int type, vec4 coords){
    Polytope4D poly;
    setPolytope4D(type,coords,poly);
    return poly;
}



















//-------------------------------------------
//CREATION FUNCTIONS FOR SPECIFIC POLYTOPES
//-------------------------------------------


void set5Cell(inout Polytope4D poly){
    setPolytope4D(3, vec4(0,1,0,0),poly);
}

Polytope4D make5Cell(){
    return makePolytope4D(3, vec4(0,1,0,0));
}



void setHypercube(inout Polytope4D poly){
    setPolytope4D(4, vec4(0,1,0,0),poly);
}

Polytope4D makeHypercube(){
    return makePolytope4D(4, vec4(0,1,0,0));
}




void set24Cell(inout Polytope4D poly){
    setPolytope4D(4, vec4(0,0,1,0),poly);
}

Polytope4D make24Cell(){
    return makePolytope4D(4, vec4(0,0,1,0));
}




void set16Cell(inout Polytope4D poly){
    setPolytope4D(4, vec4(0,0,0,1),poly);
}

Polytope4D make16Cell(){
    return makePolytope4D(4, vec4(0,0,0,1));
}








void set120Cell(inout Polytope4D poly){
    setPolytope4D(5, vec4(0,1,0,0),poly);
}

Polytope4D make120Cell(){
    return makePolytope4D(5, vec4(0,1,0,0));
}



void set600Cell(inout Polytope4D poly){
    setPolytope4D(5, vec4(0,0,0,1),poly);
}

Polytope4D make600Cell(){
    return makePolytope4D(5, vec4(0,0,0,1));
}
