//=====================================================================
// PROTO — the first scene of the region system, HAND-WRITTEN.
//
// This is the target the generator has to reproduce. Every object here is one
// REGION of space and supplies six functions of a world point:
//
//     sdf_<name>      signed distance, negative inside
//     normal_<name>   4-tap of that sdf (always — no analytic normals)
//     material_<name> Surface + this object's own Medium; may perturb n
//     medium_<name>   Medium only, for when it is merely the far side
//     trace_<name>    analytic intersection            [optional]
//     bound_<name>    conservative underestimate       [optional, unused here]
//
// plus the four dispatchers (sdfAll / normalOf / materialOf / mediumOf) and the
// two entry points (sdf_Scene / trace_Scene). setData_Scene is ENGINE code —
// see 5Scene/scene.glsl — and is not written here at all.
//
// Declaration order is priority: INNER TO OUTER, and at a wall shared by two
// objects the earlier-declared one owns the Surface. `cup` precedes `drink` so
// the glass, not the liquid, gives the shared wall its finish.
//
// What each object is here to prove:
//   cup + drink   the classifier — a shared wall (both sdfs vanish), front/back
//                 media, the IOR ratio, and the waterline falling out of max()
//   marble        material_ as a genuine field of position
//   rock          sdf_ composition: displacement the 4-tap normal picks up free
//   lamp          a traced region — trace as acceleration, sdf as truth
//   room          one region, six wall materials, by position
//=====================================================================


//---------------------------------------------------------------------
// object ids — declaration order IS containment priority
#include ../../../glsl/shapes/sphere.glsl
#include ../../../glsl/shapes/room.glsl


//---------------------------------------------------------------------
const int ID_CUP    = 0;
const int ID_DRINK  = 1;
const int ID_MARBLE = 2;
const int ID_ROCK   = 3;
const int ID_LAMP   = 4;
const int ID_ROOM   = 5;

const int N_OBJ = 6;
float gSDF[N_OBJ];


//---------------------------------------------------------------------
// placement + shape constants
//---------------------------------------------------------------------
const vec3 ROOM_C = vec3(0., 6., 0.);    //room interior: x,z in [-10,10], y in [0,12]
const vec3 ROOM_H = vec3(10., 6., 10.);

const vec3  CUP_C   = vec3(-2.9, 1.3, 0.);
const float CUP_R   = 1.1;               //outer radius
const float CUP_H   = 1.3;               //outer half-height
const float CAV_R   = 0.95;              //cavity radius  -> 0.15 wall
const float CAV_H   = 1.15;              //cavity half-height
const float CAV_Y   = 0.3;               //cavity centre, raised to leave a base
const float WATER_Y = 0.5;               //waterline, in cup-local y

const vec3  MARBLE_C = vec3(0., 1.3, 0.);
const float MARBLE_R = 1.3;

const vec3  ROCK_C = vec3(2.9, 1.35, 0.);
const float ROCK_R = 1.05;
const float ROCK_AMP  = 0.18;            //displacement amplitude
const float ROCK_FREQ = 2.5;
//1 + the Lipschitz bound of the displacement, so the sum stays 1-Lipschitz and
//the over-relaxed marcher cannot step through the surface. fbm2 is 2 octaves:
//|grad fbm2(f*q)| <= 2.01*f (see fields.glsl). Under-estimating this is not
//"a bit slow" — it lets the marcher miss the surface — but note the divisor
//slows the march EVERYWHERE, which is why the bound below matters so much.
const float ROCK_LIP  = 1. + ROCK_AMP*2.01*ROCK_FREQ;

const vec3  LAMP_C = vec3(-1.5, 8.2, 3.5);
const float LAMP_R = 0.9;


//---------------------------------------------------------------------
// sdfs
//---------------------------------------------------------------------

// The cup and the drink are TWO REGIONS OF ONE SHAPE, so they come out of one
// evaluation: the glass is the outer cylinder with the cavity carved out, and
// the drink is that same cavity cut off at the waterline. Splitting them into
// two independent sdfs would evaluate the cavity twice for no reason.
//
// They share the cavity wall EXACTLY — that shared zero is what lets the
// marcher stop on an interface interior to the union (see 5Scene/scene.glsl).
// Above the waterline max() picks the plane, so the drink is simply not there.
void sdf_tumbler(vec3 p, out float cup, out float drink){
    vec3  q      = p - CUP_C;
    float outer  = cylinderDist(q, CUP_R, CUP_H, 0.08);
    float cavity = cylinderDist(q - vec3(0., CAV_Y, 0.), CAV_R, CAV_H, 0.05);
    cup   = max(outer, -cavity);
    drink = max(cavity, q.y - WATER_Y);
}

