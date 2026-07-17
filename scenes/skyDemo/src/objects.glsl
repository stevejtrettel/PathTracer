//-------------------------------------------------
// OBJECTS OF THE SCENE
// a mirror sphere and a glass sphere: the sky image should be visible
// directly, in the mirror reflection, and through the refraction
//-------------------------------------------------

Sphere mirrorBall, glassBall;


void buildObjects(){

    mirrorBall.frame = makeFrame(vec3(-1.4, 0.2, -1));
    mirrorBall.radius = 1.2;
    mirrorBall.mat = makeMetal(vec3(0.9), 1., 0.);

    glassBall.frame = makeFrame(vec3(1.4, 0., -1));
    glassBall.radius = 1.;
    glassBall.mat = makeGlass(vec3(0.05), 1.5, 0.95);

}


//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    dist = min(dist, trace(tv, mirrorBall));
    dist = min(dist, trace(tv, glassBall));
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//used in subsurface scattering
bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, mirrorBall);
    setData(path, glassBall);
}
