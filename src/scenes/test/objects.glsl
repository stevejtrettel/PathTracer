//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Sphere ball;
Box box;


void buildObjects(){

    vec3 color;
    float specularity, roughness;
    vec3 pinkScatter = vec3(0.25,0.65,0.7);

    //----------- BALL 1 -------------------------
    ball.center=vec3(-3,0.4,-2);
    ball.radius=1.3;

    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;
    ball.mat= makeMetal(color,specularity,roughness);


    //----------- BOX  -------------------------
    box.center=vec3(-5.,1.,-5.);
    box.sides=vec3(1,1,1);
    box.rounded=0.1;

    box.mat=makeGlass(5.*pinkScatter,1.5,0.97);
    box.mat.refractionChance=0.;
    box.mat.subSurface=true;
    box.mat.meanFreePath=0.5*extra2;
    box.mat.isotropicScatter=extra;
    box.mat.roughness=0.04;

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
    return dist;
}

//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

    float dist=maxDist;
    dist=min( dist, sdf(tv, ball) );
    dist=min( dist, sdf(tv, box) );

    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    //return false;
    return inside(tv,box);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, ball);
    setData(path, box);
}



