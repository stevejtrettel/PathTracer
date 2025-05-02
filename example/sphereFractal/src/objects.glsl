//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Sphere sphere1;
Sphere sphere2;
Sphere sphere3;
Sphere sphere4;

Triangle triang1;
Triangle triang2;
Triangle triang3;
Triangle triang4;

//vertices of a tetrahedron
vec3 v1 = vec3(sqrt(8./9.),0,-1./3.);
vec3 v2 = vec3(-sqrt(2./9.),sqrt(2./3.),-1./3.);
vec3 v3 =vec3(-sqrt(2./9.),-sqrt(2./3.),-1./3.);
vec3 v4 = vec3(0,0,1);

//radius of tet
float rad = sqrt(6.)/3.;

void buildObjects(){

    sphere1.center=v1;
    sphere1.radius=rad;
    sphere1.mat=makeMetal(vec3(0.8),0.95,0.);

    sphere2.center=v2;
    sphere2.radius=rad;
    sphere2.mat=makeMetal(vec3(0.8),0.95,0.);

    sphere3.center=v3;
    sphere3.radius=rad;
    sphere3.mat=makeMetal(vec3(0.8),0.95,0.);

    sphere4.center=v4;
    sphere4.radius=rad;
    sphere4.mat=makeMetal(vec3(0.8),0.95,0.);

    float emit = 0.1*extra3;

    triang1.center = -1.25*v2;
    triang1.side=4.*rad;
    triang1.thickness=0.1;
    triang1.orientation = rotateAboutZ(1.57)*rotateZto(v2);
    triang1.mat = makeDielectric(vec3(0.7,0.2,0.2),0.5,0.1);
    triang1.mat.surfaceEmit = emit*vec3(0.7,0.2,0.2);

    triang2.center = -1.25*v3;
    triang2.side=4.*rad;
    triang2.thickness=0.1;
    triang2.orientation = rotateAboutZ(1.57)*rotateZto(v3);
    triang2.mat = makeDielectric(vec3(0.2,0.7,0.2),0.5,0.1);
    triang2.mat.surfaceEmit = emit*vec3(0.2,0.7,0.2);

    triang3.center = -1.25*v4;
    triang3.side=4.*rad;
    triang3.thickness=0.1;
    triang3.orientation = rotateAboutZ(-1.57)*rotateZto(v4);
    triang3.mat = makeDielectric(vec3(0.2,0.2,0.7),0.5,0.1);
    triang3.mat.surfaceEmit = emit*vec3(0.2,0.2,0.7);

    triang4.center = -1.3*v1;
    triang4.side=4.*rad;
    triang4.thickness=0.1;
    triang4.orientation = rotateAboutZ(1.57)*rotateZto(v1);
    triang4.mat = makeGlass(vec3(1),1.2,0.95);


}



//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------
bool render_Objects=true;


//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

//copy as many lines of dist=min(dist, trace(tv, NEW_OBJ)), one for each object to be traced
float trace_Objects( Vector tv ){
    float dist=maxDist;
   // dist = min(dist, trace(tv,sphere1));
    return dist;
}

//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

    float dist=maxDist;
    dist=min( dist, sdf(tv, sphere1) );
    dist=min( dist, sdf(tv, sphere2) );
    dist=min( dist, sdf(tv, sphere3) );
    dist=min( dist, sdf(tv, sphere4) );

    dist=min( dist, sdf(tv, triang1) );
    dist=min( dist, sdf(tv, triang2) );
    dist=min( dist, sdf(tv, triang3) );

  //  dist=min( dist, sdf(tv, triang4) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
//    return inside(tv,sphere);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, sphere1);
    setData(path, sphere2);
    setData(path, sphere3);
    setData(path, sphere4);

    setData(path, triang1);
    setData(path, triang2);
    setData(path, triang3);
 //   setData(path, triang4);

}



