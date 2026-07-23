//-------------------------------------------------
// MATERIAL FIELDS — the authoring library (docs/material-fields.md)
// three layers, all scene-facing:
//   1. NOISE     — one canonical hash/noise/fbm (no more per-scene copies)
//   2. PATTERNS  — scalar masks in [0,1] with artistic knobs; compose smoothly
//                  (mix colors/params by t) or stochastically (mixMaterial)
//   3. FIELDS    — Material-valued functions of LOCAL position, composing the
//                  presets with the patterns
// The authoring idiom is the setData followup (demo: demos/fields):
//   setData(path, obj);
//   if( at(path.tv, obj) ){
//       vec3 p = toLocal(obj.frame, path.tv.pos);
//       (superseded: material fields are now the object's material_ function)
//   }
//-------------------------------------------------


//------ 1 · noise ----------------------------------------------------------

float fieldHash(vec3 p){
    return fract(sin(dot(p, vec3(127.1,311.7,74.7)))*43758.5453);
}

//trilinear value noise
float valueNoise(vec3 p){
    vec3 i = floor(p);
    vec3 f = fract(p);
    vec3 u = f*f*(3.-2.*f);
    return mix( mix( mix(fieldHash(i+vec3(0,0,0)), fieldHash(i+vec3(1,0,0)), u.x),
                     mix(fieldHash(i+vec3(0,1,0)), fieldHash(i+vec3(1,1,0)), u.x), u.y),
                mix( mix(fieldHash(i+vec3(0,0,1)), fieldHash(i+vec3(1,0,1)), u.x),
                     mix(fieldHash(i+vec3(0,1,1)), fieldHash(i+vec3(1,1,1)), u.x), u.y), u.z);
}

//4-octave fractal noise, roughly in [0,1]
float fbm(vec3 p){
    float v = 0.;
    float a = 0.5;
    for(int i = 0; i < 4; i++){
        v += a*valueNoise(p);
        p *= 2.03;
        a *= 0.5;
    }
    return v;
}

//domain warp: displace p by a noise vector before sampling another pattern
vec3 fieldWarp(vec3 p, float amount){
    return p + amount*vec3( fbm(p),
                            fbm(p+vec3(5.2,1.3,7.1)),
                            fbm(p+vec3(9.7,3.1,0.4)) );
}


//cellular (Worley) noise: one feature point per lattice cell. F1 = distance
//to the nearest point; worleyEdge = F2-F1, which is 0 exactly on the borders
//between cells — crack networks, crackle glaze, scales, plates.
vec3 fieldCellPoint(vec3 cell){
    return cell + vec3(fieldHash(cell), fieldHash(cell+31.7), fieldHash(cell+77.3));
}

void worleyF(vec3 p, float freq, out float F1, out float F2){
    vec3 q = freq*p;
    vec3 i = floor(q);
    F1 = 8.; F2 = 8.;
    for(int x=-1;x<=1;x++){
    for(int y=-1;y<=1;y++){
    for(int z=-1;z<=1;z++){
        float d = length(q - fieldCellPoint(i + vec3(x,y,z)));
        if(d < F1){ F2 = F1; F1 = d; }
        else if(d < F2){ F2 = d; }
    }}}
}

float worley(vec3 p, float freq){ float a; float b; worleyF(p, freq, a, b); return a; }
float worleyEdge(vec3 p, float freq){ float a; float b; worleyF(p, freq, a, b); return b - a; }


//------ 2 · patterns -------------------------------------------------------

//turbulence-warped sine sheets, sharpened: thin marble veins (sharpness ~4)
float veins(vec3 p, float freq, float sharpness){
    float turb  = fbm(freq*p);
    float sheet = sin(freq*(p.x + 0.6*p.y) + 5.*turb);
    return pow(1.-abs(sheet), sharpness);
}

//concentric rings about the local y-axis: wood grain, agate banding
float rings(vec3 p, float freq, float wobble){
    float r = length(p.xz);
    return 0.5 + 0.5*sin(6.28318*freq*r + wobble*fbm(3.*p));
}

//thresholded fbm coverage mask: rust, lichen, patina. coverage 0 = none,
//1 = everywhere; soft-edged so blends read as crusts, not decals
float patches(vec3 p, float freq, float coverage){
    return smoothstep(0.85-coverage, 1.05-coverage, fbm(freq*p));
}

