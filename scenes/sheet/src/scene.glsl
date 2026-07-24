//=====================================================================
// SHEET — a hollow sheet next to a solid region, against the sky.
//
// A SHEET is the second kind of object: a two-sided surface with NO interior.
// Both of its sides open onto whatever region contains it, so the interface is
// index-matched — no refraction, no Beer's law, nothing to be inside of. All a
// sheet contributes is a Surface, and it has TWO of them: a front and a back,
// picked by which side of its own sdf the ray is on.
//
// There is no room here on purpose. The two balls hang in the image sky, so the
// background is a PATTERN, and the difference between them is unmissable:
//
//   ball    a REGION of glass — the sky behind it is bent and flipped, and
//           darkens with depth through Beer's law
//   bubble  a SHEET — the sky behind it is completely UNDISTORTED, just tinted:
//           warm where you see its near face, cool through the middle where you
//           are seeing its far face from the inside
//
// If the bubble bends the sky, the sheet path is not firing.
//
// What this exercises in the engine (5Scene/scene.glsl):
//   * isSheet() excluding the bubble from containment, so standing on its
//     negative side does not make the bubble your medium
//   * front = back = the containing region's medium, so crossing changes nothing
//   * materialOf(..., bool front) choosing between the two Surfaces
//
// Both balls are analytic and there is nothing else in the scene, so the
// marcher never takes a step and every escaping ray samples the sky.
//=====================================================================

#include ../../../glsl/shapes/sphere.glsl


//--- the objects, in declaration order (= containment priority, inner to outer)
const int ID_BUBBLE = 0;
const int ID_BALL   = 1;

const int N_OBJ = 2;
float gSDF[N_OBJ];


//--- placement -------------------------------------------------------
const vec3  BALL_P   = vec3(-1.6, 1.3, -1.2);
const float BALL_R   = 1.3;

const vec3  BUBBLE_P = vec3(1.6, 1.3, -1.2);
const float BUBBLE_R = 1.3;


//---------------------------------------------------------------------
// the region sdfs
//
// The bubble's sdf stays SIGNED, exactly like a region's. It is tempting to
// write abs() for a sheet, since a sheet has no inside — but abs() puts a kink
// at the surface, and the 4-tap normal straddles that kink and returns noise.
// The marcher stops on |sdf| < eps regardless of sign, so a plain signed level
// set is already hit from both sides. What makes it a sheet is isSheet(), not
// the shape of its sdf.
//---------------------------------------------------------------------

float sdf_bubble(vec3 p){ return sphereDistance(p - BUBBLE_P, BUBBLE_R); }
float sdf_ball  (vec3 p){ return sphereDistance(p - BALL_P,   BALL_R);   }


//---------------------------------------------------------------------
// which objects are sheets
//---------------------------------------------------------------------

bool isSheet(int id){ return id == ID_BUBBLE; }


//---------------------------------------------------------------------
// the normals — the 4-tap of each object's own sdf, in world coordinates
//---------------------------------------------------------------------
const float NRM_E = 0.0002;

Vector normal_bubble(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_bubble(p + k.xyy*NRM_E) + k.yyx*sdf_bubble(p + k.yyx*NRM_E)
                              + k.yxy*sdf_bubble(p + k.yxy*NRM_E) + k.xxx*sdf_bubble(p + k.xxx*NRM_E) ));
}
Vector normal_ball(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_ball(p + k.xyy*NRM_E) + k.yyx*sdf_ball(p + k.yyx*NRM_E)
                              + k.yxy*sdf_ball(p + k.yxy*NRM_E) + k.xxx*sdf_ball(p + k.xxx*NRM_E) ));
}


//---------------------------------------------------------------------
// the materials
//---------------------------------------------------------------------

// One face of a sheet. transmitTint is the field the material system reserves
// for exactly this: on a volume it stays white and Beer's law owns the colour,
// but a sheet has no volume, so the tint IS the material. transmit = 1 with an
// index-matched interface means light crosses unbent and simply picks the tint
// up; the gloss floor adds a sheen so the surface is still visible.
Material sheetFace(vec3 tint, float gloss){
    Material m;
    initMat(m);
    m.surf.transmit     = 1.;
    m.surf.transmitTint = tint;
    m.surf.gloss        = gloss;
    m.surf.roughness    = 0.04;
    return m;
}

//FRONT is the side the sdf's gradient points toward — for a sphere, the outside.
Material material_bubble(vec3 p, inout Vector n, bool front){
    if(front){ return sheetFace(frontTint, sheetGloss); }
    return sheetFace(backTint, sheetGloss);
}
//a sheet has no interior, so this is never consulted for the bubble — the
//classifier uses the CONTAINING region's medium on both sides (here: air)
Medium medium_bubble(vec3 p){ return defaultMedium(); }

//the control: a real region, with an interior that refracts and absorbs
Material ballMaterial(){
    return makeGlass(absorbFor(vec3(0.80, 0.88, 0.92), 2.), ballIOR, 1.);
}
Material material_ball(vec3 p, inout Vector n){ return ballMaterial(); }
Medium   medium_ball  (vec3 p){ return ballMaterial().interior; }


//---------------------------------------------------------------------
// the dispatchers
//---------------------------------------------------------------------

void sdfAll(vec3 p){
    gSDF[ID_BUBBLE] = sdf_bubble(p);
    gSDF[ID_BALL]   = sdf_ball(p);
}

Vector normalOf(int id, vec3 p){
    if(id == ID_BUBBLE){ return normal_bubble(p); }
    return normal_ball(p);
}

Material materialOf(int id, vec3 p, inout Vector n, bool front){
    if(id == ID_BUBBLE){ return material_bubble(p, n, front); }
    return material_ball(p, n);
}

Medium mediumOf(int id, vec3 p){
    if(id == ID_BUBBLE){ return medium_bubble(p); }
    if(id == ID_BALL)  { return medium_ball(p);   }
    return defaultMedium();      //ID_NONE: open air
}


//---------------------------------------------------------------------
// the entry points
//---------------------------------------------------------------------

void buildScene(){}

//nothing marches: both balls have a closed-form intersection
float sdf_Scene(Vector tv){
    return maxDist;
}

//no room, no lights — everything that misses these two escapes to the sky
float trace_Scene(Vector tv){
    float d = maxDist;
    d = min(d, sphereTrace(tv, BUBBLE_P, BUBBLE_R));
    d = min(d, sphereTrace(tv, BALL_P,   BALL_R));
    return d;
}
