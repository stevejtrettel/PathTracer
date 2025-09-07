//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------


#include ../../../glsl/objects/shapes/parametricCurveSystem.glsl
#include curveDispatch.glsl

//set the names of objects contained in the scene
ParametricCurve curveA;
ParametricCurve curveB;

void buildObjects(){


//    curve.t0 = 0.;
//    curve.t1 = 6.28;
//    curve.segments = 64;
//    curve.varyRadius=false;
//    curve.radius =0.1;
//    curve.mat = makeDielectric(vec3(0.2,0.1,0.5),0.5,0.9);
//


    // --- Helix tube ---
    curveA.t0 = 0.0;
    curveA.t1 = 12.566;           // ~ 4 turns
    curveA.segments = 64;        // <= MAX_SEGMENTS
    curveA.varyRadiusFlag = 0;    // constant radius
    curveA.radius = 0.10;
    curveA.curveType  = CURVE_HELIX;
    curveA.radiusType = RAD_CONST;
    curveA.mat = makeDielectric(vec3(0.2,0.1,0.5), 0.5, 0.9);
    curveA.bboxRad = 3.;
    curveA.bboxCenter = vec3(0);

    // --- Trefoil tube ---
    curveB.t0 = 0.0;
    curveB.t1 = 6.283;            // one period
    curveB.segments = 64;
    curveB.varyRadiusFlag = 0;
    curveB.radius = 0.07;
    curveB.curveType  = CURVE_TREFOIL;
    curveB.radiusType = RAD_CONST;
    curveB.mat = makeDielectric(vec3(0.85,0.82,0.80), 0.1,0.3); // example material
    curveB.bboxRad = 3.;
    curveB.bboxCenter = vec3(0);

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
   // dist = min(dist, trace(tv,sphere));
    return dist;
}

//copy as many lines of dist=min(dist, sdf(tv, NEW_OBJ)), one for each object in the scene
float sdf_Objects( Vector tv ){

    float dist = maxDist;
    dist = min(dist, sdf(tv, curveA));
    dist = min(dist, sdf(tv, curveB));
    return dist;
}



//used in subsurface scattering: right now we keep scattering if we are inside of this object!
bool inside_Object( Vector tv ){
    return false;
   // return inside(tv,curveA);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


//put multiple copies of "setData"; one for each object in the scene.

void setData_Objects(inout Path path){
    setData(path, curveA);
    setData(path, curveB);
}



