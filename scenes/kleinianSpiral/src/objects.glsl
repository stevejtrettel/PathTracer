//-------------------------------------------------
// OBJECTS OF THE SCENE
//-------------------------------------------------

#include ../../../glsl/objects/fractals/kleinianSpiral.glsl

//set the names of objects contained in the scene
KleinianSpiral klein;

void buildObjects(){

    //fractal at the origin so world coords == the shadertoy's (camera matches)
    klein.frame = makeFrame(vec3(0,0,0));

    //TWO rendering settings (not geometry!) that make the interior view read like
    //the original — both settable globals, both faithful to the shadertoy:
    //  1. max ray length: the original marches only ~20 units then escapes to sky
    //     (MAX_DISTANCE=20); our default 100 fills the frame with distant fractal.
    maxDist = 20.;
    //  2. fine hit threshold: the original uses a tiny distance-adaptive epsilon
    //     (~7e-6 near the camera), so the marcher sees THROUGH the thin fractal
    //     "haze" to open space. our default 0.001 is ~130x coarser -> the camera
    //     reads as embedded in a solid wall. match the fine threshold here.
    EPSILON = 0.00005;

    //detail knob (named GUI param): box-fold iterations
    //(~16 snappy preview ... ~60 matches the original resolution)
    klein.boxIterations = detail;

    //PRESENTATION: carve out just the ONE spiral in front of the camera (roughly
    //the focal point, ~1.2 units ahead along the view direction) and drop the
    //rest of the infinite tiling. set clip=false for the full landscape.
    klein.clip       = true;
    klein.clipCenter = vec3(0.6, 0.8, -0.7);   //the spiral we're looking at
    klein.clipSize   = vec3(0.8, 0.7, 0.8);    //half-extents (local units)

    //physics only; the color is set by the recolor followup below
    klein.mat = makeDielectric(vec3(0.55, 0.5, 0.6), 0.2, 0.05);

}


//-------------------------------------------------
// COLOR (scene-owned): map the orbit trap to a color. edit freely.
//-------------------------------------------------

const vec3  KLEIN_BASE = vec3(0.55, 0.5, 0.6);
const float KLEIN_STRENGTH = 0.6392111;
const vec4  KLEIN_X = vec4(0.0,      1.0,      0.164706, 1.0);
const vec4  KLEIN_Y = vec4(1.0,      0.533333, 0.0,      1.0);
const vec4  KLEIN_Z = vec4(0.603922, 0.164706, 0.776471, 1.0);
const vec4  KLEIN_R = vec4(0.262745, 0.482353, 1.0,      0.29412);

vec3 kleinColor( vec3 p ){
    vec4 trap = orbitTrap(p, klein);
    trap.w = sqrt(trap.w);
    vec3 c = KLEIN_X.rgb*KLEIN_X.a*trap.x
           + KLEIN_Y.rgb*KLEIN_Y.a*trap.y
           + KLEIN_Z.rgb*KLEIN_Z.a*trap.z
           + KLEIN_R.rgb*KLEIN_R.a*trap.w;
    return clamp(mix(KLEIN_BASE, 3.0*c, KLEIN_STRENGTH), 0.0, 1.0);
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
    dist=min( dist, sdf(tv, klein) );
    return dist;
}



//used in subsurface scattering: keep scattering while inside this object
bool inside_Object( Vector tv ){
    return inside(tv,klein);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------


void setData_Objects(inout Path path){
    setData(path, klein);                        // geometry + flat base material
    if( at(path.tv, klein) ){                    // recolor followup (scene-owned)
        vec3 p = toLocal(klein.frame, path.tv.pos);
        vec3 c = kleinColor(p);
        path.dat.surfDiffuse = c;
        path.dat.surfEmit    = 0.04 * c;         // faint orbit-trap glow; the sky +
                                                 // key light do most of the lighting
    }
}
