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
//1 + the Lipschitz bound of the displacement. fbm sums four octaves whose
//amplitude halves while frequency doubles, so every octave contributes the SAME
//gradient (that is what makes it a 1/f fractal): with valueNoise's smoothstep
//derivative capped at 1.5, |grad fbm(f*q)| <= 3.06*f. Hence amp*3.06*freq.
//Under-estimating this is not "a bit slow", it lets the over-relaxed marcher
//step through the surface — but note the divisor slows the march EVERYWHERE,
//which is why the bound below matters so much.
const float ROCK_LIP  = 1. + ROCK_AMP*3.06*ROCK_FREQ;

const vec3  LAMP_C = vec3(-1.5, 8.2, 3.5);
const float LAMP_R = 0.9;


//---------------------------------------------------------------------
// sdfs
//---------------------------------------------------------------------

//the glass shell: outer cylinder with the cavity carved out of it.
//cup and drink share the cavity wall EXACTLY — that shared zero is what lets
//the marcher stop on an interface interior to the union (see scene.glsl).
float sdf_cup(vec3 p){
    vec3  q      = p - CUP_C;
    float outer  = cylinderDist(q, CUP_R, CUP_H, 0.08);
    float cavity = cylinderDist(q - vec3(0., CAV_Y, 0.), CAV_R, CAV_H, 0.05);
    return max(outer, -cavity);
}

//the liquid: the cavity, intersected with everything below the waterline.
//Above the line max() picks the plane, so the drink is simply NOT THERE — the
//"did we hit the cup near the drink?" branch of the old code is this max().
float sdf_drink(vec3 p){
    vec3  q      = p - CUP_C;
    float cavity = cylinderDist(q - vec3(0., CAV_Y, 0.), CAV_R, CAV_H, 0.05);
    return max(cavity, q.y - WATER_Y);
}

float sdf_marble(vec3 p){
    return length(p - MARBLE_C) - MARBLE_R;
}

//sphere + lumps. The displacement is INSIDE the sdf, so the 4-tap normal picks
//it up with no extra machinery, and at() / inside() stay consistent with it.
float sdf_rock(vec3 p){
    vec3  q = p - ROCK_C;
    float d = length(q) - ROCK_R;
    d += ROCK_AMP*(fbm(ROCK_FREQ*q) - 0.5);
    return d/ROCK_LIP;
}

float sdf_lamp(vec3 p){
    return length(p - LAMP_C) - LAMP_R;
}

//the room SOLID is everything OUTSIDE the box, so the interior is open air and
//regionAt() returns ID_NONE there.
float sdf_room(vec3 p){
    return -bBox(p - ROOM_C, ROOM_H);
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
    return length(p - ROCK_C) - (ROCK_R + 0.5*ROCK_AMP);
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
Material material_room(vec3 p, inout Vector n){
    vec3 q = p - ROOM_C;
    vec3 d = abs(q) - ROOM_H;

    if(d.y >= d.x && d.y >= d.z){
        if(q.y > 0.){ return makeLight(vec3(1.0, 0.97, 0.92), roomLight); }   //ceiling
        return makeGloss(vec3(0.62), 0.0, 0.35);                              //floor
    }
    if(d.x >= d.z){
        if(q.x > 0.){ return makeGloss(vec3(0.30, 0.36, 0.58), 0.0, 0.4); }   //right, cool
        return makeGloss(vec3(0.58, 0.32, 0.30), 0.0, 0.4);                   //left, warm
    }
    if(q.z > 0.){ return makeGloss(vec3(0.46, 0.45, 0.43), 0.0, 0.4); }       //back
    return makeGloss(vec3(0.40), 0.0, 0.4);                                   //front
}
Medium medium_room(vec3 p){ return defaultMedium(); }


//---------------------------------------------------------------------
// analytic intersections (optional; acceleration only)
//---------------------------------------------------------------------

//the ray is inside the box: distance to the wall it exits through
float trace_room(Vector tv){
    vec3 o = tv.pos - ROOM_C;
    vec3 t1 = (-ROOM_H - o)/tv.dir;
    vec3 t2 = ( ROOM_H - o)/tv.dir;
    vec3 tm = max(t1, t2);
    float t = min(tm.x, min(tm.y, tm.z));
    if(t < 0.){ return maxDist; }
    return min(t, maxDist);
}

float trace_lamp(Vector tv){
    vec3 oc = tv.pos - LAMP_C;
    float b = dot(oc, tv.dir);
    float c = dot(oc, oc) - LAMP_R*LAMP_R;
    float disc = b*b - c;
    if(disc < 0.){ return maxDist; }
    float s = sqrt(disc);
    float t = -b - s;
    if(t < 0.){ t = -b + s; }
    if(t < 0.){ return maxDist; }
    return min(t, maxDist);
}


//---------------------------------------------------------------------
// the dispatchers
//---------------------------------------------------------------------

void sdfAll(vec3 p){
    gSDF[ID_CUP]    = sdf_cup(p);
    gSDF[ID_DRINK]  = sdf_drink(p);
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

Material materialOf(int id, vec3 p, inout Vector n){
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
        d = min(d, sdf_cup(p));
        d = min(d, sdf_drink(p));
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
    d = min(d, trace_lamp(tv));
    return d;
}
