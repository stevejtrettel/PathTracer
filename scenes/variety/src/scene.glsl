//=====================================================================
// VARIETY — a zero set drawn two ways: as a surface, and as a solid.
//
// A variety is authored as an EQUATION, not a distance function. Its defining
// function s(p) is signed — positive on one side, negative on the other, zero on
// the surface. How you TRACE that signed function is a separate choice:
//
//   SURFACE (left, enneper)  march abs(s): the ray stops on {s=0} and passes
//                            through {s<0} instead of treating it as solid. The
//                            zero set itself, an infinitely thin two-sided
//                            membrane. enneper is a single open surface, so you
//                            see both of its faces at once.
//   VOLUME  (right, gyroid)  march s (thickened): {s<0} is a solid the ray
//                            refracts and absorbs through, like any glass.
//
// The key idea, and why this is not a hack: abs() lives ONLY at the marcher
// (sdf_Scene). The object's own sdf stays SIGNED, so its gradient is a real
// normal and its sign is the side — which means front/back materials work with
// no special case. Trace mode is one flag; everything else is shared.
//
// This scene exists because varieties are a quarter of the legacy library and
// are the one genuinely new KIND of shape: the generator emits a dual-number
// gradient evaluator from an equation's name (the old VARIETY_DATA macro).
//=====================================================================

#include ../../../glsl/objects/varieties/formulas/misc.glsl
#include ../../../glsl/shapes/variety.glsl
#include ../../../glsl/shapes/sphere.glsl
#include ../../../glsl/shapes/room.glsl


//--- the objects, in declaration order (= containment priority, inner to outer)
const int ID_SHEET = 0;
const int ID_SOLID = 1;
const int ID_LIGHT = 2;
const int ID_ROOM  = 3;

const int N_OBJ = 4;
float gSDF[N_OBJ];


//--- placement and shape parameters ----------------------------------
const vec3  SHEET_P = vec3(-2.4, 1.6, -1.2);
const vec3  SOLID_P = vec3( 2.4, 1.6, -1.2);

const float CLIP_R      = 1.9;     //both are cut down to a ball of this radius
const float CLIP_SMOOTH = 0.06;    //smax blend, so the cut edge is not razor sharp

const vec3  LIGHT_P      = vec3(-7.0, 4.0, 2.0);
const float LIGHT_RADIUS = 1.5;

//room interior: x in [-20, 8.5], y in [-1, 14], z in [-20, 10]
const vec3 ROOM_P        = vec3(-5.75, 6.5, -5.0);
const vec3 ROOM_HALFSIZE = vec3(14.25, 7.5, 15.0);


//---------------------------------------------------------------------
// the equation's gradient
//
// Three dual-number evaluations, one per partial: seed the dual part on x, then
// y, then z, and read the derivative out of each. The value is the same in all
// three, so it is taken from the first.
//
// This is the ONE piece of a variety that is mechanical from the equation's
// NAME — four lines of glue, and exactly what the generator emits. It is the
// replacement for the old VARIETY_DATA macro.
//---------------------------------------------------------------------

vec4 data_enneper(vec3 p){
    T vx = enneper(T(p.x, 1.0), T(p.y, 0.0), T(p.z, 0.0));
    T vy = enneper(T(p.x, 0.0), T(p.y, 1.0), T(p.z, 0.0));
    T vz = enneper(T(p.x, 0.0), T(p.y, 0.0), T(p.z, 1.0));
    return vec4(vx.y, vy.y, vz.y, vx.x);
}

vec4 data_gyroid(vec3 p){
    T vx = gyroid(T(p.x, 1.0), T(p.y, 0.0), T(p.z, 0.0));
    T vy = gyroid(T(p.x, 0.0), T(p.y, 1.0), T(p.z, 0.0));
    T vz = gyroid(T(p.x, 0.0), T(p.y, 0.0), T(p.z, 1.0));
    return vec4(vx.y, vy.y, vz.y, vx.x);
}


//---------------------------------------------------------------------
// the region sdfs
//---------------------------------------------------------------------

// the raw signed distance to the enneper variety — shared by the object sdf
// and the marched form below, so the equation is evaluated in one place
float enneperDist(vec3 p){
    return varietyDistance(data_enneper(varScale*(p - SHEET_P)), varScale);
}

