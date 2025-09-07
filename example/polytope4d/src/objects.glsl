#include ../../../glsl/objects/polytopes/Polytope4D.glsl


//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Polytope4D poly;
Polytope4D dual;

void buildObjects(){

    setHypercube(poly);
    poly.center = vec3(0,1.5,0);
    poly.rot = rot3AxisAngle(normalize(vec3(0,1,0.1)),90.);
    poly.edgeRad = 0.05;
    poly.vertexRad =0.15;


    set16Cell(dual);
    dual.center = vec3(0,1.5,0);
    dual.rot = rot3AxisAngle(normalize(vec3(0,1,0.1)),90.);
    dual.edgeRad = 0.05;
    dual.vertexRad =0.15;


    vec3 pinkScatter = vec3(0.25,0.65,0.7);
    vec3 greenGlass = vec3(0.3,0.05,0.2);


    Material polyMat = makeGlass(10.*pinkScatter,1.5,0.95);
//    polyMat.refractionChance=0.;
//    polyMat.subSurface=true;
//    polyMat.meanFreePath=0.5*extra2;
//    polyMat.isotropicScatter=extra;
//    polyMat.roughness=0.0;

//    poly.edgeMat = polyMat;
//    poly.vertexMat = polyMat;

    poly.vertexMat.absorbColor = 20.*vec3(0.235,0.75,0.8);


//    Material dualMat = makeGlass(10.*greenGlass,1.5,0.95);
//    dualMat.refractionChance=0.;
//    dualMat.subSurface=true;
//    dualMat.meanFreePath=0.5*extra2;
//    dualMat.isotropicScatter=extra;
//    dualMat.roughness=0.0;
//
//    dual.edgeMat = dualMat;
//    dual.vertexMat = dualMat;
//
//    dual.vertexMat.absorbColor = 20.*vec3(0.3,0.1,0.2);

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
    dist=min( dist, sdf(tv, poly) );
//    dist=min( dist, sdf(tv, dual) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
    //return inside(tv,poly)|| inside(tv,dual);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, poly);
   // setData(path, dual);
}



