//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/hyperbolicHoneycomb.glsl

//set the names of objects contained in the scene
HyperbolicHoneycomb honey;

void buildObjects(){

    //the honeycomb lives in the z>0 half-space; place its local origin at the
    //world origin so local coords == render (upper-half-space) coords
    honey.frame = makeFrame(vec3(0,0,0));

    //fold-depth knob (named GUI param): how deep toward the ideal boundary
    //the honeycomb resolves (~20 snappy preview ... ~200 for depth)
    honey.foldIterations = foldDepth;

    //physics only; the per-cell color is set by the recolor followup below
    honey.mat = makeGloss(vec3(0.5), 0.2, 0.15);

}


//-------------------------------------------------
// COLOR (scene-owned): map the honeycomb region to a color. edit freely.
//-------------------------------------------------

const vec3 COL_SEG_A   = vec3(0.55, 0.24, 0.13);
const vec3 COL_SEG_B   = vec3(0.08, 0.38, 0.40);
const vec3 COL_SEG_C   = vec3(0.06, 0.18, 0.20);
const vec3 COL_SEG_D   = vec3(0.46, 0.32, 0.18);
const vec3 COL_VERTEX  = vec3(0.76, 0.66, 0.50);
const vec3 COL_FACE    = vec3(0.40, 0.40, 0.65);
const vec3 COL_FLOOR_1 = vec3(0.34, 0.13, 0.09);
const vec3 COL_FLOOR_2 = vec3(0.06, 0.25, 0.28);
const vec3 COL_FLOOR_L = vec3(0.72, 0.55, 0.30);

vec3 honeyColor( vec3 p ){
    int r = region(p, honey);
    if(r == HC_SEG_B)  return COL_SEG_B;
    if(r == HC_SEG_C)  return COL_SEG_C;
    if(r == HC_SEG_D)  return COL_SEG_D;
    if(r == HC_VERTEX) return COL_VERTEX;
    if(r == HC_FACE)   return COL_FACE;
    if(r == HC_FLOOR)  return floorTint(p.xy, honey, COL_FLOOR_1, COL_FLOOR_2, COL_FLOOR_L);
    return COL_SEG_A;
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
    dist=min( dist, sdf(tv, honey) );
    return dist;
}



//used in subsurface scattering: keep scattering while inside this object
bool inside_Object( Vector tv ){
    return inside(tv,honey);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, honey);                        // geometry + flat base material
    if( at(path.tv, honey) ){                    // recolor followup (scene-owned)
        vec3 p = toLocal(honey.frame, path.tv.pos);
        path.dat.surfDiffuse = honeyColor(p);
    }
}
