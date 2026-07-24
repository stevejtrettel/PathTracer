//=====================================================================
// TRANSFORM — a rotated, non-uniformly scaled body, and a lattice.
//
// Every object in every scene so far has sat at an axis-aligned offset:
// p - CENTRE, no rotation, no scale. So two claims from the design have never
// actually been tested, and this scene exists to test them.
//
// CLAIM 1 — normals need no inverse-transpose fixup.
//   The 4-tap differentiates the WORLD sdf, so any transform baked inside it is
//   handled by the chain rule. If that is right, the ellipsoid below shades and
//   reflects like an ellipsoid with no correction anywhere. If it is wrong, its
//   highlight will sit where a SPHERE's would, and the old scenes' hand-written
//   `normal.dir.y *= STRETCH_H` was load-bearing after all.
//   It is polished metal precisely because a reflection makes a bad normal obvious.
//
// CLAIM 2 — a non-uniform transform needs one Lipschitz factor.
//   sdf(M*p) is not a distance in world units. Its Lipschitz constant is the
//   LARGEST singular value of M, so dividing by that restores a conservative
//   underestimate. For a pure scale that is 1/min(scale), i.e. multiply by the
//   smallest component.
//
// The lattice is the other new thing: ONE region made of many copies, via
// opRepLim. It gets a single group bound over the whole grid, and the classifier
// names it as one object — which is what scenes/primitives used to fake with
// twenty hand-written lines.
//
// Room, light and camera are shared with cocktail/glassball/subsurface.
//=====================================================================


#include ../../../glsl/shapes/sphere.glsl
#include ../../../glsl/shapes/room.glsl


//--- the objects, in declaration order (= containment priority, inner to outer)
const int ID_BODY  = 0;
const int ID_BEADS = 1;
const int ID_LIGHT = 2;
const int ID_ROOM  = 3;

const int N_OBJ = 4;
float gSDF[N_OBJ];


//--- placement -------------------------------------------------------

//the body: a unit sphere scaled anisotropically, then rotated, then placed
const vec3  BODY_P     = vec3(-1.0, 1.2, -1.2);
const vec3  BODY_SCALE = vec3(1.5, 0.65, 1.0);
const vec3  BODY_AXIS  = vec3(0.25, 1.0, 0.15);

//the lattice: a 5 x 1 x 3 grid of beads sitting on the floor (y = -1)
const vec3  BEADS_P       = vec3(2.6, -0.68, 0.5);
const float BEADS_SPACING = 1.0;
const vec3  BEADS_LIMIT   = vec3(2., 0., 1.);
const float BEADS_R       = 0.32;

const vec3  LIGHT_P = vec3(-7.0, 4.0, 2.0);
const float LIGHT_R = 1.5;

//room interior: x in [-20, 8.5], y in [-1, 14], z in [-20, 10]
const vec3 ROOM_C = vec3(-5.75, 6.5, -5.0);
const vec3 ROOM_H = vec3(14.25, 7.5, 15.0);


//---------------------------------------------------------------------
// the region sdfs
//---------------------------------------------------------------------

// World -> local for the body: undo the placement, then the rotation, then the
// scale. GLSL applies the transpose of a mat3 as v*M, which is the inverse of
// a rotation, so no explicit inverse is needed.
vec3 toBodyLocal(vec3 p){
    mat3 rot = rot3AxisAngle(normalize(BODY_AXIS), spin);
    return ((p - BODY_P) * rot) / BODY_SCALE;
}

// The unit sphere in that local chart is an ellipsoid in the world. Multiplying
// by the smallest scale component divides out the map's largest singular value,
// which keeps the result a conservative underestimate of the true distance.
float sdf_body(vec3 p){
    float d = length(toBodyLocal(p)) - 1.0;
    return d * min(BODY_SCALE.x, min(BODY_SCALE.y, BODY_SCALE.z));
}

// ONE region, many copies. opRepLim folds the whole grid onto a single cell, so
// the sdf below is evaluated once no matter how many beads there are.
float sdf_beads(vec3 p){
    vec3 q = opRepLim(p - BEADS_P, BEADS_SPACING, BEADS_LIMIT);
    return sphereDistance(q, BEADS_R);
}

float sdf_light(vec3 p){ return sphereDistance(p - LIGHT_P, LIGHT_R); }