//single-region entry points, for the 4-tap normals below
float sdf_cup(vec3 p){   float cup, drink; sdf_tumbler(p, cup, drink); return cup;   }
float sdf_drink(vec3 p){ float cup, drink; sdf_tumbler(p, cup, drink); return drink; }

float sdf_marble(vec3 p){
    return sphereDistance(p - MARBLE_C, MARBLE_R);
}

//sphere + lumps. The displacement is INSIDE the sdf, so the 4-tap normal picks
//it up with no extra machinery, and at() / inside() stay consistent with it.
float sdf_rock(vec3 p){
    vec3  q = p - ROCK_C;
    float d = sphereDistance(q, ROCK_R);
    d += ROCK_AMP*(fbm2(ROCK_FREQ*q) - 0.5);
    return d/ROCK_LIP;
}

float sdf_lamp(vec3 p){
    return sphereDistance(p - LAMP_C, LAMP_R);
}

//the room SOLID is everything OUTSIDE the box, so the interior is open air and
//regionAt() returns ID_NONE there.
float sdf_room(vec3 p){
    return roomDistance(p - ROOM_C, ROOM_H);
}


//---------------------------------------------------------------------
// bounds — THE ACCELERATION STRUCTURE
//---------------------------------------------------------------------
// A bound is a cheap shape that never OVERestimates the distance to the real
// surface. sdf_Scene returns it instead of the real sdf whenever the ray is
// comfortably outside, so a ray that is nowhere near the rock never evaluates a
// single fbm — and, just as importantly, never pays the Lipschitz divisor.
//
// Bounds live in sdf_Scene ONLY. sdfAll must stay exact: the classifier tests
// |sdf| < AT_THRESH, so a short-circuited sdf there would stop the object being
// recognised at its own surface and every hit on it would come back ID_NONE.
//
// Exact cheap primitives (the marble sphere) get no bound: their sdf already IS
// the bound, so a guard would be pure overhead.

//one cylinder around the glass AND its drink — the drink lives inside the glass,
//so a group bound culls both at once
float bound_glass(vec3 p){
    return bCyl(p - CUP_C, vec2(CUP_R + 0.15, CUP_H + 0.15));
}

//inflated by the displacement, or the bound would shave the lumps off the rock
float bound_rock(vec3 p){
    return sphereDistance(p - ROCK_C, ROCK_R + 0.5*ROCK_AMP);
}


//---------------------------------------------------------------------
// normals — always the 4-tap, in WORLD coordinates.
// Differentiating the world function gives the world normal directly: any
// transform baked into the sdf is handled by the chain rule, so there are no
// inverse-transpose fixups anywhere.
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
Vector normal_marble(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_marble(p + k.xyy*NRM_E) + k.yyx*sdf_marble(p + k.yyx*NRM_E)
                              + k.yxy*sdf_marble(p + k.yxy*NRM_E) + k.xxx*sdf_marble(p + k.xxx*NRM_E) ));
}
Vector normal_rock(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_rock(p + k.xyy*NRM_E) + k.yyx*sdf_rock(p + k.yyx*NRM_E)
                              + k.yxy*sdf_rock(p + k.yxy*NRM_E) + k.xxx*sdf_rock(p + k.xxx*NRM_E) ));
}
Vector normal_lamp(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_lamp(p + k.xyy*NRM_E) + k.yyx*sdf_lamp(p + k.yyx*NRM_E)
                              + k.yxy*sdf_lamp(p + k.yxy*NRM_E) + k.xxx*sdf_lamp(p + k.xxx*NRM_E) ));
}
Vector normal_room(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_room(p + k.xyy*NRM_E) + k.yyx*sdf_room(p + k.yyx*NRM_E)
                              + k.yxy*sdf_room(p + k.yxy*NRM_E) + k.xxx*sdf_room(p + k.xxx*NRM_E) ));
}


//---------------------------------------------------------------------
// materials
// material_ = Surface + this object's own Medium (used when it owns the hit)
// medium_   = Medium only (used when it is merely the far side)
//---------------------------------------------------------------------

//the two glass media are constants, so material_ and medium_ share one builder.
//A field-valued material (see marble below) would write the two separately —
//which is the point of the split: the far side never runs the surface half.
Material cupMat()  { return makeGlass(absorbFor(vec3(0.86, 0.90, 0.88), 1.2), 1.5, 1.0); }
Material drinkMat(){ return makeGlass(absorbFor(vec3(0.75, 0.22, 0.12), 0.8), 1.34, 1.0); }

Material material_cup(vec3 p, inout Vector n){ return cupMat(); }
Medium   medium_cup  (vec3 p){ return cupMat().interior; }

