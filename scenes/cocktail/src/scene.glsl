//=====================================================================
// COCKTAIL — a glass with a drink in it.
//
// Two regions sharing a wall. The four interfaces this scene used to enumerate
// by hand — outer wall, inner wall above water, inner wall below water, liquid
// top — appear nowhere in this file. The classifier in 5Scene/scene.glsl works
// them out from the sdfs at the hit point, and the above/below-water split is
// the max() in sdf_drink and nothing more.
//
// Declaration order is priority: `cup` comes before `drink`, so the glass owns
// the finish of the wall they share.
//
// Lighting and camera are copied from legacy/cocktail so the two are
// comparable. Wall albedo drives path length through roulette (expected bounces
// = 1/(1-albedo)), so a brighter room is a slower room.
//=====================================================================

#include ../../../glsl/shapes/cocktailGlass.glsl


#include ../../../glsl/shapes/sphere.glsl
#include ../../../glsl/shapes/room.glsl


//--- the objects, in declaration order (= containment priority, inner to outer)
const int ID_CUP   = 0;
const int ID_DRINK = 1;
const int ID_LIGHT = 2;
const int ID_ROOM  = 3;

const int N_OBJ = 4;
float gSDF[N_OBJ];


//--- placement and shape parameters ----------------------------------
const vec3  GLASS_P     = vec3(-1.0, 0.1, -1.2);
const float G_RADIUS    = 1.0;
const float G_HEIGHT    = 1.0;
const float G_THICKNESS = 0.1;
const float G_BASE      = 0.3;
const float WATERLINE   = G_HEIGHT/3.;      //in the glass's own coordinates

const vec3  LIGHT_P = vec3(-7.0, 4.0, 2.0);
const float LIGHT_R = 1.5;

//room interior: x in [-20, 8.5], y in [-1, 14], z in [-20, 10]
const vec3 ROOM_C = vec3(-5.75, 6.5, -5.0);
const vec3 ROOM_H = vec3(14.25, 7.5, 15.0);


//---------------------------------------------------------------------
// the region sdfs
//---------------------------------------------------------------------

// The cup and the drink are TWO REGIONS OF ONE SHAPE, so they come out of one
// evaluation: cocktailGlassDistance returns the glass wall and hands back the
// enclosed cavity, and the drink is that cavity cut off at the waterline.
//
// This is what a multi-material object is. Splitting them into two independent
// sdfs would evaluate the glass twice for no reason.
//
// Above the waterline max() picks the plane, so the drink is simply not there —
// which is why the inner wall classifies as cup/air up there with no branch.
void sdf_cocktail(vec3 p, out float cup, out float drink){
    vec3  q = p - GLASS_P;
    float cavity;
    cup   = cocktailGlassDistance(q, G_RADIUS, G_HEIGHT, G_THICKNESS, G_BASE, cavity);
    drink = max(cavity, q.y - WATERLINE);
}

//single-region entry points, for the 4-tap normals below
float sdf_cup(vec3 p){   float cup, drink; sdf_cocktail(p, cup, drink); return cup;   }
float sdf_drink(vec3 p){ float cup, drink; sdf_cocktail(p, cup, drink); return drink; }

float sdf_light(vec3 p){
    return sphereDistance(p - LIGHT_P, LIGHT_R);
}

//the room SOLID is everything outside the box, so its interior is open air and
//regionAt() returns ID_NONE there
float sdf_room(vec3 p){
    return roomDistance(p - ROOM_C, ROOM_H);
}


//---------------------------------------------------------------------
// the bound — our acceleration structure for the marcher
//
// A cheap shape that never overestimates the distance to the real surface, so
// the marcher can return it instead of the real sdf while the ray is still far
// away. One bound covers the glass AND the drink, since the drink lives inside
// the glass: a group bound culling both at once.
//
// Bounds belong in sdf_Scene only. sdfAll has to stay exact — the classifier
// tests |sdf| < AT_THRESH, so a short-circuited sdf there would stop the object
// being recognised at its own surface.
//---------------------------------------------------------------------

float bound_glass(vec3 p){
    return cocktailGlassBound(p - GLASS_P, G_RADIUS, G_HEIGHT, G_BASE);
}


//---------------------------------------------------------------------
// the normals
// Always the 4-tap of the region's own sdf, in world coordinates. Every one of
// these is the same four lines; GLSL has no function pointers, so each region
// needs its own copy.
//---------------------------------------------------------------------
const float NRM_E = 0.0002;

Vector normal_cup(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_cup(p + k.xyy*NRM_E) + k.yyx*sdf_cup(p + k.yyx*NRM_E)
                              + k.yxy*sdf_cup(p + k.yxy*NRM_E) + k.xxx*sdf_cup(p + k.xxx*NRM_E) ));
}

Vector normal_drink(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_drink(p + k.xyy*NRM_E) + k.yyx*sdf_drink(p + k.yyx*NRM_E)
                              + k.yxy*sdf_drink(p + k.yxy*NRM_E) + k.xxx*sdf_drink(p + k.xxx*NRM_E) ));
}

