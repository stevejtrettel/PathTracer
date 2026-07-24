//=====================================================================
// ROCK — one height field driving BOTH geometry and colour.
//
// The point of this scene: `rockHeight(q)` is called in exactly two places,
//
//     sdf_rock()       displaces the surface by it   (geometry, in the march)
//     material_rock()  colours the surface by it     (shading, at the hit)
//
// so the pale patches sit on the peaks and the rust sits in the valleys BY
// CONSTRUCTION. There is no second texture to line up, and no way for the two
// to drift apart — change the frequency knob and the colour follows the shape
// because they are the same function.
//
// That is why the library's unit is a scalar HEIGHT FIELD rather than a
// finished "rock material": a height field can be plugged into displacement,
// into colour, into a bump normal, or all three.
//
// Knobs: rockAmp (how far the surface moves), rockFreq (feature size),
//        tintDepth (how hard colour tracks height — 0 = flat grey stone).
//=====================================================================


#include ../../../glsl/shapes/sphere.glsl
#include ../../../glsl/shapes/room.glsl


const int ID_ROCK = 0;
const int ID_LAMP = 1;
const int ID_ROOM = 2;

const int N_OBJ = 3;
float gSDF[N_OBJ];


const vec3 ROOM_C = vec3(0., 6., 0.);
const vec3 ROOM_H = vec3(10., 6., 10.);

const vec3  ROCK_C = vec3(0., 2.3, 0.);
const float ROCK_R = 2.0;

const vec3  LAMP_C = vec3(-3.5, 8.5, 4.5);
const float LAMP_R = 1.0;


//---------------------------------------------------------------------
// THE HEIGHT FIELD — the whole scene turns on this one function
//---------------------------------------------------------------------
// roughly [-0.5, 0.5]. Positive is a peak, negative is a valley.
//
// fbm2 (2 octaves) rather than fbm (4): displacement is evaluated at every march
// step, and the extra octaves cost twice — more hashes AND more gradient, which
// lengthens the Lipschitz divisor below and so shortens every step.
float rockHeight(vec3 q){
    return fbm2(rockFreq*q) - 0.5;
}

//1 + the Lipschitz bound of the displacement, so the sum stays 1-Lipschitz and
//the over-relaxed marcher (MARCH_RELAX = 1.2) cannot step through the surface.
//For the 2-octave fbm2, |grad fbm2(f*q)| <= 2.01*f (see fields.glsl).
//
//This divisor slows the march EVERYWHERE it is applied, which is why bound_rock
//below matters: outside the bound the ray pays none of it.
float rockLip(){
    return 1.0 + 2.01*rockAmp*rockFreq;
}


//---------------------------------------------------------------------
// sdfs
//---------------------------------------------------------------------

//sphere + height field. Because the displacement lives INSIDE the sdf, the
//4-tap normal picks it up for free and the silhouette moves too — this is real
//geometry, not a bump map.
float sdf_rock(vec3 p){
    vec3  q = p - ROCK_C;
    float d = sphereDistance(q, ROCK_R);
    d += rockAmp*rockHeight(q);
    return d/rockLip();
}

float sdf_lamp(vec3 p){ return sphereDistance(p - LAMP_C, LAMP_R); }

float sdf_room(vec3 p){ return roomDistance(p - ROOM_C, ROOM_H); }


//---------------------------------------------------------------------
// bound — THE ACCELERATION STRUCTURE
//---------------------------------------------------------------------
// A cheap shape that never OVERestimates the distance to the real surface.
// sdf_Scene returns it instead of the real sdf whenever the ray is comfortably
// outside, so background rays evaluate no fbm AND pay no Lipschitz divisor.
// Since sdf_Scene here is only the rock, that is most of the frame.
//
// Bounds belong in sdf_Scene ONLY — sdfAll must stay exact, or the classifier's
// |sdf| < AT_THRESH test would stop recognising the object at its own surface.
//
// Inflated by the displacement: rockHeight is in [-0.5, 0.5], so the surface
// reaches ROCK_R + 0.5*rockAmp. Without that the bound shaves the peaks off.
float bound_rock(vec3 p){
    return sphereDistance(p - ROCK_C, ROCK_R + 0.5*rockAmp);
}


//---------------------------------------------------------------------
// normals — always the 4-tap of the object's own sdf, in world coordinates
//---------------------------------------------------------------------
const float NRM_E = 0.0002;

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
//---------------------------------------------------------------------

//THE CORRELATION. h is the same value that moved this piece of surface, so
//t = 0 is the floor of a valley and t = 1 is the top of a peak.
//  valleys — dark iron red, rough: where water sat and the stone stayed wet
//  peaks   — pale bleached grey, a little smoother: weathered and worn down
//A second octave breaks up the mapping so it does not read as a clean gradient.
Material material_rock(vec3 p, inout Vector n){
    vec3  q = p - ROCK_C;
    float h = rockHeight(q);
    float t = clamp(h + 0.5, 0., 1.);

    float grain = fbm(9.*q);                       //fine mottling, independent of height
    float w = clamp(mix(0.5, smoothstep(0.3, 0.72, t), tintDepth) + 0.12*(grain-0.5), 0., 1.);

    vec3 valley = vec3(0.40, 0.13, 0.07);
    vec3 peak   = vec3(0.80, 0.76, 0.70);
    vec3 col    = mix(valley, peak, w);

    return makeGloss(col, 0.02, mix(0.70, 0.32, w));   //peaks read slightly polished
}
Medium medium_rock(vec3 p){ return defaultMedium(); }

Material material_lamp(vec3 p, inout Vector n){
    return makeLight(vec3(1.0, 0.95, 0.88), lampPower);
}
Medium medium_lamp(vec3 p){ return defaultMedium(); }

//six wall materials from one region: pick by which face p is nearest
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
// analytic intersections (acceleration only)
//---------------------------------------------------------------------

float trace_room(Vector tv){
    return roomTrace(tv, ROOM_C, ROOM_H);
}

//---------------------------------------------------------------------
// dispatchers
//---------------------------------------------------------------------

void sdfAll(vec3 p){
    gSDF[ID_ROCK] = sdf_rock(p);
    gSDF[ID_LAMP] = sdf_lamp(p);
    gSDF[ID_ROOM] = sdf_room(p);
}

Vector normalOf(int id, vec3 p){
    if(id == ID_ROCK){ return normal_rock(p); }
    if(id == ID_LAMP){ return normal_lamp(p); }
    return normal_room(p);
}

//no sheets in this scene: every object is a region with an interior
bool isSheet(int id){ return false; }

Material materialOf(int id, vec3 p, inout Vector n, bool front){
    if(id == ID_ROCK){ return material_rock(p, n); }
    if(id == ID_LAMP){ return material_lamp(p, n); }
    return material_room(p, n);
}

Medium mediumOf(int id, vec3 p){
    if(id == ID_ROCK){ return medium_rock(p); }
    if(id == ID_LAMP){ return medium_lamp(p); }
    if(id == ID_ROOM){ return medium_room(p); }
    return defaultMedium();      //ID_NONE: open air
}


//---------------------------------------------------------------------
// entry points
//---------------------------------------------------------------------

void buildScene(){}

float sdf_Scene(Vector tv){
    vec3 p = tv.pos;                  //room and lamp are analytic, so only the rock marches
    float b = bound_rock(p);
    return (b > BOUND_MARGIN) ? b : sdf_rock(p);
}

float trace_Scene(Vector tv){
    return min(trace_room(tv), sphereTrace(tv, LAMP_C, LAMP_R));
}
