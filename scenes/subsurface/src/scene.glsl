//=====================================================================
// SUBSURFACE — three balls, testing the medium walk and nested regions.
//
// Nothing written so far has had mfp < maxDist, so the medium walk has not run
// once since the rewrite. This is its first exercise, and the three balls
// isolate the failure modes from each other:
//
//   glass   clear, ballistic         the control: the path we already trust
//   wax     scattering interior      the walk itself — path.region tracking,
//                                    bisect to the wall, exit Fresnel and TIR
//   shell   a scattering CORE inside a glass ball
//
// The third is the interesting one. It is the first NESTED pair, so it hits
// three things nothing else does:
//
//   * the classifier's CONTAINMENT branch — at the core's surface only the
//     core's sdf vanishes, and the far side is "the innermost object that
//     contains this point", i.e. the shell. Cocktail only ever exercises the
//     other branch, where two sdfs vanish at a shared wall.
//   * an interface between two NON-AIR media, so the Fresnel there comes from
//     the ratio of the core's and shell's indices.
//   * a walk inside a nested region, which has to stop at the CORE's wall and
//     not at the shell's — the case a global "inside any object?" test gets
//     wrong, and the reason insideOf() is emitted per region.
//
// Every ball is analytic, so sdf_Scene returns maxDist and nothing marches:
// what this measures is the walk, not the marcher. Room, light and camera are
// shared with scenes/cocktail and scenes/glassball for comparison.
//=====================================================================


#include ../../../glsl/shapes/sphere.glsl
#include ../../../glsl/shapes/room.glsl


//--- the objects, in declaration order (= containment priority, INNER TO OUTER)
const int ID_CORE  = 0;      //nested inside SHELL, so it must come first
const int ID_SHELL = 1;
const int ID_WAX   = 2;
const int ID_GLASS = 3;
const int ID_LIGHT = 4;
const int ID_ROOM  = 5;

const int N_OBJ = 6;
float gSDF[N_OBJ];


//--- placement -------------------------------------------------------
const vec3  GLASS_P = vec3(-4.0, 1.3, -1.2);
const float GLASS_R = 1.3;

const vec3  WAX_P = vec3(-1.0, 1.3, -1.2);
const float WAX_R = 1.3;

const vec3  SHELL_P = vec3(2.0, 1.3, -1.2);
const float SHELL_R = 1.3;
const float CORE_R  = 0.8;          //concentric with the shell

const vec3  LIGHT_P = vec3(-7.0, 4.0, 2.0);
const float LIGHT_R = 1.5;

//room interior: x in [-20, 8.5], y in [-1, 14], z in [-20, 10]
const vec3 ROOM_C = vec3(-5.75, 6.5, -5.0);
const vec3 ROOM_H = vec3(14.25, 7.5, 15.0);


//---------------------------------------------------------------------
// the region sdfs
//---------------------------------------------------------------------

float sdf_core (vec3 p){ return sphereDistance(p - SHELL_P, CORE_R);  }
float sdf_shell(vec3 p){ return sphereDistance(p - SHELL_P, SHELL_R); }
float sdf_wax  (vec3 p){ return sphereDistance(p - WAX_P, WAX_R);   }
float sdf_glass(vec3 p){ return sphereDistance(p - GLASS_P, GLASS_R); }
float sdf_light(vec3 p){ return sphereDistance(p - LIGHT_P, LIGHT_R); }

//the room SOLID is everything outside the box, so its interior is open air and
//regionAt() returns ID_NONE there
float sdf_room(vec3 p){ return roomDistance(p - ROOM_C, ROOM_H); }


//---------------------------------------------------------------------
// which region contains a point
//
// Only needed because this scene scatters (see SCENE_SUBSURFACE in its
// settings). Each test names ONLY the regions actually nested inside it, which
// is what makes it cheap: the medium walk calls this once per scatter step and
// sixteen times per boundary crossing.
//---------------------------------------------------------------------

bool inside_core (vec3 p){ return sdf_core(p)  < 0.; }
bool inside_wax  (vec3 p){ return sdf_wax(p)   < 0.; }
bool inside_glass(vec3 p){ return sdf_glass(p) < 0.; }
bool inside_light(vec3 p){ return sdf_light(p) < 0.; }
bool inside_room (vec3 p){ return sdf_room(p)  < 0.; }

//the core sits inside the shell, so the shell's interior EXCLUDES it. This is
//the one line a general "sdf < 0" test would get wrong.
bool inside_shell(vec3 p){ return sdf_shell(p) < 0. && sdf_core(p) >= 0.; }


//---------------------------------------------------------------------
// the normals — the 4-tap of each region's own sdf, in world coordinates
//---------------------------------------------------------------------
const float NRM_E = 0.0002;