//cellular flecks: granite, terrazzo
float speckle(vec3 p, float freq, float density){
    return step(1.-density, fieldHash(floor(freq*p)));
}

//height gradient with noisy wobble: 0 at the top (y=h1), 1 at the bottom
//(y=h0) — soap-film drainage, sediment, dust settling
float drainage(vec3 p, float h0, float h1){
    float t = clamp((h1 - p.y)/(h1 - h0), 0., 1.);
    return clamp(t + 0.15*(fbm(2.5*p)-0.5), 0., 1.);
}


//------ 3 · material fields ------------------------------------------------

//veined marble: ivory stone, rough slate veins, polish fading on the veins
Material marbleField(vec3 p, float freq, float polish){
    float v = veins(p, freq, 4.);
    return makeGloss( mix(vec3(0.93,0.90,0.85), vec3(0.25,0.30,0.42), v),
                      polish*(1.-0.7*v),
                      mix(0.02, 0.4, v) );
}
Material marbleField(vec3 p){ return marbleField(p, 3.5, 0.25); }

//weathered metal: a warm matte rust crust eats the base metal. The mask is
//deterministic; the per-ray blend is stochastic (mixMaterial) — accumulation
//converges the crust edges smoothly, weight-free.
Material rustField(vec3 p, Material metal, float weathering){
    Material rust = makeGloss( mix(vec3(0.58,0.26,0.09), vec3(0.32,0.13,0.05), fbm(9.*p)),
                               0.02, 0.6 );
    return mixMaterial(metal, rust, patches(p, 4.0, weathering));
}

//verdigris on copper/bronze — same skeleton, colder crust
Material patinaField(vec3 p, Material metal, float weathering){
    Material verdigris = makeGloss( mix(vec3(0.32,0.72,0.58), vec3(0.19,0.52,0.44), fbm(7.*p)),
                                    0.03, 0.5 );
    return mixMaterial(metal, verdigris, patches(p+vec3(3.7), 4.5, weathering));
}

//wood: ring-darkened tone, late wood slightly rougher. The log axis (local y)
//is OFFSET from the object center — like a board cut off-center from the log —
//so any surface sweeps ACROSS the ring shells; a centered axis leaves a
//sphere's face at nearly constant radius, i.e. inside one band: no grain.
//Reorient the grain via the object's frame.
Material woodField(vec3 p, vec3 tone){
    float r = rings(p + vec3(1.4, 0., 0.5), 2.5, 4.);
    return makeGloss( tone*mix(1.0, 0.55, r), 0.06, mix(0.15, 0.35, r) );
}
Material woodField(vec3 p){ return woodField(p, vec3(0.58,0.34,0.18)); }

//polished granite: mottled greys with dark flecks
Material graniteField(vec3 p){
    vec3 base = mix(vec3(0.55,0.53,0.50), vec3(0.34,0.33,0.36), fbm(6.*p));
    vec3 col  = mix(base, vec3(0.10), 0.8*speckle(p, 24., 0.3));
    return makeGloss(col, 0.15, 0.12);
}

//soap-film drainage: thickness swells toward the bottom of the bubble.
//p in units of the bubble radius (pass p/radius); base = nominal thickness nm
float bubbleThickness(vec3 p, float base){
    return base*mix(0.35, 1.8, drainage(p, -1., 1.));
}


//------ 3b · the second batch (demos/fields2 + fields3) --------------------

//lapis lazuli: deep blue stone flecked with pyrite — the speckle picks REAL
//gold via the stochastic mix
Material lapisField(vec3 p){
    vec3 blue = mix(vec3(0.06,0.12,0.42), vec3(0.10,0.20,0.55), fbm(5.*p));
    Material stone = makeGloss(blue, 0.15, 0.1);
    return mixMaterial(stone, makeGold(0.3), 0.8*speckle(p, 14., 0.12));
}

//damascus steel: forge-folded bands — heavily warped sheets alternating two
//steels; the domain warp is what makes it read as forged
Material damascusField(vec3 p){
    vec3 q = fieldWarp(2.*p, 1.2);
    float band = 0.5 + 0.5*sin(9.*q.x + 4.*fbm(3.*q));
    vec3 steel = mix(vec3(0.35,0.36,0.38), vec3(0.62,0.63,0.66), band);
    return makeMetal(steel, 1., mix(0.12, 0.3, band));
}

