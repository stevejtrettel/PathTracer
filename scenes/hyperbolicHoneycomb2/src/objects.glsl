//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/hyperbolicHoneycomb2.glsl

//set the names of objects contained in the scene
HyperbolicHoneycomb2 honey;

void buildObjects(){

    //local origin at the world origin: local coords == render (half-space) coords
    honey.frame = makeFrame(vec3(0,0,0));

    //fold-depth knob (named GUI param) (~30 preview ... ~180 full depth)
    honey.foldIterations = foldDepth;

    //physics only; the per-cell color is set by the recolor followup below
    honey.mat = makeDielectric(vec3(0.5), 0.2, 0.12);

}


//-------------------------------------------------
// COLOR (scene-owned): map the honeycomb region to a color. edit freely.
//-------------------------------------------------

const vec3 BASE_TINT = vec3(0.67451);
const float TINT_STR = 0.55319;   //blend toward BASE_TINT (0 = full palette)

const vec3 COL_SEG_A   = vec3(0.811765, 0.733333, 0.325490);
const vec3 COL_SEG_B   = vec3(0.000000, 0.486275, 0.729412);
const vec3 COL_SEG_C   = vec3(0.647059, 0.866667, 0.843137);
const vec3 COL_SEG_D   = vec3(0.717647, 0.415686, 0.847059);
const vec3 COL_VERTEX  = vec3(0.909804, 0.937255, 0.976471);
const vec3 COL_FACE    = vec3(0.835294, 0.647059, 0.784314);
const vec3 COL_FLOOR_1 = vec3(0.968627, 1.000000, 0.600000);
const vec3 COL_FLOOR_2 = vec3(0.552941, 0.380392, 0.521569);
const vec3 COL_FLOOR_L = vec3(0.0);

vec3 honeyColor( vec3 p ){
    int r = region(p, honey);
    vec3 c = COL_SEG_A;
    if(r == HC2_SEG_B)  c = COL_SEG_B;
    if(r == HC2_SEG_C)  c = COL_SEG_C;
    if(r == HC2_SEG_D)  c = COL_SEG_D;
    if(r == HC2_VERT)   c = COL_VERTEX;
    if(r == HC2_FACE)   c = COL_FACE;
    if(r == HC2_FLOOR)  c = floorTint(p.xy, honey, COL_FLOOR_1, COL_FLOOR_2, COL_FLOOR_L);
    return clamp(mix(BASE_TINT, c, TINT_STR), 0.0, 1.0);
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