Vector normal_core(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_core(p + k.xyy*NRM_E) + k.yyx*sdf_core(p + k.yyx*NRM_E)
                              + k.yxy*sdf_core(p + k.yxy*NRM_E) + k.xxx*sdf_core(p + k.xxx*NRM_E) ));
}
Vector normal_shell(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_shell(p + k.xyy*NRM_E) + k.yyx*sdf_shell(p + k.yyx*NRM_E)
                              + k.yxy*sdf_shell(p + k.yxy*NRM_E) + k.xxx*sdf_shell(p + k.xxx*NRM_E) ));
}
Vector normal_wax(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_wax(p + k.xyy*NRM_E) + k.yyx*sdf_wax(p + k.yyx*NRM_E)
                              + k.yxy*sdf_wax(p + k.yxy*NRM_E) + k.xxx*sdf_wax(p + k.xxx*NRM_E) ));
}
Vector normal_glass(vec3 p){
    vec2 k = vec2(1.,-1.)*0.5773;
    return Vector(p, normalize( k.xyy*sdf_glass(p + k.xyy*NRM_E) + k.yyx*sdf_glass(p + k.yyx*NRM_E)
                              + k.yxy*sdf_glass(p + k.yxy*NRM_E) + k.xxx*sdf_glass(p + k.xxx*NRM_E) ));
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

//control: a clear ballistic interior. mfp stays at maxDist, so no walk.
Material glassMaterial(){
    return makeGlass(absorbFor(vec3(0.85, 0.92, 0.90), 2.), 1.5, 1.);
}

//wax: the same glass with a SHORT mean free path, which is the only difference
//between "glass" and "subsurface" in this model.
//
//The tint is a live colour knob because a scattering interior needs tuning by
//eye: the random walk makes the path through the medium far LONGER than the
//ball is wide, so Beer bills it much harder than the same absorb would in clear
//glass. waxDepth is the reference depth handed to absorbFor — smaller means a
//stronger tint.
Material waxMaterial(){
    return makeSubsurface(absorbFor(waxTint, waxDepth), 1.45, waxDensity, waxBlur);
}

//the shell is clear glass; the core scatters. The interface between them has
//air on neither side, so its Fresnel comes from 1.5 / 1.4.
Material shellMaterial(){
    return makeGlass(absorbFor(vec3(0.90, 0.93, 0.96), 3.), 1.5, 1.);
}
Material coreMaterial(){
    return makeSubsurface(absorbFor(coreTint, coreDepth), 1.4, coreDensity, 1.);
}

Material material_glass(vec3 p, inout Vector n){ return glassMaterial(); }
Medium   medium_glass  (vec3 p){ return glassMaterial().interior; }

Material material_wax(vec3 p, inout Vector n){ return waxMaterial(); }
Medium   medium_wax  (vec3 p){ return waxMaterial().interior; }

Material material_shell(vec3 p, inout Vector n){ return shellMaterial(); }
Medium   medium_shell  (vec3 p){ return shellMaterial().interior; }

Material material_core(vec3 p, inout Vector n){ return coreMaterial(); }
Medium   medium_core  (vec3 p){ return coreMaterial().interior; }

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
    gSDF[ID_CORE]  = sdf_core(p);
    gSDF[ID_SHELL] = sdf_shell(p);
    gSDF[ID_WAX]   = sdf_wax(p);
    gSDF[ID_GLASS] = sdf_glass(p);
    gSDF[ID_LIGHT] = sdf_light(p);
    gSDF[ID_ROOM]  = sdf_room(p);
}

bool insideOf(int id, vec3 p){
    if(id == ID_CORE) { return inside_core(p);  }
    if(id == ID_SHELL){ return inside_shell(p); }
    if(id == ID_WAX)  { return inside_wax(p);   }
    if(id == ID_GLASS){ return inside_glass(p); }
    if(id == ID_LIGHT){ return inside_light(p); }
    if(id == ID_ROOM) { return inside_room(p);  }
    return false;                //ID_NONE: open air
}

Vector normalOf(int id, vec3 p){
    if(id == ID_CORE) { return normal_core(p);  }
    if(id == ID_SHELL){ return normal_shell(p); }
    if(id == ID_WAX)  { return normal_wax(p);   }
    if(id == ID_GLASS){ return normal_glass(p); }
    if(id == ID_LIGHT){ return normal_light(p); }
    return normal_room(p);
}

//no sheets in this scene: every object is a region with an interior
bool isSheet(int id){ return false; }

Material materialOf(int id, vec3 p, inout Vector n, bool front){
    if(id == ID_CORE) { return material_core(p, n);  }
    if(id == ID_SHELL){ return material_shell(p, n); }
    if(id == ID_WAX)  { return material_wax(p, n);   }
    if(id == ID_GLASS){ return material_glass(p, n); }
    if(id == ID_LIGHT){ return material_light(p, n); }
    return material_room(p, n);
}

Medium mediumOf(int id, vec3 p){
    if(id == ID_CORE) { return medium_core(p);  }
    if(id == ID_SHELL){ return medium_shell(p); }
    if(id == ID_WAX)  { return medium_wax(p);   }
    if(id == ID_GLASS){ return medium_glass(p); }
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
    d = min(d, sphereTrace(tv, GLASS_P, GLASS_R));
    d = min(d, sphereTrace(tv, WAX_P,   WAX_R));
    d = min(d, sphereTrace(tv, SHELL_P, SHELL_R));
    d = min(d, sphereTrace(tv, SHELL_P, CORE_R));
    d = min(d, sphereTrace(tv, LIGHT_P, LIGHT_R));
    d = min(d, trace_room(tv));
    return d;
}