//the room SOLID is everything outside the box, so its interior is open air and
//regionAt() returns ID_NONE there
float sdf_room(vec3 p){ return roomDistance(p - ROOM_C, ROOM_H); }


//---------------------------------------------------------------------
// the bounds — our acceleration structure for the marcher
//---------------------------------------------------------------------

//a sphere of the body's LARGEST semi-axis encloses it whatever the rotation
float bound_body(vec3 p){
    return sphereDistance(p - BODY_P, max(BODY_SCALE.x, max(BODY_SCALE.y, BODY_SCALE.z)));
}

//one box over the whole lattice: the outermost cell centre plus a bead radius
float bound_beads(vec3 p){
    return bBox(p - BEADS_P, BEADS_SPACING*BEADS_LIMIT + vec3(BEADS_R));
}


//---------------------------------------------------------------------
// the normals — the 4-tap of each region's own sdf, in WORLD coordinates.
// Note there is no transform correction here of any kind: that is claim 1.
//---------------------------------------------------------------------
const float NRM_E = 0.0002;

Vector normal_body(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_body(p + k.xyy*NRM_E) + k.yyx*sdf_body(p + k.yyx*NRM_E)
                              + k.yxy*sdf_body(p + k.yxy*NRM_E) + k.xxx*sdf_body(p + k.xxx*NRM_E) ));
}
Vector normal_beads(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_beads(p + k.xyy*NRM_E) + k.yyx*sdf_beads(p + k.yyx*NRM_E)
                              + k.yxy*sdf_beads(p + k.yxy*NRM_E) + k.xxx*sdf_beads(p + k.xxx*NRM_E) ));
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

//polished metal: a reflection shows a wrong normal immediately
Material material_body(vec3 p, inout Vector n){
    return makeMetal(vec3(0.92, 0.80, 0.52), 1., bodyRough);
}
Medium medium_body(vec3 p){ return defaultMedium(); }

//the pattern is a function of LOCAL position inside the repeated cell, so every
//bead is identical — swap toBeadLocal for p and it would vary across the grid
Material material_beads(vec3 p, inout Vector n){
    return makeGloss(vec3(0.78, 0.26, 0.22), 0.1, 0.2);
}
Medium medium_beads(vec3 p){ return defaultMedium(); }

Material material_light(vec3 p, inout Vector n){ return makeLight(vec3(0.9), 100.); }
Medium   medium_light  (vec3 p){ return defaultMedium(); }

//six wall materials out of one region: pick by which face the point is nearest
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
//---------------------------------------------------------------------

//the ray is inside the box, so this is the distance at which it exits
float trace_room(Vector tv){
    return roomTrace(tv, ROOM_C, ROOM_H);
}


//---------------------------------------------------------------------
// the dispatchers
//---------------------------------------------------------------------

void sdfAll(vec3 p){
    gSDF[ID_BODY]  = sdf_body(p);
    gSDF[ID_BEADS] = sdf_beads(p);
    gSDF[ID_LIGHT] = sdf_light(p);
    gSDF[ID_ROOM]  = sdf_room(p);
}

Vector normalOf(int id, vec3 p){
    if(id == ID_BODY) { return normal_body(p);  }
    if(id == ID_BEADS){ return normal_beads(p); }
    if(id == ID_LIGHT){ return normal_light(p); }
    return normal_room(p);
}

//no sheets in this scene: every object is a region with an interior
bool isSheet(int id){ return false; }

Material materialOf(int id, vec3 p, inout Vector n, bool front){
    if(id == ID_BODY) { return material_body(p, n);  }
    if(id == ID_BEADS){ return material_beads(p, n); }
    if(id == ID_LIGHT){ return material_light(p, n); }
    return material_room(p, n);
}

Medium mediumOf(int id, vec3 p){
    if(id == ID_BODY) { return medium_body(p);  }
    if(id == ID_BEADS){ return medium_beads(p); }
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
    float d = maxDist;

    float bb = bound_body(p);
    d = min(d, (bb > BOUND_MARGIN) ? bb : sdf_body(p));

    float bl = bound_beads(p);
    d = min(d, (bl > BOUND_MARGIN) ? bl : sdf_beads(p));

    return d;
}

float trace_Scene(Vector tv){
    return min(trace_room(tv), sphereTrace(tv, LIGHT_P, LIGHT_R));
}
