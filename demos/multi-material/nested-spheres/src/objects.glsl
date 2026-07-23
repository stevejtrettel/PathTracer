//-------------------------------------------------
// OBJECTS — NESTED MEDIA, THE MINIMAL CASE
// (docs/material-system.md §2; interaction.glsl setMaterialInterface)
//
// The smallest possible multi-material object: a clear glass sphere with a
// second sphere embedded inside it. Nothing here is in the object library —
// the whole composite is the twenty lines of setData_Objects at the bottom of
// this file, so this page doubles as the TEMPLATE for building your own.
//
// THE IDEA. A surface is not a thing that has a material; it is the BOUNDARY
// BETWEEN TWO MEDIA, and its Fresnel comes from the ratio of their indices.
// That is why ior lives on the Medium and not on the Surface. The outer sphere
// is a glass/air boundary (ratio shellIOR/1). The inner sphere is a
// glass/core boundary (ratio shellIOR/coreIOR) — no air in sight.
//
// THE SWEEP. Left to right the core's index climbs, and the MIDDLE one is
// pinned to the shell's index whatever you set shellIOR to:
//
//   coreIOR = 1        an air BUBBLE trapped in glass. The ratio is inverted
//                      (dense -> light), so it total-internal-reflects and
//                      reads as a silvery mirrored pocket, not a hole.
//   coreIOR < shell    a weak inverted interface: faint, still silvery.
//   coreIOR = shell    INDEX MATCHED — the core VANISHES. Its geometry is
//                      still there and still traced; there is simply no
//                      optical event at a boundary between identical media.
//                      This is the whole argument for ior-on-the-medium in
//                      one image.
//   coreIOR > shell    a dense inclusion: a normal refracting lens again,
//                      strengthening as it climbs.
//
// Give the core an absorb tint to keep the matched one findable — Beer's law
// still bills it for the distance travelled even when the SURFACE is silent.
//-------------------------------------------------

const int NUM = 5;
Sphere shell[NUM];
Sphere core[NUM];

Material shellMat;
Material coreMat[NUM];


//the core index for column i, built so column 2 is ALWAYS index-matched to the
//shell no matter where shellIOR is dragged
float coreIORat(int i){
    float t = float(i);
    if(t < 2.){ return mix(1., shellIOR, t/2.); }
    return mix(shellIOR, maxCoreIOR, (t - 2.)/2.);
}


void buildObjects(){

    shellMat = makeGlass(vec3(0.), shellIOR);

    for(int i = 0; i < NUM; i++){
        float x = -6.4 + 3.2*float(i);

        shell[i].frame  = makeFrame(vec3(x, 1.7, 0.));
        shell[i].radius = 1.6;
        shell[i].mat    = shellMat;

        core[i].frame  = makeFrame(vec3(x, 1.7, 0.));
        core[i].radius = 0.8;
        coreMat[i]     = makeGlass(absorbFor(coreTint, coreDepth), coreIORat(i));
        core[i].mat    = coreMat[i];
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
// BOTH surfaces must be traced — the core is a real boundary the ray has to
// be able to land on, even though it is buried inside the shell.
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, shell[i]));
        dist = min(dist, trace(tv, core[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;   //every medium here is ballistic (clear): no walk
}


//-------------------------------------------------
// Setting the Objects Data — THE DISPATCHER
//
// This is the part that makes a multi-material object. For every hit, decide
// WHICH boundary was struck and FROM WHICH SIDE, then name the two media:
//
//   setObjectInAir(dat, inside, normal, mat)
//       the easy case — one side is the open air. The wrapper flips the
//       normal for you when `inside` is true.
//
//   setMaterialInterface(dat, current, neighbor, dominant)
//       the nested case — BOTH sides are real media. `current` is the medium
//       the ray is in now (reflections stay in it), `neighbor` is the one
//       beyond (transmissions enter it), and `dominant` supplies the Surface
//       response. Which material is dominant is an AUTHORING choice, not
//       physics: here the core owns its own boundary, so its roughness/tint
//       describe the inclusion.
//       NOTE the contract: you must set dat.normal (facing the incoming ray)
//       and dat.side YOURSELF before calling it.
//
// Branch on the SIGN OF THE SDF rather than on inside(), so the two cases
// cannot both fire at a grazing hit.
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){

        //---- the outer boundary: air | glass ------------------------------
        if( at(path.tv, shell[i]) ){
            Vector normal = normalVec(path.tv, shell[i]);
            bool fromInside = ( sdf(path.tv, shell[i]) < 0. );
            setObjectInAir(path.dat, fromInside, normal, shellMat);
        }

        //---- the inner boundary: glass | core -----------------------------
        if( at(path.tv, core[i]) ){
            Vector normal = normalVec(path.tv, core[i]);

            if( sdf(path.tv, core[i]) > 0. ){
                //arriving from the shell glass, crossing into the core
                path.dat.normal = normal;
                path.dat.side   = 1.;
                setMaterialInterface(path.dat, shellMat, coreMat[i], coreMat[i]);
            }
            else{
                //leaving the core, crossing back into the shell glass
                path.dat.normal = negate(normal);
                path.dat.side   = -1.;
                setMaterialInterface(path.dat, coreMat[i], shellMat, coreMat[i]);
            }
        }

    }
}
