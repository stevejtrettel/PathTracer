//-------------------------------------------------
// OBJECTS — GLOSS vs IOR: THE TWO WAYS TO GET A HIGHLIGHT
// (docs/material-system.md §3, Tier 2)
//
// The model offers two separate controls over how reflective a surface is, and
// they are NOT the same knob. Both rows sweep left (dull) to right (mirror):
//
//   FRONT row — `surf.gloss`, the ARTISTIC floor, 0 -> 1.
//     gloss is the head-on reflectance, imposed directly. Fresnel still ramps
//     it to 1 at grazing, but the floor lifts the WHOLE curve: at gloss 1 the
//     sphere is a mirror from every angle. No index is involved. This is the
//     direct art control — rooms and props are tuned in these terms.
//
//   BACK row — `interior.ior`, the PHYSICAL index, 1 -> maxIOR.
//     No gloss floor at all: the reflectance comes from the index step alone,
//     so it stays LOW head-on (~4% at n=1.5, ~17% at n=2.5) and only climbs to
//     a mirror at grazing. transmit stays 0, so the interior is never entered —
//     its index only shapes the reflection (that is makePlastic).
//
// The tell: scan across the two rows and look at the CENTRE of each sphere.
// The gloss row brightens everywhere at once. The IOR row keeps a dark face
// with a bright rim, however far you push it — that rim-only brightening is
// what real dielectrics do, and why plastic never looks like chrome.
//
// At IOR 1 the back row's leftmost sphere has NO interface at all: Schlick's
// grazing term does not vanish at n == 1, so scatter.glsl gates the base
// Fresnel off entirely there rather than painting a phantom reflection.
//-------------------------------------------------

const int NUM = 7;
Sphere glossRow[NUM];
Sphere iorRow[NUM];


void buildObjects(){

    vec3 slate = vec3(0.10, 0.13, 0.20);   //dark, so reflections read

    for(int i = 0; i < NUM; i++){
        float x = -7.2 + 2.4*float(i);
        float t = float(i)/float(NUM - 1);   //0 -> 1

        //ARTISTIC: gloss floor 0 -> 1, no index
        glossRow[i].frame  = makeFrame(vec3(x, 1.05, 2.));
        glossRow[i].radius = 1.05;
        glossRow[i].mat    = makeGloss(slate, t, roughness);

        //PHYSICAL: index 1 -> maxIOR, no gloss floor
        iorRow[i].frame  = makeFrame(vec3(x, 1.05, -2.5));
        iorRow[i].radius = 1.05;
        iorRow[i].mat    = makePlastic(slate, roughness, mix(1., maxIOR, t));
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, glossRow[i]));
        dist = min(dist, trace(tv, iorRow[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;   //transmit is 0 on both rows: the interior is never entered
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, glossRow[i]);
        setData(path, iorRow[i]);
    }
}
