//=====================================================================
// GLASSBALL — one glass sphere in a room. The speed baseline.
//
// Deliberately the cheapest scene the engine can express:
//   * both the ball and the room are ANALYTIC, so trace_Scene finds every hit
//     and sdf_Scene returns maxDist — the marcher never takes a step
//   * sdfAll is two cheap sdfs (a length and a box), used only to classify
//
// So whatever this measures is the cost of the classifier, the scatter tree and
// the LocalData refill, with the marcher taken out of the picture entirely. If
// this is slow, the problem is not geometry.
//
// The room, the key light, the camera and roomLight are copied from
// scenes/cocktail, so the two differ ONLY in the glass object.
//=====================================================================


#include ../../../glsl/shapes/sphere.glsl
#include ../../../glsl/shapes/room.glsl


//--- the objects, in declaration order (= containment priority, inner to outer)
const int ID_BALL  = 0;
const int ID_LIGHT = 1;
const int ID_ROOM  = 2;

const int N_OBJ = 3;
float gSDF[N_OBJ];


//--- placement -------------------------------------------------------
const vec3  BALL_P = vec3(-1.0, 1.1, -1.2);
const float BALL_R = 1.2;

const vec3  LIGHT_P = vec3(-7.0, 4.0, 2.0);
const float LIGHT_R = 1.5;

//room interior: x in [-20, 8.5], y in [-1, 14], z in [-20, 10]
const vec3 ROOM_C = vec3(-5.75, 6.5, -5.0);
const vec3 ROOM_H = vec3(14.25, 7.5, 15.0);


//---------------------------------------------------------------------
// the region sdfs
// Exact, and used only by the classifier and the normals — the marcher never
// calls them, since everything here is traced.
//---------------------------------------------------------------------

float sdf_ball(vec3 p){
    return sphereDistance(p - BALL_P, BALL_R);
}

float sdf_light(vec3 p){
    return sphereDistance(p - LIGHT_P, LIGHT_R);
}

//the room SOLID is everything outside the box, so its interior is open air and
//regionAt() returns ID_NONE there
float sdf_room(vec3 p){
    return roomDistance(p - ROOM_C, ROOM_H);
}


//---------------------------------------------------------------------
// the normals — the 4-tap of each region's own sdf, in world coordinates
//---------------------------------------------------------------------
const float NRM_E = 0.0002;

Vector normal_ball(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_ball(p + k.xyy*NRM_E) + k.yyx*sdf_ball(p + k.yyx*NRM_E)
                              + k.yxy*sdf_ball(p + k.yxy*NRM_E) + k.xxx*sdf_ball(p + k.xxx*NRM_E) ));
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
//---------------------------------------------------------------------

Material ballMaterial(){
    return makeGlass(0.1*vec3(0.3, 0.05, 0.2), 1.5, 1.);
}

Material material_ball(vec3 p, inout Vector n){ return ballMaterial(); }
Medium   medium_ball  (vec3 p){ return ballMaterial().interior; }

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
// the analytic intersections — here they find EVERY hit in the scene
//---------------------------------------------------------------------

//the ray is inside the box, so this is the distance at which it exits
float trace_room(Vector tv){
    return roomTrace(tv, ROOM_C, ROOM_H);
}


//---------------------------------------------------------------------
// the dispatchers
//---------------------------------------------------------------------

void sdfAll(vec3 p){
    gSDF[ID_BALL]  = sdf_ball(p);
    gSDF[ID_LIGHT] = sdf_light(p);
    gSDF[ID_ROOM]  = sdf_room(p);
}

Vector normalOf(int id, vec3 p){
    if(id == ID_BALL) { return normal_ball(p);  }
    if(id == ID_LIGHT){ return normal_light(p); }
    return normal_room(p);
}

//no sheets in this scene: every object is a region with an interior
bool isSheet(int id){ return false; }

Material materialOf(int id, vec3 p, inout Vector n, bool front){
    if(id == ID_BALL) { return material_ball(p, n);  }
    if(id == ID_LIGHT){ return material_light(p, n); }
    return material_room(p, n);
}

Medium mediumOf(int id, vec3 p){
    if(id == ID_BALL) { return medium_ball(p);  }
    if(id == ID_LIGHT){ return medium_light(p); }
    if(id == ID_ROOM) { return medium_room(p);  }
    return defaultMedium();      //ID_NONE: open air
}


//---------------------------------------------------------------------
// the entry points
//---------------------------------------------------------------------

void buildScene(){}

//nothing marches: every surface here has a closed-form intersection
float sdf_Scene(Vector tv){
    return maxDist;
}

float trace_Scene(Vector tv){
    float d = maxDist;
    d = min(d, sphereTrace(tv, BALL_P,  BALL_R));
    d = min(d, sphereTrace(tv, LIGHT_P, LIGHT_R));
    d = min(d, trace_room(tv));
    return d;
}
