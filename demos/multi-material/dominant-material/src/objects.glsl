//-------------------------------------------------
// OBJECTS — WHO OWNS THE BOUNDARY?
// (interaction.glsl setMaterialInterface, the `dominant` argument)
//
// When two media meet, the physics is fully determined: the Fresnel comes from
// the ratio of their indices, and Beer's law bills whichever medium the ray
// travels through. But something is still undecided — WHOSE SURFACE is it?
// Roughness, tint, coat, film all live on the Surface, and a boundary between
// two materials has two candidates and needs exactly one.
//
// That is the third argument to setMaterialInterface(current, neighbor,
// DOMINANT), and it is an AUTHORING choice, not physics. This page makes the
// choice visible by putting the two options side by side.
//
// Both objects are identical in every physical respect: same shell (smooth
// clear glass), same core (denser, and FROSTED — roughness `frost`), same
// indices, same absorption. The only difference is which material is named
// dominant at the inner boundary:
//
//   LEFT  — the SHELL is dominant. The inner boundary takes the shell's
//           smooth finish: you see a clean, sharp refracting inclusion. The
//           core's roughness is still stored on its material — it simply
//           never gets consulted here, because this is not its surface.
//
//   RIGHT — the CORE is dominant. The same boundary now takes the core's
//           roughness, so the inclusion is frosted: light scatters as it
//           crosses. This is the one you want when the inner object is a
//           thing (a frosted stone set in resin); the left one is what you
//           want when the outer body is the thing (a bubble in polished glass,
//           whose surface is the glass's own).
//
// Drag `frost` and watch ONLY the right sphere change. That is the whole
// lesson: the two objects are optically identical and look different anyway,
// because surface response and medium physics are separate questions.
//-------------------------------------------------

Sphere shell[2];
Sphere core[2];

Material shellMat;
Material coreMat;


void buildObjects(){

    //the shell: smooth, clear, colourless
    shellMat = makeGlass(vec3(0.), 1.5);

    //the core: denser and frosted, with a tint so it is easy to find
    coreMat = makeGlass(absorbFor(coreTint, 2.), coreIOR);
    coreMat.surf.roughness = frost;

    for(int i = 0; i < 2; i++){
        float x = -2.6 + 5.2*float(i);

        shell[i].frame  = makeFrame(vec3(x, 1.9, 0.));
        shell[i].radius = 1.8;
        shell[i].mat    = shellMat;

        core[i].frame  = makeFrame(vec3(x, 1.9, 0.));
        core[i].radius = 0.95;
        core[i].mat    = coreMat;
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < 2; i++){
        dist = min(dist, trace(tv, shell[i]));
        dist = min(dist, trace(tv, core[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;   //both media are ballistic (clear): no medium walk
}


//-------------------------------------------------
// Setting the Objects Data
// The dispatcher is the same as nested-spheres; the ONLY difference between
// the two objects is the third argument of setMaterialInterface.
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < 2; i++){

        //---- the outer boundary: air | glass ------------------------------
        if( at(path.tv, shell[i]) ){
            Vector normal = normalVec(path.tv, shell[i]);
            bool fromInside = ( sdf(path.tv, shell[i]) < 0. );
            setObjectInAir(path.dat, fromInside, normal, shellMat);
        }

        //---- the inner boundary: glass | core -----------------------------
        if( at(path.tv, core[i]) ){
            Vector normal = normalVec(path.tv, core[i]);

            //i == 0: the shell owns this surface.  i == 1: the core owns it.
            //Everything else about the interface is identical.
            Material dominant = coreMat;
            if(i == 0){ dominant = shellMat; }

            if( sdf(path.tv, core[i]) > 0. ){
                path.dat.normal = normal;
                path.dat.side   = 1.;
                setMaterialInterface(path.dat, shellMat, coreMat, dominant);
            }
            else{
                path.dat.normal = negate(normal);
                path.dat.side   = -1.;
                setMaterialInterface(path.dat, coreMat, shellMat, dominant);
            }
        }

    }
}
