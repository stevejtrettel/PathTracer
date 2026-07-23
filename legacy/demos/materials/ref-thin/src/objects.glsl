//-------------------------------------------------
// OBJECTS — THIN SURFACES & transmitTint (interaction.glsl setSurfaceInMat)
//
// A thin surface is a two-sided boundary with NO interior: paper, a leaf, a
// lampshade, a stained-glass pane. Both sides open onto the same medium, so
// the interface is index-MATCHED (IOR ratio 1) — light that crosses does not
// refract, it goes straight on. That makes it the one place where
// `surf.transmitTint` is the whole story: with no interior, Beer's law has no
// distance to work over, so the tint on crossing IS the colour of the material.
// (On a volume, transmitTint stays white and the Medium owns the colour.)
//
// Each shade here is a thin shell with a small LIGHT INSIDE, so you are
// looking at light that has crossed the surface and picked up its tint —
// which is exactly what a paper lantern is. Left to right:
//   rice paper, amber lampshade, green leaf, blue stained glass, red silk.
//
// The `shadeRough` knob is the other half of the model: roughness on a thin
// surface converges the crossing ray toward LAMBERT TRANSMISSION at 1, which
// is the difference between stained glass (0 — you can see the bulb) and
// paper (near 1 — the bulb becomes an even glow). Drag it and watch the
// filaments dissolve.
//-------------------------------------------------

const int NUM = 5;
Sphere shade[NUM];
Sphere bulb[NUM];
Material airMat;


void buildObjects(){

    initMat(airMat);   //the ambient material the shades float in

    //the tint each shade imposes on light crossing it
    vec3 tint[NUM];
    tint[0] = vec3(0.95, 0.90, 0.78);   //rice paper, barely warm
    tint[1] = vec3(0.95, 0.55, 0.15);   //amber
    tint[2] = vec3(0.35, 0.75, 0.25);   //leaf green
    tint[3] = vec3(0.20, 0.40, 0.90);   //cobalt
    tint[4] = vec3(0.85, 0.12, 0.20);   //red silk

    for(int i = 0; i < NUM; i++){
        float x = -6.4 + 3.2*float(i);

        //---- the shade: a thin two-sided surface -------------------------
        Material m; initMat(m);
        m.surf.transmit     = 1.;        //all non-reflected light crosses
        m.surf.transmitTint = tint[i];   //and picks up the tint doing so
        m.surf.diffuse      = tint[i];   //what it looks like lit from outside
        m.surf.roughness    = shadeRough;

        shade[i].frame  = makeFrame(vec3(x, 2.2, 0.));
        shade[i].radius = 1.4;
        shade[i].mat    = m;

        //---- the bulb inside ---------------------------------------------
        bulb[i].frame  = makeFrame(vec3(x, 2.2, 0.));
        bulb[i].radius = 0.35;
        bulb[i].mat    = makeLight(vec3(1.), bulbPower);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched;
// trace() returns the far intersection once inside, so a shell is hit
// from both sides)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, shade[i]));
        dist = min(dist, trace(tv, bulb[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;   //thin surfaces have no interior; the bulbs are opaque
}


//-------------------------------------------------
// Setting the Objects Data
// the shades take the THIN path (setSurfaceInMat, both sides into air);
// the bulbs are ordinary emissive solids.
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){

        if( at(path.tv, shade[i]) ){
            Vector normal = normalVec(path.tv, shade[i]);
            float side = inside(path.tv, shade[i]) ? -1. : 1.;
            setSurfaceInMat(path.dat, side, normal, shade[i].mat, airMat);
        }

        setData(path, bulb[i]);
    }
}
