//-------------------------------------------------
// THE SCENE — the classifier
//
// A scene is a list of OBJECTS, each of which is one region of space. The scene
// chunk (generated, or hand-written) supplies:
//
//     const int N_OBJ;                                    how many
//     float gSDF[N_OBJ];                                  scratch, filled below
//     void  sdfAll( vec3 p );                             every object's sdf at p
//     Vector   normalOf  ( int id, vec3 p );              4-tap of that object's sdf
//     Material materialOf( int id, vec3 p, inout Vector n, bool front );
//     Medium   mediumOf  ( int id, vec3 p );              medium only (ID_NONE = air)
//     bool     isSheet   ( int id );                      no interior (see below)
//
//     void  buildScene();
//     float sdf_Scene  ( Vector tv );     the marched union (bound-accelerated)
//     float trace_Scene( Vector tv );     analytic surfaces only
//
// and, ONLY if some region scatters (mfp < maxDist), the scene declares
// `defines: ['SCENE_SUBSURFACE']` and additionally supplies
//
//     bool insideOf( int id, vec3 p );    is p inside region `id`?
//
// The generator knows which regions can scatter, refract or carry a varying
// index, so a scene with no scattering media compiles the whole medium walk
// away — see 6Trace/mediumWalk.glsl.
//
// sdf_Scene is emitted separately from sdfAll on purpose: the marcher wants
// early-outs on bounding volumes and runs hundreds of times per bounce, while
// sdfAll is unconditional and runs twice per bounce. Both come from the same
// source, so they cannot drift.
//-------------------------------------------------


//-------------------------------------------------
// Which object contains a point
//-------------------------------------------------
// Declaration order is priority: objects are declared INNER TO OUTER, so the
// first containing object is the innermost one. ID_NONE means open air.

int regionAt( vec3 p ){
    sdfAll(p);
    for(int i = 0; i < N_OBJ; i++){
        if(gSDF[i] < 0.){ return i; }
    }
    return ID_NONE;
}


//-------------------------------------------------
// Setting the interface data at a hit
//-------------------------------------------------
// The marcher hands us a POINT, not an identity — it cannot hand us one. At a
// wall shared by two objects (glass against liquid) the union's min is a TIE,
// and on the analytic-stop path no marched argmin exists at all. So identity is
// recovered here, from the sdfs themselves:
//
//   the object we are ON      — its sdf vanishes (|sdf| < AT_THRESH)
//   the object on the OTHER SIDE — a second vanishing sdf (a shared wall),
//                              else the innermost object CONTAINING the point,
//                              else air
//
// That second line is the whole multi-material system. The above/below-waterline
// case that used to be a hand-written branch falls out of it: above the surface
// the drink's sdf is the (positive) plane, so the drink is simply not there.

void setData_Scene(inout Path path){

    vec3 p = path.tv.pos;
    sdfAll(p);

    //---- (a) whose boundary are we standing on? -------------------------
    int hit = ID_NONE;
    for(int i = 0; i < N_OBJ; i++){
        if(abs(gSDF[i]) < AT_THRESH){ hit = i; break; }
    }

    //nothing claimed this landing. Today's engine silently reused the previous
    //bounce's data here; instead pass straight through, unchanged, and leave
    //hit = ID_NONE for debugPass to paint.
    if(hit == ID_NONE){
        path.dat.hit     = ID_NONE;
        path.dat.frontID = path.region;
        path.dat.backID  = path.region;
        path.dat.front   = path.medium;
        path.dat.back    = path.medium;
        path.dat.render  = false;
        path.dat.normal  = Vector(p, -path.tv.dir);
        return;
    }

    //---- (b) what is on the other side? ---------------------------------
    //Sheets are skipped throughout: a sheet has no interior, so it can never be
    //what contains a point, and standing on the negative side of a leaf must not
    //make the leaf your medium.
    int other = ID_NONE;
    if(!isSheet(hit)){
        //a coincident second boundary (a shared wall) beats mere containment
        for(int i = hit+1; i < N_OBJ; i++){
            if(!isSheet(i) && abs(gSDF[i]) < AT_THRESH){ other = i; break; }
        }
    }
    if(other == ID_NONE){
        for(int i = 0; i < N_OBJ; i++){
            if(i != hit && !isSheet(i) && gSDF[i] < -AT_THRESH){ other = i; break; }
        }
    }

    //---- (c) the boundary's normal, and which way we cross it -----------
    //taken from the object we are ON, never from the union: at a shared wall the
    //union has a RIDGE (negative on both sides, zero on the wall), so its finite
    //difference returns noise.
    Vector n = normalOf(hit, p);

    //the GEOMETRIC normal decides the side; a bump modifier may tilt n afterwards
    //for shading only. The sdf's gradient points from its negative side to its
    //positive one, so a ray travelling WITH the gradient is on the negative side.
    bool leaving = vDot(path.tv, n) > 0.;
    bool front   = !leaving;

    //---- (d) refill -----------------------------------------------------
    //the object we are on always supplies the Surface, and (unless it is a sheet)
    //one of the two media, so it needs its full Material. The far object is only
    //ever a Medium — which also keeps a stochastic mixMaterial from being sampled
    //and thrown away.
    Material m = materialOf(hit, p, n, front);

    path.dat.hit    = hit;
    path.dat.surf   = m.surf;
    path.dat.render = m.render;

    if(leaving){ path.dat.normal = negate(n); }
    else       { path.dat.normal = n;         }

    if(isSheet(hit)){
        //A SHEET has no interior. Both of its sides open onto whatever region
        //contains it, so the interface is index-matched: no refraction, and the
        //ray's medium is unchanged by crossing. All the sheet contributes is its
        //Surface — and which of its two Surfaces, front or back, it just chose.
        Medium around = mediumOf(other, p);
        path.dat.frontID = other;  path.dat.front = around;
        path.dat.backID  = other;  path.dat.back  = around;
    }
    else if(leaving){                   //we are inside `hit`, heading out
        path.dat.frontID = hit;    path.dat.front = m.interior;
        path.dat.backID  = other;  path.dat.back  = mediumOf(other, p);
    }
    else{                               //we are outside `hit`, heading in
        path.dat.frontID = other;  path.dat.front = mediumOf(other, p);
        path.dat.backID  = hit;    path.dat.back  = m.interior;
    }
}
