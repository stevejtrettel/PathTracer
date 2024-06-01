//-------------------------------------------------
// OBJECTS OF THE SCENE
// describes the SDF / tracing function for the objects of the scene
//-------------------------------------------------

#include objects/basicShapes.glsl
#include objects/bottles.glsl
#include objects/fractals.glsl
#include objects/glasses.glsl
#include objects/hypGeo.glsl
#include objects/misc.glsl
#include objects/topology.glsl
#include objects/varieties.glsl

//this function constructs the objects
void buildObjects(){

    buildBasicShapes();
    buildBottles();
    buildFractals();
    buildGlasses();
    buildHypGeo();
    buildMisc();
    buildTopology();
    buildVarieties();

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
    //dist=min(dist, trace(tv, ball1));

    return dist;

}




//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

   float dist=maxDist;

    //dist=min( dist, sdf(tv, kB) );
    dist=min( dist, sdf(tv, var) );
   //dist=min( dist, sdf(tv, mobius) );
  // dist=min( dist, sdf(tv, mobius2) );
//    dist=min( dist, sdf(tv, campari) );
//    dist=min( dist, sdf(tv, vermouth) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
//so, in a multi-material object just put the parts that subsurface scatter.
//PROBLEM: RIGHT NOW DON'T NECESSARILY HAVE A GOOD WAY TO HAVE TWO SCATTERING MATERIALS IN CONTACT?
bool inside_Object( Vector tv ){

    //return false;
    return inside(tv,var);
   // return  inside(tv, mobius) || inside(tv, mobius2);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, var);
    //setData(path, mobius);
    //setData(path, mobius2);
    // setData(path, kB);
//    setData(path, vermouth);
    //setData(path, dod);
}



