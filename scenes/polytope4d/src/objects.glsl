#include ../../../glsl/objects/polytopes/polytope4D.glsl


//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

//set the names of objects contained in the scene
Polytope4D poly;
Polytope4D dual;

void buildObjects(){

    setHypercube(poly);
    poly.frame = makeFrame(vec3(0,1.5,0));
    //poly.rot is an internal rotation of the 3-sphere (not 3D placement): unchanged
    poly.rot = rot3AxisAngle(normalize(vec3(0,1,0.1)),-90.);
    poly.edgeRad = 0.05;
    poly.vertexRad =0.15;


    set16Cell(dual);
    dual.frame = makeFrame(vec3(0,1.5,0));
    dual.rot = rot3AxisAngle(normalize(vec3(0,1,0.1)),-90.);
    dual.edgeRad = 0.05;
    dual.vertexRad =0.15;


    vec3 tealScatter = vec3(0.25,0.65,0.7);
    vec3 magentaGlass = vec3(0.3,0.05,0.2);


    Material polyMat = makeGlass(10.*tealScatter,1.5,1.);
//alternate materials:
//    polyMat.refractionChance=0.;
//    polyMat.subSurface=true;
//    polyMat.meanFreePath=0.5*scratch2;
//    polyMat.isotropicScatter=scratch1;
//    polyMat.roughness=0.0;

//    poly.edgeMat = polyMat;
//    poly.vertexMat = polyMat;

    poly.vertexMat.absorbColor = 20.*vec3(0.235,0.75,0.8);


//    Material dualMat = makeGlass(10.*magentaGlass,1.5,1.);
//    dualMat.refractionChance=0.;
//    dualMat.subSurface=true;
//    dualMat.meanFreePath=0.5*scratch2;
//    dualMat.isotropicScatter=scratch1;
//    dualMat.roughness=0.0;
//
//    dual.edgeMat = dualMat;
//    dual.vertexMat = dualMat;
//
//    dual.vertexMat.absorbColor = 20.*vec3(0.3,0.1,0.2);

}



//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    return dist;
}

float sdf_Objects( Vector tv ){

    float dist=maxDist;
    dist=min( dist, sdf(tv, poly) );
//alternate: render the dual 16-cell
//    dist=min( dist, sdf(tv, dual) );
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
    //alternate: render the dual 16-cell
    //return inside(tv,poly)|| inside(tv,dual);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, poly);
   //alternate: render the dual 16-cell
   // setData(path, dual);
}