Material material_drink(vec3 p, inout Vector n){ return drinkMat(); }
Medium   medium_drink  (vec3 p){ return drinkMat().interior; }

//A FIELD, not a constant: the veining is a function of position, sampled fresh
//at every hit. This is the whole point of material_ taking p.
Material material_marble(vec3 p, inout Vector n){
    return marbleField(p - MARBLE_C, 3.5, polish);
}
Medium medium_marble(vec3 p){ return defaultMedium(); }

Material material_rock(vec3 p, inout Vector n){
    vec3 q = p - ROCK_C;
    vec3 tone = mix(vec3(0.38,0.35,0.32), vec3(0.55,0.52,0.47), fbm(4.*q));
    return makeGloss(tone, 0.03, 0.55);
}
Medium medium_rock(vec3 p){ return defaultMedium(); }

Material material_lamp(vec3 p, inout Vector n){
    return makeLight(vec3(1.0, 0.94, 0.86), lampPower);
}
Medium medium_lamp(vec3 p){ return defaultMedium(); }

//SIX WALL MATERIALS from one region: pick by which face the point is on.
//d is negative inside; the LARGEST component is the nearest face.
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
// analytic intersections (optional; acceleration only)
//---------------------------------------------------------------------

//the ray is inside the box: distance to the wall it exits through
float trace_room(Vector tv){
    return roomTrace(tv, ROOM_C, ROOM_H);
}

//---------------------------------------------------------------------
// the dispatchers
//---------------------------------------------------------------------

//organised by SHAPE, not by region: one shape can fill several slots, which is
//the point of a multi-material object
void sdfAll(vec3 p){
    sdf_tumbler(p, gSDF[ID_CUP], gSDF[ID_DRINK]);
    gSDF[ID_MARBLE] = sdf_marble(p);
    gSDF[ID_ROCK]   = sdf_rock(p);
    gSDF[ID_LAMP]   = sdf_lamp(p);
    gSDF[ID_ROOM]   = sdf_room(p);
}

Vector normalOf(int id, vec3 p){
    if(id == ID_CUP)   { return normal_cup(p);    }
    if(id == ID_DRINK) { return normal_drink(p);  }
    if(id == ID_MARBLE){ return normal_marble(p); }
    if(id == ID_ROCK)  { return normal_rock(p);   }
    if(id == ID_LAMP)  { return normal_lamp(p);   }
    return normal_room(p);
}

//no sheets in this scene: every object is a region with an interior
bool isSheet(int id){ return false; }

Material materialOf(int id, vec3 p, inout Vector n, bool front){
    if(id == ID_CUP)   { return material_cup(p, n);    }
    if(id == ID_DRINK) { return material_drink(p, n);  }
    if(id == ID_MARBLE){ return material_marble(p, n); }
    if(id == ID_ROCK)  { return material_rock(p, n);   }
    if(id == ID_LAMP)  { return material_lamp(p, n);   }
    return material_room(p, n);
}

Medium mediumOf(int id, vec3 p){
    if(id == ID_CUP)   { return medium_cup(p);    }
    if(id == ID_DRINK) { return medium_drink(p);  }
    if(id == ID_MARBLE){ return medium_marble(p); }
    if(id == ID_ROCK)  { return medium_rock(p);   }
    if(id == ID_LAMP)  { return medium_lamp(p);   }
    if(id == ID_ROOM)  { return medium_room(p);   }
    return defaultMedium();      //ID_NONE: open air
}


//---------------------------------------------------------------------
// the two entry points the tracer marches
// sdf_Scene is the MARCHED union: room and lamp are analytic, so they are not
// in it. They are still in sdfAll — trace finds the hit, sdfs classify it.
//---------------------------------------------------------------------

void buildScene(){}

float sdf_Scene(Vector tv){
    vec3 p = tv.pos;
    float d = maxDist;

    //--- glass + drink: one group bound over both, since the drink lives
    //    inside the glass
    float bg = bound_glass(p);
    if(bg > BOUND_MARGIN){ d = min(d, bg); }
    else{
        float cup, drink;
        sdf_tumbler(p, cup, drink);
        d = min(d, min(cup, drink));
    }

    //--- marble: already an exact sphere, no bound worth adding
    d = min(d, sdf_marble(p));

    //--- rock: the expensive one. Outside the bound, no fbm and no divisor.
    float br = bound_rock(p);
    d = min(d, (br > BOUND_MARGIN) ? br : sdf_rock(p));

    return d;
}

float trace_Scene(Vector tv){
    float d = maxDist;
    d = min(d, trace_room(tv));
    d = min(d, sphereTrace(tv, LAMP_C, LAMP_R));
    return d;
}
