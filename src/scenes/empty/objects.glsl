//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

Sphere EH;

void buildObjects(){

    EH.center=vec3(0);
    EH.radius=0.2;
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
    dist=min( dist, sdf(tv, EH) );
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
   // setData(path, beer);
    if(length(path.tv.pos)<1.){
        path.keepGoing=false;
        path.light=vec3(0);
        path.pixel=vec3(0);
    }
}



