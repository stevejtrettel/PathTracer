//-------------------------------------------------
// OBJECTS — BEER'S LAW: DISTANCE vs CONCENTRATION
// (material.glsl absorbFor, updatePath.glsl updateFromVolume)
//
// Absorption is  exp(-absorb * distance)  — a product. So there are exactly
// two ways to make a clear material read as a deeper colour, and this page
// puts them side by side:
//
//   FRONT row — MORE GLASS. Identical absorb, radius growing left to right.
//     The tint is a property of the medium; the depth of colour is a property
//     of the OBJECT. This is why a thick glass bottle is green at the rim and
//     nearly clear at the neck, with no change of material.
//
//   BACK row — MORE PIGMENT. Identical radius, absorb scaling left to right.
//     Same visual result, different cause.
//
// The rows are matched so equivalent columns carry the same optical depth:
// column i of the front row has 2x the path of column 0, and column i of the
// back row has 2x the extinction. Beer cannot tell them apart — only the
// silhouette gives it away. THAT is the point: `absorb` alone is not a colour,
// it is a colour PER UNIT LENGTH, and it means nothing until you say how far.
//
// Which is what absorbFor(tint, depth) is for: it answers "what extinction
// shows THIS tint after travelling THIS far", so you author in the terms you
// can actually see instead of hand-scaling magic constants.
//-------------------------------------------------

const int NUM = 6;
Sphere depthRow[NUM];
Sphere pigmentRow[NUM];


void buildObjects(){

    vec3 tint = vec3(0.35, 0.75, 0.55);   //shown after `tintDepth` of travel
    vec3 base = absorbFor(tint, tintDepth);

    for(int i = 0; i < NUM; i++){
        float x = -6.5 + 2.6*float(i);
        float step = pow(1.55, float(i));   //geometric: 1 -> ~9

        //MORE GLASS: same medium, growing object (centre tracks the radius so
        //every sphere rests on the floor)
        float r = 0.45*step;
        depthRow[i].frame  = makeFrame(vec3(x, r, 2.5));
        depthRow[i].radius = r;
        depthRow[i].mat    = makeGlass(base, 1.5);

        //MORE PIGMENT: same object, growing extinction
        pigmentRow[i].frame  = makeFrame(vec3(x, 1.1, -2.8));
        pigmentRow[i].radius = 1.1;
        pigmentRow[i].mat    = makeGlass(base*step, 1.5);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, depthRow[i]));
        dist = min(dist, trace(tv, pigmentRow[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    for(int i = 0; i < NUM; i++){
        if(inside(tv, depthRow[i])){   return true; }
        if(inside(tv, pigmentRow[i])){ return true; }
    }
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, depthRow[i]);
        setData(path, pigmentRow[i]);
    }
}
