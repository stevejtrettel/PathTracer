//-------------------------------------------------
// OBJECTS — IRIDESCENCE OVER ANYTHING (scatter.glsl thinFilmReflect)
//
// The soap-bubble effect is not restricted to soap bubbles. When
// `surf.film > 0` the two-beam interference REPLACES the base Fresnel — and it
// does that whatever the base is. So the same physics that makes a bubble
// rainbow will iridize a rock, a metal, or a lump of wax. One thickness,
// five substrates, left to right:
//
//   1. THIN SHELL   — no interior at all: the classic bubble. The film is the
//                     only reflectance there is; un-reflected light passes
//                     straight through (setSurfaceInMat, IOR ratio 1).
//   2. MATTE BLACK  — oil on asphalt. The dark base is what makes the film
//                     read: there is nothing else coming back to compete.
//   3. MATTE WHITE  — the same film over a bright base, washed out. Worth
//                     seeing next to #2: iridescence is a CONTRAST effect.
//   4. GOLD         — iridized metal (heat-tinted steel, anodizing). The film
//                     replaces the conductor's Fresnel, so the F0 tint now
//                     reaches you only through the interference.
//   5. SUBSURFACE   — nacre: film over a milky scattering interior. This is
//                     what pearlField is; the glow underneath the rainbow is
//                     the medium walk.
//
// LIMITATION worth knowing: the film sits on the BASE lobe, not on the coat.
// Film-under-clearcoat works (coat is a separate tier above it), but an
// iridescent clearcoat — rainbow on the lacquer itself — is not expressible
// today. That would be a small extension to the coat tier.
//
// spectral is ON in settings: without per-ray wavelengths the interference is
// angle-only banding rather than true rainbows.
//-------------------------------------------------

const int NUM = 5;
Sphere ball[NUM];
Material airMat;


void buildObjects(){

    initMat(airMat);   //the ambient material the thin shell floats in

    for(int i = 0; i < NUM; i++){
        float x = -6.4 + 3.2*float(i);
        ball[i].frame  = makeFrame(vec3(x, 1.6, 0.));
        ball[i].radius = 1.5;
    }

    //1. the bare film: a thin two-sided shell, no interior
    ball[0].mat = makeSoapFilm(thickness);

    //2-5. the same film thickness laid over four solid substrates
    ball[1].mat = makeMatte(vec3(0.03));
    ball[2].mat = makeMatte(vec3(0.85));
    ball[3].mat = makeGold(0.1);
    ball[4].mat = makeMilk();

    for(int i = 1; i < NUM; i++){
        ball[i].mat.surf.film    = thickness;
        ball[i].mat.surf.filmIOR = filmIOR;
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, ball[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//the nacre sphere has a scattering interior; the shell has none
bool inside_Object( Vector tv ){
    return inside(tv, ball[4]);
}


//-------------------------------------------------
// Setting the Objects Data
// ball[0] is a THIN surface (two-sided, no interior) and needs the
// setSurfaceInMat path; the rest are ordinary solids in air.
//-------------------------------------------------

void setData_Objects(inout Path path){

    if( at(path.tv, ball[0]) ){
        Vector normal = normalVec(path.tv, ball[0]);
        float side = inside(path.tv, ball[0]) ? -1. : 1.;

        //drain the film like a real bubble: thin at the top, swelling at the
        //bottom, so the bands slide down the shell
        vec3 p = toLocal(ball[0].frame, path.tv.pos)/ball[0].radius;
        Material m = ball[0].mat;
        m.surf.film = bubbleThickness(p, thickness);

        setSurfaceInMat(path.dat, side, normal, m, airMat);
    }

    for(int i = 1; i < NUM; i++){
        setData(path, ball[i]);
    }
}