//pearl: thin-film iridescence over a milky subsurface body (nacre); the film
//thickness wanders gently so the sheen shifts across the surface
Material pearlField(vec3 p){
    Material m = makeMilk();
    m.surf.film = 320. + 140.*fbm(3.*p + vec3(2.2));
    m.surf.filmIOR = 1.6;
    return m;
}

//oil slick: rainbow film whose thickness pools and swirls over a dark base
Material oilSlickField(vec3 p, vec3 baseColor){
    Material m = makeOilSlick(baseColor, 0.);
    m.surf.film = 250. + 450.*fbm(4.*p);
    return m;
}

//lava: cooled crust plates with molten light in the cracks — the first
//EMISSION field (surf.emit varying over the surface)
Material lavaField(vec3 p, float heat){
    float crack = worleyEdge(p, 3.);
    float glow  = smoothstep(0.25, 0.05, crack);
    Material rock = makeGloss(vec3(0.09,0.08,0.08), 0.03, 0.5);
    rock.surf.emit = heat*glow*mix(vec3(1.0,0.15,0.), vec3(1.0,0.55,0.05), fbm(6.*p));
    return rock;
}

//wet line: dry base above the waterline, wet below — wet = a clear coat plus
//darkened albedo (coat as a FIELD)
Material wetLineField(vec3 p, Material base, float level){
    float wet = smoothstep(level+0.05, level-0.05, p.y + 0.1*fbm(4.*p));
    Material wetted = withCoat(base, 1., 0.);
    wetted.surf.diffuse *= 0.45;
    return mixMaterial(base, wetted, wet);
}

//agate: banded translucent stone — warped rings driving the INTERIOR absorb
//(the first field to vary a Medium property)
Material agateField(vec3 p){
    float band = rings(fieldWarp(p, 0.6) + vec3(0.9, 0., 0.4), 3.5, 2.);
    vec3 tint  = mix(vec3(0.75,0.45,0.28), vec3(0.92,0.86,0.78), band);
    Material m = makeSubsurface(absorbFor(tint, 0.35), 1.5, 0.08, 1.);
    m.surf.roughness = 0.05;
    return m;
}

//dust settling on upward faces (amount 0-1); works on any base
Material dustField(vec3 p, Material base, float amount){
    Material dust = makeMatte(vec3(0.52,0.48,0.42));
    return mixMaterial(base, dust, amount*drainage(p, 1., -1.));
}

//snow cap: porcelain snow settling on the top of any base
Material snowCapField(vec3 p, Material base, float amount){
    return mixMaterial(base, makePorcelain(), amount*drainage(p, 0.9, -0.3));
}

//lichen: two crusts at different scales over any base
Material lichenField(vec3 p, Material base){
    Material sage = makeGloss(vec3(0.55,0.62,0.42), 0.02, 0.7);
    Material gold = makeGloss(vec3(0.75,0.55,0.25), 0.02, 0.7);
    Material m = mixMaterial(base, sage, patches(p, 5., 0.35));
    return mixMaterial(m, gold, 0.7*patches(p+vec3(8.1), 9., 0.2));
}

//planet: glossy ocean, matte continents, polar ice. p in units of the radius
Material planetField(vec3 p){
    Material ocean = makeGloss(vec3(0.03,0.10,0.22), 0.08, 0.02);
    Material land  = makeMatte(mix(vec3(0.20,0.30,0.12), vec3(0.45,0.36,0.22), fbm(6.*p)));
    Material m = mixMaterial(ocean, land, smoothstep(0.48, 0.53, fbm(2.2*p + vec3(7.7))));
    return mixMaterial(m, makeMatte(vec3(0.92)), smoothstep(0.68, 0.8, abs(p.y) + 0.08*fbm(5.*p)));
}

//smudged glass: fingerprints and haze modulating ONLY the roughness
Material smudgeField(vec3 p, float IOR){
    Material m = makeGlass(vec3(0.), IOR);
    m.surf.roughness = 0.35*patches(p, 6., 0.35);
    return m;
}