Vector normal_light(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_light(p + k.xyy*NRM_E) + k.yyx*sdf_light(p + k.yyx*NRM_E)
                              + k.yxy*sdf_light(p + k.yxy*NRM_E) + k.xxx*sdf_light(p + k.xxx*NRM_E) ));
}

Vector normal_room(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_room(p + k.xyy*NRM_E) + k.yyx*sdf_room(p + k.yyx*NRM_E)
                              + k.yxy*sdf_room(p + k.yxy*NRM_E) + k.xxx*sdf_room(p + k.xxx*NRM_E) ));
}


//---------------------------------------------------------------------
// the materials
//
// material_ gives the Surface plus this object's own Medium, and is used when
// the object owns the interface. medium_ gives only the Medium, and is used
// when the object is merely what lies on the far side.
//---------------------------------------------------------------------

Material cupMaterial(){
    return makeGlass(0.1*vec3(0.3, 0.05, 0.2), 1.5, 1.);
}

Material drinkMaterial(){
    vec3 brownAbsorb = vec3(1.) - vec3(204., 142., 105.)/255.;
    vec3 redAbsorb   = vec3(0.2, 1.0, 0.6);
    return makeGlass(3.*(brownAbsorb + 0.25*redAbsorb), 1.2, 1.);
}

Material material_cup(vec3 p, inout Vector n){ return cupMaterial(); }
Medium   medium_cup  (vec3 p){ return cupMaterial().interior; }

Material material_drink(vec3 p, inout Vector n){ return drinkMaterial(); }
Medium   medium_drink  (vec3 p){ return drinkMaterial().interior; }

Material material_light(vec3 p, inout Vector n){ return makeLight(vec3(0.9), 100.); }
Medium   medium_light  (vec3 p){ return defaultMedium(); }

//six wall materials out of one region: pick by which face the point is nearest.
//d is negative inside the room, and its largest component names the face.
//the six walls are a material FIELD over one region: roomFace() says which one.
//Set warmColor / coolColor equal to wallColor to make the room uniform.
Material material_room(vec3 p, inout Vector n){
    int face = roomFace(p - ROOM_C, ROOM_H);

    if(face == ROOM_CEILING){ return makeLight(vec3(1.), roomLight); }
    if(face == ROOM_FLOOR)  { return makeGloss(floorColor, 0., wallRough); }
    if(face == ROOM_LEFT)   { return makeGloss(warmColor,  0., wallRough); }
    if(face == ROOM_RIGHT)  { return makeGloss(coolColor,  0., wallRough); }
    return makeGloss(wallColor, 0., wallRough);
}
Medium medium_room(vec3 p){ return defaultMedium(); }


//---------------------------------------------------------------------
// the analytic intersections
// Acceleration only: these find the hit, the sdfs above still classify it.
//---------------------------------------------------------------------

//the ray is inside the box, so this is the distance at which it exits
float trace_room(Vector tv){
    return roomTrace(tv, ROOM_C, ROOM_H);
}

//---------------------------------------------------------------------
// the dispatchers
//---------------------------------------------------------------------

//every region's sdf at one point, exact. Organised by SHAPE, not by region:
//one shape can fill several slots, which is the point of a multi-material object.
void sdfAll(vec3 p){
    sdf_cocktail(p, gSDF[ID_CUP], gSDF[ID_DRINK]);
    gSDF[ID_LIGHT] = sdf_light(p);
    gSDF[ID_ROOM]  = sdf_room(p);
}

Vector normalOf(int id, vec3 p){
    if(id == ID_CUP)  { return normal_cup(p);   }
    if(id == ID_DRINK){ return normal_drink(p); }
    if(id == ID_LIGHT){ return normal_light(p); }
    return normal_room(p);
}

//no sheets in this scene: every object is a region with an interior
bool isSheet(int id){ return false; }

Material materialOf(int id, vec3 p, inout Vector n, bool front){
    if(id == ID_CUP)  { return material_cup(p, n);   }
    if(id == ID_DRINK){ return material_drink(p, n); }
    if(id == ID_LIGHT){ return material_light(p, n); }
    return material_room(p, n);
}

Medium mediumOf(int id, vec3 p){
    if(id == ID_CUP)  { return medium_cup(p);   }
    if(id == ID_DRINK){ return medium_drink(p); }
    if(id == ID_LIGHT){ return medium_light(p); }
    if(id == ID_ROOM) { return medium_room(p);  }
    return defaultMedium();      //ID_NONE: open air
}


//---------------------------------------------------------------------
// the entry points
//---------------------------------------------------------------------

void buildScene(){}

//the marched union: the room and the light are analytic, so they are not here
float sdf_Scene(Vector tv){
    vec3 p = tv.pos;

    float b = bound_glass(p);
    if(b > BOUND_MARGIN){ return b; }

    float cup, drink;
    sdf_cocktail(p, cup, drink);
    return min(cup, drink);
}

float trace_Scene(Vector tv){
    return min(trace_room(tv), sphereTrace(tv, LIGHT_P, LIGHT_R));
}