// THE OBJECT'S SDF — signed, and clipped to the ball. This is what the
// classifier and the normal read: its SIGN is the face (s>0 vs s<0) and its
// GRADIENT is the surface normal. It is NOT abs'd — the object keeps its two
// sides. Marching is handled separately (sdf_Scene), which is the only place
// abs() appears.
float sdf_sheet(vec3 p){
    return smax(enneperDist(p), sphereDistance(p - SHEET_P, CLIP_R), CLIP_SMOOTH);
}

// the same zero set, thickened into a shell before the clip, so it has an
// inside. Thicken FIRST, clip second: clipping first would cut the shell open
// and leave the interior exposed at the ball's surface.
float sdf_solid(vec3 p){
    vec3  q = p - SOLID_P;
    float d = varietyDistance(data_gyroid(varScale*q), varScale);
    d = varietyShell(d, shellThickness, 0.0);
    return smax(d, sphereDistance(q, CLIP_R), CLIP_SMOOTH);
}

float sdf_light(vec3 p){ return sphereDistance(p - LIGHT_P, LIGHT_RADIUS); }
float sdf_room (vec3 p){ return roomDistance(p - ROOM_P, ROOM_HALFSIZE);   }


//---------------------------------------------------------------------
// the bounds — the acceleration structure
//
// The clip ball IS the bound, padded for the smax blend. A variety is exactly
// the case bounds are for: the real sdf is three dual-number evaluations of a
// trigonometric polynomial, and the bound is one length().
//---------------------------------------------------------------------

float bound_sheet(vec3 p){ return sphereDistance(p - SHEET_P, CLIP_R + CLIP_SMOOTH); }
float bound_solid(vec3 p){ return sphereDistance(p - SOLID_P, CLIP_R + CLIP_SMOOTH); }


//---------------------------------------------------------------------
// the normals — the 4-tap of each object's own sdf, in world coordinates
//---------------------------------------------------------------------
const float NRM_E = 0.0002;

Vector normal_sheet(vec3 p){
    vec2 k = vec2(1.0,-1.0)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_sheet(p + k.xyy*NRM_E) + k.yyx*sdf_sheet(p + k.yyx*NRM_E)
                              + k.yxy*sdf_sheet(p + k.yxy*NRM_E) + k.xxx*sdf_sheet(p + k.xxx*NRM_E) ));
}
Vector normal_solid(vec3 p){
    vec2 k = vec2(1.0,-1.0)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_solid(p + k.xyy*NRM_E) + k.yyx*sdf_solid(p + k.yyx*NRM_E)
                              + k.yxy*sdf_solid(p + k.yxy*NRM_E) + k.xxx*sdf_solid(p + k.xxx*NRM_E) ));
}
Vector normal_light(vec3 p){
    vec2 k = vec2(1.0,-1.0)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_light(p + k.xyy*NRM_E) + k.yyx*sdf_light(p + k.yyx*NRM_E)
                              + k.yxy*sdf_light(p + k.yxy*NRM_E) + k.xxx*sdf_light(p + k.xxx*NRM_E) ));
}
Vector normal_room(vec3 p){
    vec2 k = vec2(1.0,-1.0)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_room(p + k.xyy*NRM_E) + k.yyx*sdf_room(p + k.yyx*NRM_E)
                              + k.yxy*sdf_room(p + k.yxy*NRM_E) + k.xxx*sdf_room(p + k.xxx*NRM_E) ));
}


//---------------------------------------------------------------------
// the materials
//---------------------------------------------------------------------

// one face of the sheet — OPAQUE. transmit stays 0, so the face reflects rather
// than passing light through: a solid coloured surface, not a tinted film. The
// two faces are genuinely different materials, seen from the two sides of one
// infinitely thin surface.
Material sheetFace(vec3 color){
    return makeGloss(color, sheetGloss, 0.2);
}

// The two faces, front and back. `front` works here with no special case
// BECAUSE the object's sdf is signed (the abs lives only at the marcher): the
// normal comes from the signed gradient, so it flips correctly between the two
// sides and the engine's geometric front/back is exactly the s>0 / s<0 face.
// This is the whole payoff of keeping the sdf signed.
Material material_sheet(vec3 p, inout Vector n, bool front){
    if(front){ return sheetFace(frontColor); }
    return sheetFace(backColor);
}
Medium medium_sheet(vec3 p){ return defaultMedium(); }   //no interior: never used

