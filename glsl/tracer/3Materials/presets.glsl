//-------------------------------------------------
// PRESETS — named materials, built purely from the constructors in
// material.glsl. Every preset takes a color; overloads expose the extra
// parameter worth touching (and a no-arg classic where one exists). Tuning
// reference: demos/presets renders one sphere of each.
//
// LEGACY for generated scenes: the live named-material source is
// js/presets/materials.js (JS value bundles, docs/generator.md §5). This
// file remains for hand-written GLSL callers (variety scene, demo branch)
// and deletes when those migrate — keep the two in sync until then.
//-------------------------------------------------


//------ opaque ------------------------------------------------------------

//unglazed fired clay: matte with the faintest burnish
Material makeTerracotta(vec3 color){
    return makeGloss(color, 0.03, 0.5);
}
Material makeTerracotta(){
    return makeTerracotta(vec3(0.71, 0.38, 0.26));
}

//glazed ceramic: a crisp white Fresnel glaze over flat pigment
Material makeTile(vec3 color, float glazeRoughness){
    return withCoat(makeMatte(color), 1., glazeRoughness);
}
Material makeTile(vec3 color){
    return makeTile(color, 0.);
}

//soft wide highlight over deep pigment
Material makeRubber(vec3 color){
    return makeGloss(color, 0.04, 0.6);
}

//a polished clear coat over rough metal flake
Material makeCarPaint(vec3 color, float flakeRoughness){
    return withCoat(makeMetal(color, 1., flakeRoughness), 1., 0.);
}
Material makeCarPaint(vec3 color){
    return makeCarPaint(color, 0.4);
}

Material makeMirror(vec3 tint){
    return makeMetal(tint, 1., 0.);
}
Material makeMirror(){
    return makeMirror(vec3(1.));
}


//------ transmissive -------------------------------------------------------

//a clear liquid showing `tint` per unit of travel
Material makeLiquid(vec3 tint, float IOR){
    return makeGlass(absorbFor(tint, 1.), IOR);
}
Material makeLiquid(vec3 tint){
    return makeLiquid(tint, 1.33);
}

Material makeHoney(){
    return makeLiquid(vec3(0.75, 0.45, 0.12), 1.42);
}

//colourless and highly refractive — the colour comes from dispersion (turn
//spectral on); tint overload for fancy coloured stones
Material makeDiamond(vec3 tint){
    return makeGlass(absorbFor(tint, 2.), 2.42);
}
Material makeDiamond(){
    return makeDiamond(vec3(1.));
}

//a glowing gas filling the shape: no interface (ior 1), pure volume emission
Material makeNeon(vec3 color, float power){
    Material mat; initMat(mat);
    mat.surf.transmit=1.;
    mat.interior.emit=power*color;
    return mat;
}

//a soap film: a THIN surface (use with setSurfaceInMat-style shell geometry)
//whose reflectance is thin-film interference — thickness in nm, ~150-700 is
//the visible sweet spot. True rainbows need spectral on; the un-reflected
//light passes straight through. demo: demos/soapFilm.
Material makeSoapFilm(float thickness){
    Material mat; initMat(mat);
    mat.surf.transmit=1.;
    mat.surf.film=thickness;
    return mat;
}

//a thin oily coating over an opaque base: iridized highlights (oil ~1.45)
Material makeOilSlick(vec3 baseColor, float thickness){
    Material mat = makeMatte(baseColor);
    mat.surf.film=thickness;
    mat.surf.filmIOR=1.45;
    return mat;
}


//------ subsurface ---------------------------------------------------------
// all on one axis: interior mfp (dense -> dilute) x surface finish
// (rough exit = waxy matte, smooth exit = polished stone)

//polished stone, deep colored glow
Material makeJade(vec3 color, float mfp){
    return makeSubsurface(absorbFor(color, 0.3), 1.5, mfp, 0.8);
}
Material makeJade(vec3 color){
    return makeJade(color, 0.1);
}

//dense, barely translucent, Fresnel-glazed by its own index
Material makePorcelain(vec3 color){
    return makeSubsurface(absorbFor(color, 0.5), 1.5, 0.02, 1.);
}
Material makePorcelain(){
    return makePorcelain(vec3(0.94, 0.92, 0.87));
}

//matte finish over a scattering interior (the rough exit is what makes it wax)
Material makeWax(vec3 color, float mfp){
    Material mat = makeSubsurface(absorbFor(color, 0.5), 1.5, mfp, 0.9);
    mat.surf.roughness=0.45;
    return mat;
}
Material makeWax(vec3 color){
    return makeWax(color, 0.12);
}

Material makeMilk(vec3 tint){
    return makeSubsurface(absorbFor(tint, 3.), 1.35, 0.03, 1.);
}
Material makeMilk(){
    return makeMilk(vec3(0.93, 0.95, 1.));
}

//lightly polished stone: subtle veiny glow at edges
Material makeMarble(vec3 color, float mfp){
    Material mat = makeSubsurface(absorbFor(color, 1.), 1.5, mfp, 1.);
    mat.surf.roughness=0.08;
    return mat;
}
Material makeMarble(vec3 color){
    return makeMarble(color, 0.06);
}

//ambient fog is no longer a bolt-on hook: open air is region ID_NONE, so a scene
//sets its medium with `ambient:` and the generator emits it into mediumOf(ID_NONE)
//(the ambientMFP/AMBIENT_FOG accessors + macros are gone). See ambient.glsl.
