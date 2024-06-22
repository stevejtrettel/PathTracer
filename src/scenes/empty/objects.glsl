//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

Sphere EH;
Box box;

void buildObjects(){

    EH.center=vec3(0);
    EH.radius=1.;

    box.center = vec3(-3,3,0);
    box.sides = vec3(0.5);

    vec3 color= vec3(0.9,0.9,0.5);
    float specularity=0.8;
    float roughness=0.;
    box.mat= makeMetal(color,specularity,roughness);

}



//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------
bool render_Objects=true;


//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

    float dist=maxDist;
   // dist=min( dist, sdf(tv, box) );
    return dist;

}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
    //return inside(tv,beer);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){

   // setData(path, box);
    if(length(path.tv.pos)<EH.radius){
        path.keepGoing=false;
        path.light=vec3(0);
        path.pixel=vec3(0);
    }
}