//the control: the same surface as a real region, with glass inside it
Material material_solid(vec3 p, inout Vector n){ return makeGlass(absorbFor(vec3(0.72, 0.86, 0.80), 0.6), 1.5, 1.0); }
Medium   medium_solid  (vec3 p){ return makeGlass(absorbFor(vec3(0.72, 0.86, 0.80), 0.6), 1.5, 1.0).interior; }

Material material_light(vec3 p, inout Vector n){ return makeLight(vec3(0.9), 100.0); }
Medium   medium_light  (vec3 p){ return defaultMedium(); }

//six wall materials out of one region: pick by which face the point is nearest.
//the six walls are a material FIELD over one region: roomFace() says which one.
//Set warmColor / coolColor equal to wallColor to make the room uniform.
Material material_room(vec3 p, inout Vector n){
    vec3 q = p - ROOM_P;
    int face = roomFace(q, ROOM_HALFSIZE);

    if(face == ROOM_CEILING){ return makeLight(vec3(1.0), roomLight); }
    if(face == ROOM_FLOOR)  { return makeGloss(floorColor, 0.0, wallRough); }
    if(face == ROOM_LEFT)   { return makeGloss(warmColor,  0.0, wallRough); }
    if(face == ROOM_RIGHT)  { return makeGloss(coolColor,  0.0, wallRough); }
    return makeGloss(wallColor, 0.0, wallRough);
}
Medium medium_room(vec3 p){ return defaultMedium(); }


//---------------------------------------------------------------------
// the analytic intersections
//---------------------------------------------------------------------

float trace_light(Vector tv){
    return sphereTrace(tv, LIGHT_P, LIGHT_RADIUS);
}

//the ray is inside the box, so this is the distance at which it exits
float trace_room(Vector tv){
    return roomTrace(tv, ROOM_P, ROOM_HALFSIZE);
}


//---------------------------------------------------------------------
// the dispatchers
//---------------------------------------------------------------------

void sdfAll(vec3 p){
    gSDF[ID_SHEET] = sdf_sheet(p);
    gSDF[ID_SOLID] = sdf_solid(p);
    gSDF[ID_LIGHT] = sdf_light(p);
    gSDF[ID_ROOM]  = sdf_room(p);
}

Vector normalOf(int id, vec3 p){
    if(id == ID_SHEET){ return normal_sheet(p); }
    if(id == ID_SOLID){ return normal_solid(p); }
    if(id == ID_LIGHT){ return normal_light(p); }
    return normal_room(p);
}

//the enneper surface is a sheet: a two-sided surface with no interior
bool isSheet(int id){ return id == ID_SHEET; }

Material materialOf(int id, vec3 p, inout Vector n, bool front){
    if(id == ID_SHEET){ return material_sheet(p, n, front); }
    if(id == ID_SOLID){ return material_solid(p, n);        }
    if(id == ID_LIGHT){ return material_light(p, n);        }
    return material_room(p, n);
}

Medium mediumOf(int id, vec3 p){
    if(id == ID_SHEET){ return medium_sheet(p); }
    if(id == ID_SOLID){ return medium_solid(p); }
    if(id == ID_LIGHT){ return medium_light(p); }
    if(id == ID_ROOM) { return medium_room(p);  }
    return defaultMedium();      //ID_NONE: open air
}


//---------------------------------------------------------------------
// the entry points
//---------------------------------------------------------------------

void buildScene(){}

//both varieties are marched; the room and the light are analytic
float sdf_Scene(Vector tv){
    vec3 p = tv.pos;
    float d = maxDist;

    //SURFACE trace: abs() lives HERE and nowhere else. It makes the marcher stop
    //on {s=0} and pass through {s<0} rather than treating it as solid — while
    //sdf_sheet stays signed so the surface keeps its two sides. The clip is a
    //hard max OUTSIDE the abs, so the ball cap over {s<0} is not drawn.
    float b_sheet = bound_sheet(p);
    d = min(d, (b_sheet > BOUND_MARGIN) ? b_sheet
                                        : max(abs(enneperDist(p)), sphereDistance(p - SHEET_P, CLIP_R)));

    //VOLUME trace: sdf_solid is a thickened shell, marched directly
    float b_solid = bound_solid(p);
    d = min(d, (b_solid > BOUND_MARGIN) ? b_solid : sdf_solid(p));

    return d;
}

float trace_Scene(Vector tv){
    float d = maxDist;
    d = min(d, trace_light(tv));
    d = min(d, trace_room(tv));
    return d;
}
