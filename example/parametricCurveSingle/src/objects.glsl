//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------





#include ../../../glsl/objects/shapes/parametricCurveSingle.glsl





// Position on the curve at parameter t.
vec3 curvePos( float t) {
    // EXAMPLE (replace with your parametric equations):
    // helix: C(t) = (cos t, sin t, 0.25 t)
    return vec3(cos(t), sin(t), 0.25*t);
}

// Optional: variable radius along the curve.
float curveRadius(float t) {
    // If you don't want a varying radius, either:
    //  - return pc.radius; and set pc.varyRadius=false, or
    //  - implement a radius profile here and set pc.varyRadius=true
    return 0.1;
}












//set the names of objects contained in the scene
ParametricCurve curve;

void buildObjects(){


    curve.t0 = 0.;
    curve.t1 = 6.28;
    curve.segments = 128;
    curve.varyRadiusFlag=0;
    curve.radius =0.1;
    curve.mat = makeDielectric(vec3(0.2,0.1,0.5),0.5,0.9);

    curve.bboxCenter=vec3(0);
    curve.bboxRad=3.;

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
    dist = min(dist, sdf(tv, curve));
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
    setData(path, curve);
}



