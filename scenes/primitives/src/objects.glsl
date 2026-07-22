//-------------------------------------------------
// OBJECTS OF THE SCENE
// a demo of the new first-class primitives (cylinder, capsule, ellipsoid),
// all auto-included from basic/. also shows opRepLim (limited domain repetition).
//-------------------------------------------------

Cylinder  cyl;
Capsule   cap;
Ellipsoid ell;
Sphere    beads;   //a small sphere, repeated on a grid via opRepLim

void buildObjects(){

    //--- capped, slightly rounded cylinder (sits on the floor) ---
    cyl.frame   = makeFrame(vec3(-3.2, 1.5, 0));
    cyl.radius  = 1.0;
    cyl.height  = 1.5;      //half-height
    cyl.rounded = 0.12;
    cyl.mat     = makeMetal(vec3(0.9, 0.75, 0.4), 0.9, 0.05);

    //--- capsule: a tilted segment a -> b, thickened ---
    cap.frame  = makeFrame(vec3(0, 0, 0));
    cap.a      = vec3(-0.8, 0.6, 0);
    cap.b      = vec3(0.8, 3.2, 0);
    cap.radius = 0.55;
    cap.mat    = makeDielectric(vec3(0.2, 0.5, 0.85), 0.2, 0.1);

    //--- ellipsoid ---
    ell.frame = makeFrame(vec3(3.2, 1.1, 0));
    ell.radii = vec3(1.4, 1.1, 0.8);
    ell.mat   = makeGlass(vec3(0.15, 0.05, 0.25), 1.5);

    //--- the bead (repeated on a grid in sdf_beads below) ---
    beads.radius = 0.22;
    beads.mat    = makeDielectric(vec3(0.85, 0.3, 0.25), 0.1, 0.2);

}


//-------------------------------------------------
//Finding the Objects
//-------------------------------------------------

float trace_Objects( Vector tv ){
    return maxDist;
}

//a 5 x 3 grid of beads on the floor toward the camera, via opRepLim
float sdf_beads( vec3 pos ){
    vec3 p = pos - vec3(0.0, 0.35, 4.5);            //grid origin
    p = opRepLim(p, 1.1, vec3(2.0, 0.0, 1.0));      //repeat x in [-2,2], z in [-1,1]; no y
    return length(p) - beads.radius;
}

//finite-difference normal of the repeated field
Vector normal_beads( Vector tv ){
    vec3 q = tv.pos;
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    vec3 dir = e.xyy*sdf_beads(q + e.xyy*ep)
             + e.yyx*sdf_beads(q + e.yyx*ep)
             + e.yxy*sdf_beads(q + e.yxy*ep)
             + e.xxx*sdf_beads(q + e.xxx*ep);
    return Vector(tv.pos, normalize(dir));
}

float sdf_Objects( Vector tv ){
    float dist = maxDist;
    dist = min(dist, sdf(tv, cyl));
    dist = min(dist, sdf(tv, cap));
    dist = min(dist, sdf(tv, ell));
    dist = min(dist, sdf_beads(tv.pos));
    return dist;
}


bool inside_Object( Vector tv ){
    return inside(tv, cyl) || inside(tv, cap) || inside(tv, ell);
}


//-------------------------------------------------
//Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, cyl);
    setData(path, cap);
    setData(path, ell);
    //the repeated beads: set material if the bead field is the surface we hit
    if( abs(sdf_beads(path.tv.pos)) < AT_THRESH ){
        setObjectInAir(path.dat, false, normal_beads(path.tv), beads.mat);
    }
}
